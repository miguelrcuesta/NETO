import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neto_app/controllers/transaction_controller.dart';
import 'package:neto_app/models/transaction_model.dart';

class TransactionsProvider extends ChangeNotifier {
  final TransactionController _controller;

  TransactionsProvider() : _controller = TransactionController();

  // =========================================================
  // ESTADO CENTRAL
  // =========================================================

  List<TransactionModel> _transactions = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;

  // Estado de filtros actuales para mantener consistencia en paginación
  int? _currentYear;
  int? _currentMonth;

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
  // LÓGICA DE SELECCIÓN
  //====================================================================

  void toggleTransactionSelection(TransactionModel transaction) {
    if (transaction.transactionId == null) return;

    final id = transaction.transactionId!;
    if (_transactionsSelected.contains(id)) {
      _transactionsSelected.remove(id);
    } else {
      _transactionsSelected.add(id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _transactionsSelected.clear();
    notifyListeners();
  }

  // =========================================================
  // FIREBASE Y FILTROS
  // =========================================================

  /// Carga inicial sin filtros específicos (resetea filtros actuales)
  Future<void> loadInitialTransactions() async {
    if (_isLoadingInitial) return;

    _currentYear = null;
    _currentMonth = null;
    _lastDocument = null;
    _hasMore = true;

    _isLoadingInitial = true;
    notifyListeners();

    await _fetchAndAppendTransactions(
      startAfterDocument: null,
      limit: _initItemsSize,
    );

    _isLoadingInitial = false;
    notifyListeners();
  }

  /// Función para cargar transacciones aplicando filtros de año y mes
  Future<void> loadTransactionsByFilter({int? year, int? month}) async {
    _currentYear = year;
    _currentMonth = month;
    _lastDocument = null;
    _hasMore = true;
    _transactions = []; // Limpiamos la lista para mostrar los nuevos resultados

    _isLoadingInitial = true;
    notifyListeners();

    await _fetchAndAppendTransactions(
      startAfterDocument: null,
      limit: _initItemsSize,
    );

    _isLoadingInitial = false;
    notifyListeners();
  }

  /// Carga la siguiente página respetando los filtros actuales
  Future<void> loadMoreTransactions() async {
    if (!_hasMore || _isLoadingMore || _lastDocument == null) return;

    _isLoadingMore = true;
    notifyListeners();

    await _fetchAndAppendTransactions(
      startAfterDocument: _lastDocument,
      limit: _moreItemsSize,
    );

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Función privada genérica que conecta con el Controller
  Future<void> _fetchAndAppendTransactions({
    DocumentSnapshot? startAfterDocument,
    int? limit,
  }) async {
    try {
      final result = await _controller.getTransactionsPaginated(
        startAfterDocument: startAfterDocument,
        limit: limit,
        year: _currentYear,
        month: _currentMonth,
      );

      if (startAfterDocument == null) {
        _transactions = result.data;
      } else {
        _transactions.addAll(result.data);
      }

      _lastDocument = result.lastDocument;
      _hasMore = result.lastDocument != null;
    } catch (e) {
      debugPrint("Error al obtener transacciones: $e");
    }
  }

  // =========================================================
  // OPERACIONES CRUD
  // =========================================================

  Future<void> addTransaction({
    required BuildContext context,
    required TransactionModel newTransaction,
  }) async {
    await _controller.createNewTransaction(
      context: context,
      newTransaction: newTransaction,
    );

    _transactions.insert(0, newTransaction);
    _transactions.sort((a, b) => b.date!.compareTo(a.date!));
    notifyListeners();
  }

  Future<void> updateTransaction({
    required BuildContext context,
    required TransactionModel updatedTransaction,
  }) async {
    await _controller.updateTransaction(
      context: context,
      newTransaction: updatedTransaction,
    );

    final index = _transactions.indexWhere(
      (t) => t.transactionId == updatedTransaction.transactionId,
    );
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction({
    required BuildContext context,
    required String id,
  }) async {
    await _controller.deleteTransaction(context: context, id: id);
    _transactions.removeWhere((t) => t.transactionId == id);
    notifyListeners();
  }

  Future<void> deleteSelectedTransactionsAndUpdate({
    required BuildContext context,
    required TransactionController controller,
  }) async {
    if (_transactionsSelected.isEmpty) return;

    final List<String> idsToDelete = _transactionsSelected.toList();

    final success = await _controller.deletemultipleTransactions(
      context: context,
      idsToDelete: idsToDelete,
    );

    if (success) {
      _transactions.removeWhere(
        (t) =>
            t.transactionId != null &&
            _transactionsSelected.contains(t.transactionId),
      );
      _transactionsSelected.clear();
      notifyListeners();
    }
  }
}
