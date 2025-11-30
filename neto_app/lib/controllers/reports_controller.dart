import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/services/reports_services.dart';
import 'package:neto_app/widgets/app_snackbars.dart';

class PaginatedReportResult {
  final List<ReportModel> data;
  final DocumentSnapshot? lastDocument;

  PaginatedReportResult({required this.data, this.lastDocument});
}

class ReportsController {
  final ReportsService _reportsService;
  final List<ReportModel> reportsSelected = [];
  final int _pageSize = 20;
  final String _currentUserId = 'MIGUEL_USER_ID';

  ReportsController() : _reportsService = ReportsService();

  // =========================================================
  // LLAMADAS AL SERVICES
  // =========================================================
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

  Future<List<TransactionModel>> loadAllTransactionsForReport({
    required BuildContext context,
    required String reportId,
  }) async {
    try {
      // Llamamos al servicio que maneja la obtención eficiente de IDs
      return await _reportsService.getAllTransactionsFromReport(
        reportId: reportId,
      );
    } catch (e) {
      if (!context.mounted) return [];
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.error(
          message: "Error al cargar los movimientos del informe",
        ),
      );
      debugPrint('🚨 Error al cargar todos los movimientos del informe: $e');
      return [];
    }
  }

  Future<void> createReport({
    required BuildContext context,
    required ReportModel report,
  }) async {
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

  Future<void> updateReport({
    required BuildContext context,
    required ReportModel report,
  }) async {
    try {
      await _reportsService.updateReport(report);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.success(message: "Informe actualizado correctamente"),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.error(message: "Error al actualizar el informe"),
      );
    }
  }

  Future<void> addTransactionToReport({
    required BuildContext context,
    required ReportModel report,
    required List<String> transactionsIds,
  }) async {
    try {
      final List<String> auxlist = List<String>.from(report.listIdTransactions)
        ..addAll(transactionsIds);
      final updatedReport = report.copyWith(listIdTransactions: auxlist);
      await _reportsService.updateReport(updatedReport);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.success(message: "Añadido al informe correctamente"),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppSnackbars.error(message: "Error al añadir al informe"));
    }
  }

  Future<void> addMultipleTransactionsToReport({
    required BuildContext context,
    required List<String> transactionsIds,
  }) async {
    try {
      for (int i = 0; i < reportsSelected.length; i++) {
        final List<String> auxlist = List<String>.from(
          reportsSelected[i].listIdTransactions,
        )..addAll(transactionsIds);
        final updatedReport = reportsSelected[i].copyWith(
          listIdTransactions: auxlist,
        );
        await _reportsService.updateReport(updatedReport);
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.success(message: "Añadido al informe correctamente"),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppSnackbars.error(message: "Error al añadir al informe"));
    }
  }

  Future<void> removeTransactionsFromReport({
    required BuildContext context,
    required ReportModel report,
    required List<String> transactionsIdsToRemove,
  }) async {
    try {
      // 1. Convertir la lista actual a Set para manipulación eficiente
      final Set<String> currentIds = Set<String>.from(
        report.listIdTransactions,
      );

      // 2. Eliminar todos los IDs a remover
      currentIds.removeAll(transactionsIdsToRemove);

      // 3. Crear y actualizar el reporte
      final updatedReport = report.copyWith(
        listIdTransactions: currentIds.toList(),
      );
      await _reportsService.updateReport(updatedReport);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.success(message: "Movimiento(s) eliminado(s) del informe"),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.error(message: "Error al eliminar del informe"),
      );
    }
  }

  // =========================================================
  // FUNCIONES
  // =========================================================

  bool reportAlreadySelected(String id) {
    return reportsSelected.any((report) => report.reportId == id);
  }

  void selectReportAction(ReportModel report) {
    if (reportAlreadySelected(report.reportId) == false) {
      reportsSelected.add(report);
      debugPrint("Añadido: ${report.description}");
      debugPrint(reportsSelected.toString());
    } else {
      reportsSelected.removeWhere((item) => item.reportId == report.reportId);

      reportsSelected.remove(report);
      debugPrint("Eliminado: ${report.description}");
      debugPrint(reportsSelected.toString());
    }
  }
}
