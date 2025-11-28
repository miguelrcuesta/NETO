import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/services/reports_services.dart';
import 'package:neto_app/widgets/app_snackbars.dart';

class PaginatedReportResult {
  final List<ReportModel> data;
  final DocumentSnapshot? lastDocument;

  PaginatedReportResult({required this.data, this.lastDocument});
}

class ReportsController {
  final ReportsService _reportsService;
  final int _pageSize = 20;
  final String _currentUserId = 'MIGUEL_USER_ID';

  ReportsController() : _reportsService = ReportsService();

  Future<PaginatedReportResult> getReportsPaginated({
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      // 1. Crear la consulta con el servicio
      final Query query = _reportsService.getReports(
        pageSize: _pageSize,
        userId: _currentUserId,
        // Puedes añadir aquí filtros opcionales de fecha si los necesitas:
        // startDate: someDate,
        // endDate: someOtherDate,
      );

      // 2. Aplicar el punto de inicio (paginación)
      Query finalQuery = query;
      if (startAfterDocument != null) {
        finalQuery = query.startAfterDocument(startAfterDocument);
      }

      // 3. Ejecutar la consulta en la base de datos
      final QuerySnapshot snapshot = await finalQuery.get();

      // 4. Mapear los datos
      final List<ReportModel> reports = snapshot.docs.map((doc) {
        return ReportModel.fromJson(
          doc.data() as Map<String, dynamic>,
        ).copyWith(reportId: doc.id); // Asigna el ID del documento al modelo
      }).toList();

      // 5. Determinar el último documento para la próxima página
      final DocumentSnapshot? lastDocument = snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : null;

      return PaginatedReportResult(data: reports, lastDocument: lastDocument);
    } catch (e) {
      debugPrint('🚨 Error CRÍTICO en getReportsPaginated: $e');
      rethrow;
    }
  }

  Future<void> createReport({
    required BuildContext context,
    required ReportModel report,
  }) async {
    if (report.name.trim().isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.warning(message: "Añade un nombre al informe"),
      );
    }

    try {
      final newreportmodel = report.copyWith(
        dateCreated: DateTime.now(),
        userId: _currentUserId,
      );
      await _reportsService.createReport(newreportmodel);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.success(message: "Informe creado correctamente"),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppSnackbars.error(message: "Error al crear el informe"));
    }
  }
}
