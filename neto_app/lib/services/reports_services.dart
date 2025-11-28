import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:neto_app/models/reports_model.dart';

class ReportsService {
  final CollectionReference _reportsRef = FirebaseFirestore.instance.collection(
    'reports',
  );

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

  /// Crea un nuevo informe en Firestore con un ID de documento generado automáticamente.
  ///
  /// Este método es solo para CREAR, asumiendo que el ReportModel que recibe
  /// aún no tiene un reportId de Firestore.
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

  // Si necesitas actualizar el informe, sería un método separado:

  Future<void> updateReport(ReportModel report) async {
    if (report.reportId.isEmpty) {
      throw ArgumentError('El ReportModel debe tener un ID para actualizar.');
    }
    await _reportsRef.doc(report.reportId).update(report.toJson());
  }
}
