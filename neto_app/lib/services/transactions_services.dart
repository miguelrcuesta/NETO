// Archivo: services/transaction_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/models/transaction_model.dart';

class TransactionService {
  // Referencia a la colección principal
  final CollectionReference _transactionsRef = FirebaseFirestore.instance
      .collection('transactions');

  // =========================================================
  // CONSTRUCTOR DE CONSULTAS DINÁMICAS (Paginación y Filtros)
  // =========================================================

  /// Construye dinámicamente una consulta de Firestore aplicando filtros WHERE
  /// y los parámetros de paginación (startAfterDocument y limit).
  Query getTransactions({
    String? type,
    String? userId,
    String? categoryId,
    String? currency,
    String? frequency,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    DocumentSnapshot? lastDocument,
    required int pageSize, // Recibe el límite de la página
  }) {
    // 1. Iniciar la consulta
    Query query = _transactionsRef;

    // 2. Aplicar condiciones 'where' (Filtros)
    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
    }
    //userId != null && userId.isNotEmpty
    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryid', isEqualTo: categoryId);
    }
    // ... aplicar otros filtros (currency, frequency, amount, date ranges)
    if (currency != null && currency.isNotEmpty) {
      query = query.where('currency', isEqualTo: currency);
    }
    if (frequency != null && frequency.isNotEmpty) {
      query = query.where('frequency', isEqualTo: frequency);
    }
    if (minAmount != null && minAmount > 0) {
      query = query.where('amount', isGreaterThanOrEqualTo: minAmount);
    }
    if (maxAmount != null && maxAmount > 0) {
      query = query.where('amount', isLessThanOrEqualTo: maxAmount);
    }
    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      final adjustedEndDate = endDate.add(const Duration(days: 1));
      query = query.where('date', isLessThan: adjustedEndDate);
    }

    // 3. Aplicar ordenación (CRUCIAL para la paginación)
    query = query.orderBy('date', descending: true);

    // 4. Aplicar paginación (Cursor)
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    // 5. Aplicar límite de página
    query = query.limit(pageSize);

    return query;
  }

  Future<List<TransactionModel>> getTransactionsByIds(
    List<String> transactionIds,
  ) async {
    if (transactionIds.isEmpty) {
      return [];
    }

    const int batchSize = 10;
    List<Future<QuerySnapshot>> futures = [];

    // ... (Lógica de división en lotes y Future.wait - NO REQUIERE CAMBIOS) ...

    for (int i = 0; i < transactionIds.length; i += batchSize) {
      final end = (i + batchSize < transactionIds.length)
          ? i + batchSize
          : transactionIds.length;
      final batchIds = transactionIds.sublist(i, end);

      futures.add(
        _transactionsRef.where(FieldPath.documentId, whereIn: batchIds).get(),
      );
    }

    final List<QuerySnapshot> snapshots = await Future.wait(futures);

    // 4. Aplanar resultados con MANEJO DE ERRORES para cada documento
    List<TransactionModel> transactions = [];

    for (var snapshot in snapshots) {
      for (var doc in snapshot.docs) {
        try {
          // ⚠️ Intentar parsear el documento ⚠️
          transactions.add(
            TransactionModel.fromMap(doc.data() as Map<String, dynamic>),
          );
        } catch (e, stackTrace) {
          // Si el parsing falla, registra el error y salta al siguiente documento
          debugPrint('Error al parsear la transacción con ID ${doc.id}: $e');
          debugPrint('Stack Trace: $stackTrace');

          // El 'continue' implícito dentro del catch permite que el bucle
          // pase al siguiente 'doc' sin interrumpir el proceso.
        }
      }
    }

    return transactions;
  }

  // =========================================================
  // ESCRITURA DE DATOS (Set New Transaction)
  // =========================================================

  /// Guarda una nueva transacción en Firestore y maneja errores.
  Future<String?> createTransaction(
    TransactionModel transaction,
    String userId,
  ) async {
    try {
      final newDocRef = _transactionsRef.doc();
      final newTransactionId = newDocRef.id;

      final transactionWithId = transaction.copyWith(
        userId: userId,
        transactionId: newTransactionId,
        date: transaction.date ?? DateTime.now(),
      );

      final transactionMap = transactionWithId.toMap();

      await newDocRef.set(transactionMap);

      return newTransactionId;
    } on FirebaseException catch (e) {
      debugPrint(
        'Firebase Error al crear transacción: ${e.code} - ${e.message}',
      );
      throw Exception('Fallo al guardar en la base de datos: ${e.message}');
    } catch (e) {
      debugPrint('Error desconocido al crear transacción: $e');
      throw Exception('Error desconocido al procesar la transacción.');
    }
  }

  // =========================================================
  // ACTUALIZAR DATOS (Update Transaction)
  // =========================================================

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final newDocRef = _transactionsRef.doc(transaction.transactionId);
      await newDocRef.update(transaction.toMap());
    } on FirebaseException catch (e) {
      debugPrint(
        'Firebase Error al actualizar transacción: ${e.code} - ${e.message}',
      );
      throw Exception('Fallo al guardar en la base de datos: ${e.message}');
    } catch (e) {
      debugPrint('Error desconocido al actualizar transacción: $e');
      throw Exception('Error desconocido al procesar la transacción.');
    }
  }

  // =========================================================
  // ELIMINAR DATOS (Update Transaction)
  // =========================================================
  Future<void> deleteTransaction(String id) async {
    try {
      final newDocRef = _transactionsRef.doc(id);
      await newDocRef.delete();
    } on FirebaseException catch (e) {
      debugPrint(
        'Firebase Error al eliminar transacción: ${e.code} - ${e.message}',
      );
      throw Exception('Fallo al eliminar en la base de datos: ${e.message}');
    } catch (e) {
      debugPrint('Error desconocido al eliminar transacción: $e');
      throw Exception('Error desconocido al eliminar la transacción.');
    }
  }

  Future<bool> deleteMultipleTransactions(List<String> transactionIds) async {
    try {
      for (int i = 0; i < transactionIds.length; i++) {
        deleteTransaction(transactionIds[i]);
      }

      return true;
    } on FirebaseException catch (e) {
      debugPrint(
        'Firebase Error al eliminar las transaciones: ${e.code} - ${e.message}',
      );
      throw Exception('Fallo al eliminar en la base de datos: ${e.message}');
    } catch (e) {
      debugPrint('Error desconocido al eliminar las transaciones: $e');
      throw Exception('Error desconocido al eliminar las transaciones.');
    }
  }
}
