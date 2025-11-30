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

  // =========================================================
  // ESTADO INTERNO
  // =========================================================

  final List<String> transactionsSelected = [];

  final int _pageSize = 20;
  final String _currentUserId = 'MIGUEL_USER_ID';

  // =========================================================
  // LLAMADAS AL SERVICES
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

  Future<void> createNewTransaction({
    required BuildContext context,
    required TransactionModel newTransaction,
  }) async {
    try {
      final newId = await _transactionService.createTransaction(newTransaction);

      if (newId != null) {
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

  Future<void> updateTransaction({
    required BuildContext context,
    required TransactionModel newTransaction,
  }) async {
    try {
      await _transactionService.updateTransaction(newTransaction);

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppSnackbars.success(message: '¡Movimiento guardado!'));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.error(message: "Error al actualizar el movimiento"),
      );
    }
  }

  Future<void> deleteTransaction({
    required BuildContext context,
    required String id,
  }) async {
    try {
      await _transactionService.deleteTransaction(id);

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppSnackbars.success(message: '¡Movimiento eliminado!'));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.error(message: "Error al eliminar el movimiento"),
      );
    }
  }

  Future<void> deletemultipleTransactions({
    required BuildContext context,
  }) async {
    try {
      if (transactionsSelected.isNotEmpty) {
        await _transactionService.deleteMultipleTransactions(
          transactionsSelected,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          AppSnackbars.warning(message: 'Selecciona para poder eliminar'),
        );
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppSnackbars.success(message: '¡Movimientos eliminados!'));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.error(message: "Error al eliminar los movimientos"),
      );
    }
  }

  // =========================================================
  // FUNCIONES
  // =========================================================

  bool transactionAlreadySelected(String id) {
    if (transactionsSelected.contains(id)) {
      return true;
    }
    return false;
  }

  void selectTransactionAction(TransactionModel transaction) {
    //Si no existe se añade
    if (transactionAlreadySelected(transaction.transactionId!) == false) {
      transactionsSelected.add(transaction.transactionId!);
      debugPrint("Añadido: ${transaction.description} - ${transaction.amount}");
      debugPrint(transactionsSelected.toString());
    } else {
      transactionsSelected.remove(transaction.transactionId!);
      debugPrint(
        "Eliminado: ${transaction.description} - ${transaction.amount}",
      );
      debugPrint(transactionsSelected.toString());
    }
  }
}
