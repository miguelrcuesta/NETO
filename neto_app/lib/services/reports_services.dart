import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/services/transactions_services.dart';

class ReportsService {
  final CollectionReference _reportsRef = FirebaseFirestore.instance.collection(
    'reports',
  );

  final TransactionService _transactionService = TransactionService();

  // =========================================================
  // LECTURA DE DATOS
  // =========================================================
  Future<ReportModel?> getReportById(String reportId) async {
    final docSnapshot = await _reportsRef.doc(reportId).get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      return ReportModel.fromJson(docSnapshot.data() as Map<String, dynamic>);
    }
    return null;
  }

  Query getReports({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    DocumentSnapshot? lastDocument,
    required int pageSize,
  }) {
    // 1. Iniciar la consulta
    Query query = _reportsRef;

    // 2. Aplicar condiciones 'where' (Filtros)

    // Filtro por ID de usuario (Crucial para aplicaciones multiusuario)
    if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }

    // Filtro por rangos de fecha de creación (dateCreated)
    if (startDate != null) {
      // Usamos el campo 'dateCreated' del ReportModel para filtrar
      query = query.where('dateCreated', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      // Ajustamos el endDate para incluir todo el día
      final adjustedEndDate = endDate.add(const Duration(days: 1));
      query = query.where('dateCreated', isLessThan: adjustedEndDate);
    }

    // 3. Aplicar ordenación (CRUCIAL para la paginación)
    // Ordenamos por la fecha de creación de forma descendente (más reciente primero)
    query = query.orderBy('dateCreated', descending: true);

    // 4. Aplicar paginación (Cursor)
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    // 5. Aplicar límite de página
    query = query.limit(pageSize);

    return query;
  }

  Future<List<TransactionModel>> getAllTransactionsFromReport({
    required String reportId,
  }) async {
    // 1. OBTENER EL REPORTE
    final ReportModel? report = await getReportById(reportId);

    if (report == null) {
      throw Exception('Report document with ID $reportId not found');
    }

    // 2. PREPARAR TODOS LOS IDs
    // Se invierte la lista si quieres ver los movimientos más recientes primero.
    final allTransactionIds = report.listIdTransactions.reversed.toList();

    // 3. OBTENER LOS MODELOS DE TRANSACCIÓN REALES
    if (allTransactionIds.isEmpty) {
      return [];
    }

    // Llamamos al servicio eficiente (maneja el whereIn y el batching de 10)
    List<TransactionModel> transactions = await _transactionService
        .getTransactionsByIds(allTransactionIds);

    // 4. Asegurar el orden basado en la lista de IDs del reporte
    transactions.sort((a, b) {
      return allTransactionIds
          .indexOf(a.transactionId!)
          .compareTo(allTransactionIds.indexOf(b.transactionId!));
    });

    // 5. DEVOLVER LA LISTA SIMPLE
    return transactions;
  }

  // =========================================================
  // ESCRITURA DE DATOS
  // =========================================================
  Future<void> createReport(ReportModel report) async {
    try {
      final newDocRef = _reportsRef.doc();
      final newTReportId = newDocRef.id;

      final newreportmodel = report.copyWith(
        dateCreated: DateTime.now(),
        reportId: newTReportId,
      );

      final DocumentReference docRef = await _reportsRef.add(
        newreportmodel.toJson(),
      );

      debugPrint('✅ Nuevo informe creado con ID: ${docRef.id}');
    } catch (e) {
      // 4. Manejo de errores
      debugPrint('🚨 Error al crear el nuevo informe en Firestore: $e');

      throw FirebaseException(
        plugin: 'Firestore',
        message: 'Fallo al crear el informe: $e',
      );
    }
  }

  // =========================================================
  // ACTUALIZAR DE DATOS
  // =========================================================

  Future<void> updateReport(ReportModel report) async {
    if (report.reportId.isEmpty) {
      throw ArgumentError('El ReportModel debe tener un ID para actualizar.');
    }
    await _reportsRef.doc(report.reportId).update(report.toJson());
  }

  // =========================================================
  // ELIMINAT DATOS
  // =========================================================

  Future<void> deleteReport(String id) async {
    await _reportsRef.doc(id).delete();
  }
}
