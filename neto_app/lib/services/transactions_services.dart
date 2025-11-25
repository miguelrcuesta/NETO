// Archivo: services/transaction_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/models/transaction_model.dart';

class TransactionService {
  // Referencia a la colección principal
  final CollectionReference _transactionsRef = FirebaseFirestore.instance.collection('transactions');
  
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

  // =========================================================
  // ESCRITURA DE DATOS (Set New Transaction)
  // =========================================================

  /// Guarda una nueva transacción en Firestore y maneja errores.
  Future<String?> setNewTransaction(TransactionModel transaction) async {
    try {
      final newDocRef = _transactionsRef.doc();
      final newTransactionId = newDocRef.id;

      final transactionWithId = transaction.copyWith(
        transactionId: newTransactionId,
        date: transaction.date ?? DateTime.now(), 
      );
      
      final transactionMap = transactionWithId.toMap();
      
      await newDocRef.set(transactionMap);

      return newTransactionId;
      
    } on FirebaseException catch (e) {
      debugPrint('Firebase Error al crear transacción: ${e.code} - ${e.message}');
      throw Exception('Fallo al guardar en la base de datos: ${e.message}');
      
    } catch (e) {
      debugPrint('Error desconocido al crear transacción: $e');
      throw Exception('Error desconocido al procesar la transacción.');
    }
  }

}