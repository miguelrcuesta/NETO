import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para DocumentSnapshot
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/services/reports_services.dart';
import 'package:neto_app/widgets/app_snackbars.dart';
// import 'package:neto_app/constants/app_utils.dart'; // Para mostrar SnackBar/Alertas

// ⚠️ PLACEHOLDER: Esta clase DEBE existir en tu proyecto
class PaginatedReportResult {
  final List<ReportModel> data;
  final DocumentSnapshot? lastDocument;

  PaginatedReportResult({required this.data, this.lastDocument});
}
// FIN PLACEHOLDER

class ReportsController {
  final ReportsService _reportsService = ReportsService();

  final String _currentUserId = 'MIGUEL_USER_ID';

  String getUniqueReportTransactionId() {
    // Esto genera un ID único de documento de Firestore sin crearlo realmente.
    return FirebaseFirestore.instance.collection('reports').doc().id;
  }

  //####################################################################
  // 1. CREACIÓN
  //####################################################################

  Future<void> createReport({
    required BuildContext context,
    required ReportModel report,
  }) async {
    debugPrint('Create report');
    try {
      final reportWithUser = report.copyWith(userId: _currentUserId);
      await _reportsService.createReport(reportWithUser);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.success(message: "Informe creador correctamente"),
      );
    } catch (e) {
      debugPrint("Controller: Error al crear informe: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppSnackbars.error(message: "Error al crear el informe"));
    }
  }

  //####################################################################
  // 2. LECTURA (PAGINACIÓN)
  //####################################################################

  /// Obtiene los informes paginados usando un cursor (DocumentSnapshot).
  Future<PaginatedReportResult> getReportsPaginated({
    DocumentSnapshot? lastDocument,
    int pageSize = 10,
    // Puedes añadir más filtros aquí si los necesitas (ej. startDate, endDate)
  }) async {
    debugPrint('getReportsPaginated');
    try {
      final Query query = _reportsService.getReports(
        userId: _currentUserId,
        lastDocument: lastDocument,
        pageSize: pageSize,
      );

      final QuerySnapshot querySnapshot = await query.get();

      final reports = querySnapshot.docs.map((doc) {
        return ReportModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      // Determinar si hay un puntero para la siguiente página
      DocumentSnapshot? newLastDocument;
      if (querySnapshot.docs.isNotEmpty &&
          querySnapshot.docs.length == pageSize) {
        newLastDocument = querySnapshot.docs.last;
      }

      return PaginatedReportResult(
        data: reports,
        lastDocument: newLastDocument,
      );
    } catch (e) {
      debugPrint("Controller: Error en la paginación de informes: $e");
      return PaginatedReportResult(data: [], lastDocument: null);
    }
  }

  //####################################################################
  // 3. ELIMINACIÓN
  //####################################################################

  /// Elimina un solo informe.
  Future<void> deleteReport({
    required BuildContext context,
    required String id,
  }) async {
    debugPrint('deleteReport');
    try {
      await _reportsService.deleteReport(id);
      // AppUtils.showSuccess(context, 'Informe eliminado con éxito.');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.success(message: 'Informe eliminado con éxito.'),
      );
    } catch (e) {
      debugPrint("Controller: Error al eliminar informe $id: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.error(message: 'Error al eliminar el informe.'),
      );
    }
  }

  /// Llama al servicio para eliminar una lista de IDs de informes.
  Future<bool> deletemultipleReports({
    required BuildContext context,
    required List<String> idsToDelete,
  }) async {
    debugPrint('deletemultipleReports');
    if (idsToDelete.isEmpty) {
      debugPrint("Controller: Lista de IDs de informes vacía.");
      return false;
    }

    try {
      // Implementación simple (iterativa):
      for (final id in idsToDelete) {
        await _reportsService.deleteReport(id);
      }

      // AppUtils.showSuccess(context, 'Se eliminaron ${idsToDelete.length} informes.');
      debugPrint(
        "Controller: ${idsToDelete.length} informes eliminados con éxito.",
      );
      return true;
    } catch (e) {
      // AppUtils.showError(context, 'Error al eliminar informes.');
      debugPrint(
        "Controller: Excepción durante el borrado múltiple de informes: $e",
      );
      return false;
    }
  }

  //####################################################################
  // 4. ACTUALIZACIÓN
  //####################################################################

  /// Actualiza un informe existente en la base de datos a través del servicio.
  Future<void> updateReport({
    required BuildContext context,
    required ReportModel updatedReport,
  }) async {
    debugPrint('updateReport');
    // 🔑 Requerimos una instancia de ReportsService si no es un campo de clase ya definido
    // final ReportsService _reportsService = ReportsService();

    try {
      // 1. Validar que el ID del informe exista
      if (updatedReport.reportId.isEmpty) {
        throw ArgumentError('El ReportModel debe tener un ID para actualizar.');
      }

      // 2. Llamar al servicio para realizar la actualización en Firestore
      await _reportsService.updateReport(updatedReport);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.success(message: 'Informe actualizado con éxito.'),
      );
    } on ArgumentError catch (e) {
      debugPrint("Controller: Error de validación al actualizar informe: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.error(message: 'Error al actualizar el informe.'),
      );
      throw Exception('Error de validación del informe.');
    } catch (e) {
      debugPrint(
        "Controller: Error al actualizar informe ${updatedReport.reportId}: $e",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbars.error(message: 'Error al actualizar el informe.'),
      );
      // AppUtils.showError(context, 'Error al actualizar el informe.');
      throw Exception('Fallo al actualizar el informe.');
    }
  }
}
