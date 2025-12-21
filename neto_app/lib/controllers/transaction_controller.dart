// Archivo: controllers/transaction_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/provider/transaction_provider.dart';
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
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // =========================================================
  // LLAMADAS AL SERVICES
  // =========================================================

  /// Carga la siguiente página de transacciones y actualiza el Stream.
  /// Carga la siguiente página de transacciones con soporte para filtros de Año y Mes.
  Future<PaginatedTransactionResult> getTransactionsPaginated({
    String? type,
    DocumentSnapshot? startAfterDocument,
    int? limit,
    int? year,
    int? month,
  }) async {
    try {
      debugPrint(
        "Llamando al controller: getTransactionsPaginated (Filtros: Year $year, Month $month)",
      );

      final Query query = _transactionService.getTransactions(
        pageSize: limit ?? _pageSize,
        type: type,
        userId: _currentUserId,
        year: year,
        month: month,
      );

      Query finalQuery = query;
      if (startAfterDocument != null) {
        finalQuery = query.startAfterDocument(startAfterDocument);
      }

      final QuerySnapshot snapshot = await finalQuery.get();

      final List<TransactionModel> transactions = snapshot.docs.map((doc) {
        return TransactionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          transactionId: doc.id,
        );
      }).toList();

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
      debugPrint("Llamando al controller: createNewTransaction");
      final newId = await _transactionService.createTransaction(
        newTransaction,
        _currentUserId,
      );

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
      debugPrint("Llamando al controller: updateTransactions");
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
      debugPrint("Llamando al controller: deleteTransaction");
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

  Future<bool> deletemultipleTransactions({
    required BuildContext context,
    required List<String> idsToDelete,
  }) async {
    debugPrint("Llamando al controller: deletemultipleTransactions");
    if (idsToDelete.isEmpty) {
      debugPrint(
        "Controller: Lista de IDs vacía. No se realizó ninguna acción.",
      );
      return false;
    }

    try {
      // 1. Llamar al servicio de API para realizar el borrado
      final success = await _transactionService.deleteMultipleTransactions(
        idsToDelete,
      );

      if (success) {
        // 2. Mostrar un mensaje de éxito al usuario (opcional)ç
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            AppSnackbars.success(message: '¡Eliminado correctamente!'),
          );
        }

        debugPrint(
          "Controller: ${idsToDelete.length} transacciones eliminadas con éxito.",
        );
        return true;
      } else {
        // Manejar el caso donde la API devuelve un error (ej. 400/500)
        // AppUtils.showError(context, 'Error al eliminar movimientos.');
        debugPrint("Controller: La API falló al eliminar las transacciones.");
        return false;
      }
    } catch (e) {
      // Manejar errores de red o excepciones
      // AppUtils.showError(context, 'Error de red o excepción: $e');
      debugPrint("Controller: Excepción durante el borrado: $e");
      return false;
    }
  }
}
