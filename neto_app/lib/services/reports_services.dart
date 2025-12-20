import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/services/transactions_services.dart';

class ReportsService {
  final CollectionReference _reportsRef = FirebaseFirestore.instance.collection(
    'reports',
  );

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

  /// Obtiene y ordena todas las transacciones incrustadas en un informe específico.
  Future<List<TransactionModel>> getAllReportTransactions({
    required String reportId,
  }) async {
    // 1. OBTENER EL REPORTE
    final ReportModel? report = await getReportById(reportId);

    if (report == null) {
      throw Exception('Report document with ID $reportId not found');
    }

    // 2. EXTRAER TRANSACCIONES DEL MAPA
    // Obtenemos los valores (los objetos ReportTransactionModel) del mapa.
    final List<TransactionModel> allReportTransactions = report
        .reportTransactions
        .values
        .toList();

    if (allReportTransactions.isEmpty) {
      return [];
    }

    // 3. ORDENAR POR FECHA (Descendente: más reciente primero)
    allReportTransactions.sort((a, b) => b.date!.compareTo(a.date!));

    // 4. DEVOLVER LA LISTA SIMPLE Y ORDENADA
    // Las transacciones ya son objetos completos, no necesitamos buscar IDs en otro lugar.
    return allReportTransactions;
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

      await newDocRef.set(newreportmodel.toJson());

      debugPrint('✅ Nuevo informe creado con ID: $newTReportId');
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
