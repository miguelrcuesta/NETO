// Archivo: controllers/transaction_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/services/transactions_services.dart';
import 'package:neto_app/widgets/app_snackbars.dart';
import 'package:rxdart/rxdart.dart'; // ⭐️ Necesario para BehaviorSubject y .value ⭐️
import 'package:neto_app/models/transaction_model.dart';

class PaginatedTransactionResult {
  final List<TransactionModel> data;
  final DocumentSnapshot? lastDocument;

  PaginatedTransactionResult({required this.data, this.lastDocument});
}

class TransactionController {
  final TransactionService _transactionService;

  TransactionController() : _transactionService = TransactionService();

  // Emite la lista completa acumulada de transacciones.
  final _transactionsController =
      StreamController<List<TransactionModel>>.broadcast();
  Stream<List<TransactionModel>> get transactionsStream =>
      _transactionsController.stream;

  // Usa BehaviorSubject: emite el último valor a nuevos suscriptores y permite acceder al valor actual (.value)
  final _isLoadingController = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoading => _isLoadingController.stream;
  bool get isLoadingValue =>
      _isLoadingController.value; // ⭐️ El getter corregido ⭐️

  // =========================================================
  // ESTADO INTERNO
  // =========================================================

  final List<TransactionModel> _transactions = [];
  bool hasMoreData = true;
  final int _pageSize = 20;
  final String _currentUserId = 'MIGUEL_USER_ID';

  // =========================================================
  // LÓGICA DE CARGA DE DATOS (Paginación)
  // =========================================================

  /// Carga la siguiente página de transacciones y actualiza el Stream.
  Future<PaginatedTransactionResult> getTransactionsPaginated({
    required String type,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      // 1. Crear la consulta con el servicio
      final Query query = _transactionService.getTransactions(
        pageSize: _pageSize,
        type: type,
        userId: _currentUserId,
      );

      // 2. Agregar el punto de inicio (paginación)
      Query finalQuery = query;
      if (startAfterDocument != null) {
        finalQuery = query.startAfterDocument(startAfterDocument);
      }

      // 3. Ejecutar la consulta en la base de datos
      final QuerySnapshot snapshot = await finalQuery.get();

      // 4. Mapear los datos
      final List<TransactionModel> transactions = snapshot.docs.map((doc) {
        return TransactionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          transactionId: doc.id,
        );
      }).toList();

      // 5. Determinar el último documento para la próxima página
      final DocumentSnapshot? lastDocument = snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : null;

      return PaginatedTransactionResult(
        data: transactions,
        lastDocument: lastDocument,
      );
    } catch (e) {
      debugPrint(
        '🚨 Error CRÍTICO en getTransactionsPaginated para tipo $type: $e',
      );
      rethrow;
    }
  }

  // =========================================================
  // LÓGICA DE CREACIÓN DE DATOS
  // =========================================================

  Future<void> createNewTransaction({
    required BuildContext context,
    required TransactionModel newTransaction,
  }) async {
    try {
      final newId = await _transactionService.createTransaction(newTransaction);

      if (newId != null) {
        final savedTransaction = newTransaction.copyWith(
          transactionId: newId,
          date: newTransaction.date ?? DateTime.now(),
        );

        // Insertar al inicio y emitir la lista actualizada
        _transactions.insert(0, savedTransaction);
        _transactionsController.sink.add(List.from(_transactions));
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(AppSnackbars.success(message: '¡Movimiento guardado!'));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.error(message: "Error al crear el movimiento"),
      );
    }
  }
}
