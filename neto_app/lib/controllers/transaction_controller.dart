// Archivo: controllers/transaction_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/services/transactions_services.dart';
import 'package:neto_app/widgets/app_snackbars.dart';
import 'package:rxdart/rxdart.dart'; // ⭐️ Necesario para BehaviorSubject y .value ⭐️
import 'package:neto_app/models/transaction_model.dart';


class TransactionController {
  final TransactionService _service;
  
  // =========================================================
  // STREAMS PÚBLICOS PARA LA UI
  // =========================================================
  
  // Emite la lista completa acumulada de transacciones.
  final _transactionsController = StreamController<List<TransactionModel>>.broadcast();
  Stream<List<TransactionModel>> get transactionsStream => _transactionsController.stream;

  // Usa BehaviorSubject: emite el último valor a nuevos suscriptores y permite acceder al valor actual (.value)
  final _isLoadingController = BehaviorSubject<bool>.seeded(false); 
  Stream<bool> get isLoading => _isLoadingController.stream;
  bool get isLoadingValue => _isLoadingController.value; // ⭐️ El getter corregido ⭐️

  // =========================================================
  // ESTADO INTERNO
  // =========================================================
  
  final List<TransactionModel> _transactions = []; 
  DocumentSnapshot? _lastDocument; 
  bool hasMoreData = true;
  final int _pageSize = 20;
  final String _currentUserId = 'MIGUEL_USER_ID'; // Simulación de usuario actual

  TransactionController({required TransactionService service}) : _service = service;


  // =========================================================
  // LÓGICA DE CARGA DE DATOS (Paginación)
  // =========================================================

  /// Carga la siguiente página de transacciones y actualiza el Stream.
  Future<List<TransactionModel>> getTransactions({
    required String type, // Tipo de transacción: EXPENSE o INCOME
    // Se puede añadir un DocumentSnapshot para paginación si se quiere, 
    // pero para este modelo de FutureBuilder simplificado no es necesario.
  }) async {
    
    // Si usas paginación, el tamaño de la página (_pageSize) debería estar definido.
    // final int _pageSize = 20; 
    
    try {
      // 1. Obtener la consulta desde el servicio (asumiendo que tiene la lógica de filtro 'type')
      final Query query = _service.getTransactions(
          pageSize: _pageSize,
          type: type,
          userId: _currentUserId, // Si es necesario
          lastDocument: _lastDocument,
      );

      // 2. Ejecutar la consulta en la base de datos
      final QuerySnapshot snapshot = await query.get();
      
      // 3. Mapear y devolver los datos
      if (snapshot.docs.isNotEmpty) {
        final List<TransactionModel> transactions = snapshot.docs.map((doc) {
          // Mapea el DocumentSnapshot a tu modelo
          return TransactionModel.fromMap(
            doc.data() as Map<String, dynamic>, 
            transactionId: doc.id,
          );
        }).toList();

        // ⭐️ Retorna la lista de transacciones (Future<List<TransactionModel>>) ⭐️
        return transactions;
      }
      
      // Si no hay documentos, retorna una lista vacía.
      return [];

    } catch (e) {
      // 4. Manejo de errores
      debugPrint('🚨 Error CRÍTICO en getTransactions para tipo $type: $e');
      
      // Lanza la excepción para que el FutureBuilder la capture y muestre el mensaje de error.
      throw Exception('Fallo al obtener transacciones de tipo $type: $e');
    }
  }


  // =========================================================
  // LÓGICA DE CREACIÓN DE DATOS
  // =========================================================

  Future<void> createNewTransaction({
    required BuildContext context,
    required TransactionModel newTransaction,
  }) async {
    _setIsLoading(true);
    
    try {
      final newId = await _service.setNewTransaction(newTransaction); 

      if (newId != null) {
        final savedTransaction = newTransaction.copyWith(
          transactionId: newId,
          date: newTransaction.date ?? DateTime.now(),
        );

        // Insertar al inicio y emitir la lista actualizada
        _transactions.insert(0, savedTransaction); 
        _transactionsController.sink.add(List.from(_transactions));
      if(!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          AppSnackbars.success(message: '¡Movimiento guardado!'),
        );
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if(!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.error(message: errorMessage),
      );
    } finally {
      _setIsLoading(false);
    }
  }
  
  // =========================================================
  // LIMPIEZA
  // =========================================================

  void _setIsLoading(bool loading) {
    if (!_isLoadingController.isClosed) {
      _isLoadingController.sink.add(loading);
    }
  }

  void dispose() {
    _transactionsController.close();
    _isLoadingController.close();
  }
}