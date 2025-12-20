import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Necesario para DocumentSnapshot
import 'package:neto_app/controllers/transaction_controller.dart';
import 'package:neto_app/models/transaction_model.dart';
// Importa tus utilidades de Snackbar si es necesario, aunque el Provider se enfoca en el estado.

class TransactionsProvider extends ChangeNotifier {
  // 1.Inyección de dependencia (Tu Controller)
  final TransactionController _controller;

  TransactionsProvider() : _controller = TransactionController();

  // =========================================================
  // ESTADO CENTRAL
  // =========================================================

  List<TransactionModel> _transactions = [];

  DocumentSnapshot? _lastDocument; // El puntero para la siguiente página
  bool _hasMore = true; // Flag para saber si hay más datos en Firestore

  bool _isLoadingInitial = false; // Solo para la primera carga
  bool _isLoadingMore = false; // Para el scroll infinito

  // =========================================================
  // Getters
  // =========================================================

  final int _initItemsSize = 30;
  final int _moreItemsSize = 30;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  final Set<String> _transactionsSelected = {};
  Set<String> get transactionsSelected => _transactionsSelected;
  bool get isMultiselectActive => _transactionsSelected.isNotEmpty;

  //====================================================================
  //LÓGICA DE SELECCIÓN
  //====================================================================

  /// Añade o elimina el ID de una transacción de la lista de seleccionados
  /// y notifica a los listeners (AppBar, TransactionCard).
  void toggleTransactionSelection(TransactionModel transaction) {
    if (transaction.transactionId == null) return;

    final id = transaction.transactionId!;
    if (_transactionsSelected.contains(id)) {
      _transactionsSelected.remove(id);
    } else {
      _transactionsSelected.add(id);
    }
    notifyListeners();
    debugPrint(
      _transactionsSelected.toString(),
    ); //  Notifica el cambio de selección
  }

  /// Limpia la lista de seleccionados y desactiva el modo multiselección.
  void clearSelection() {
    _transactionsSelected.clear();
    notifyListeners(); // 📢 Notifica para forzar el cambio del AppBar
  }

  // =========================================================
  // FIREBASE
  // =========================================================

  /// 1. Carga el primer lote de transacciones.
  Future<void> loadInitialTransactions() async {
    debugPrint("Llamando al provider: loadInitialTransactions");
    // Evita recargar si ya hay datos y no se necesita refresh
    // if (_transactions.isNotEmpty || _isLoadingInitial) return;
    if (_isLoadingInitial) return;

    _isLoadingInitial = true;
    notifyListeners();

    // Llama a la lógica de paginación con un lastDocument nulo
    await _fetchAndAppendTransactions(
      startAfterDocument: null,
      limit: _initItemsSize,
    );

    _isLoadingInitial = false;
    notifyListeners();
  }

  /// 2. Carga la siguiente página de transacciones.
  Future<void> loadMoreTransactions() async {
    debugPrint("Llamando al provider: loadMoreTransactions");
    // Restricciones para evitar llamadas innecesarias o duplicadas
    if (!_hasMore || _isLoadingMore || _lastDocument == null) return;

    _isLoadingMore = true;
    notifyListeners();

    // Llama a la lógica de paginación usando el último puntero
    await _fetchAndAppendTransactions(
      startAfterDocument: _lastDocument,
      limit: _moreItemsSize,
    );

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Función privada genérica para manejar la consulta y la actualización del estado.
  Future<void> _fetchAndAppendTransactions({
    DocumentSnapshot? startAfterDocument,
    int? limit,
  }) async {
    try {
      final result = await _controller.getTransactionsPaginated(
        startAfterDocument: startAfterDocument,
        limit: limit,
      );

      if (result.data.isNotEmpty && startAfterDocument == null) {
        // Carga inicial: reemplaza toda la lista
        _transactions = result.data;
      } else if (result.data.isNotEmpty && startAfterDocument != null) {
        // Paginación: agrega a la lista existente
        _transactions.addAll(result.data);
      }

      // Actualiza el puntero de paginación
      _lastDocument = result.lastDocument;
      _hasMore = result.lastDocument != null;
    } catch (e) {
      debugPrint("Error al obtener transacciones paginadas: $e");
      // Opcional: manejar si _hasMore debe ser false en caso de error
    }
  }

  // =========================================================
  // PROVIDER FUNCIONES
  // =========================================================

  /// Crea y añade una nueva transacción.
  Future<void> addTransaction({
    required BuildContext context,
    required TransactionModel newTransaction,
  }) async {
    // 1. Persistir el dato (Controller maneja el SnackBar de éxito/error)
    await _controller.createNewTransaction(
      context: context,
      newTransaction: newTransaction,
    );

    // 2. Actualizar la lista en memoria (Se asume que la transacción fue exitosa)
    // Se añade al principio para que sea visible inmediatamente.
    _transactions.insert(0, newTransaction);
    _transactions.sort((a, b) => b.date!.compareTo(a.date!));
    notifyListeners();
  }

  /// Edita una transacción sin recargar la lista completa.
  Future<void> updateTransaction({
    required BuildContext context,
    required TransactionModel updatedTransaction,
  }) async {
    // 1. Persistir el cambio (Controller maneja el SnackBar)
    await _controller.updateTransaction(
      context: context,
      newTransaction: updatedTransaction,
    );

    // 2. Reemplazar el objeto en memoria
    final index = _transactions.indexWhere(
      (t) => t.transactionId == updatedTransaction.transactionId,
    );
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      notifyListeners();
    }
  }

  /// Elimina una transacción.
  Future<void> deleteTransaction({
    required BuildContext context,
    required String id,
  }) async {
    // 1. Eliminar del backend (Controller maneja el SnackBar)
    await _controller.deleteTransaction(context: context, id: id);

    // 2. Eliminar de la lista en memoria
    _transactions.removeWhere((t) => t.transactionId == id);
    notifyListeners();
  }

  /// Elimina una transacciones
  Future<void> deleteSelectedTransactionsAndUpdate({
    required BuildContext context,
    required TransactionController controller,
  }) async {
    if (_transactionsSelected.isEmpty) return;

    final List<String> idsToDelete = _transactionsSelected.toList();

    // 1. Llamar al Controller para ejecutar el borrado en la API
    final success = await _controller.deletemultipleTransactions(
      context: context,
      idsToDelete: idsToDelete,
    );

    if (success) {
      // 2. Si la API tuvo éxito, actualiza la lista local:
      // Remueve de _transactions todos los elementos cuyo ID esté en _transactionsSelected.
      _transactions.removeWhere(
        (t) =>
            t.transactionId != null &&
            _transactionsSelected.contains(t.transactionId),
      );

      // 3. Limpiar la selección
      _transactionsSelected.clear();

      // 4. Notificar a la UI (ListView y AppBar)
      notifyListeners();
    }
  }
}
