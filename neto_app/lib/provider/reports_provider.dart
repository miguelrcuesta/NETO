import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Necesario para DocumentSnapshot
import 'package:neto_app/controllers/reports_controller.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';
// Asumiendo que PaginatedReportResult existe en tu archivo de utilidades/controladores.
// (Definición ficticia aquí para contexto, si no está en otro archivo)

class PaginatedReportResult {
  final List<ReportModel> data;
  final DocumentSnapshot? lastDocument;

  PaginatedReportResult({required this.data, this.lastDocument});
}

class ReportsProvider extends ChangeNotifier {
  // 1. 🔑 Inyección de dependencia (Tu Controller)
  final ReportsController _controller;

  // Puedes inyectar el controller o crearlo directamente
  ReportsProvider() : _controller = ReportsController();

  // =========================================================
  // ESTADO CENTRAL
  // =========================================================

  List<ReportModel> _reports = [];

  // ⭐️ Paginación
  DocumentSnapshot? _lastDocument; // Puntero para la siguiente página
  bool _hasMore = true; // Flag para saber si hay más datos en Firestore

  // ⭐️ Estados de Carga
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;

  // ⭐️ Multiselección
  final Set<String> _reportsSelected = {};

  // =========================================================
  // 📥 Getters (Exposición del Estado a la UI)
  // =========================================================

  List<ReportModel> get reports => _reports;
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  Set<String> get reportsSelected => _reportsSelected;
  bool get isMultiselectActive => _reportsSelected.isNotEmpty;

  //====================================================================
  // 🔑 LÓGICA DE SELECCIÓN (Similar a Transactions) 🔑
  //====================================================================

  /// Añade o elimina el ID de un informe de la lista de seleccionados.
  void toggleReportSelection(ReportModel report) {
    final id = report.reportId;
    if (_reportsSelected.contains(id)) {
      _reportsSelected.remove(id);
    } else {
      _reportsSelected.add(id);
    }
    notifyListeners();
  }

  /// Limpia la lista de seleccionados.
  void clearSelection() {
    _reportsSelected.clear();
    notifyListeners();
  }

  //====================================================================
  //FIREBASE/PAGINACIÓN
  //====================================================================

  /// Carga el primer lote de informes (Página 1).
  Future<void> loadInitialReports() async {
    // Evita recargar si ya está en curso
    if (_isLoadingInitial) return;

    _isLoadingInitial = true;
    _reports = []; // Limpiar lista para refresco
    _lastDocument = null;
    _hasMore = true;
    notifyListeners();

    await _fetchAndAppendReports(startAfterDocument: null);

    _isLoadingInitial = false;
    notifyListeners();
  }

  /// Busca y devuelve la versión más reciente del Reporte por su ID.
  /// Si no lo encuentra, lanza una excepción o devuelve el ReportModel inicial.
  ReportModel getReportById(String reportId) {
    try {
      return _reports.firstWhere((report) => report.reportId == reportId);
    } catch (e) {
      debugPrint(
        'Error: Reporte con ID $reportId no encontrado en el Provider. $e',
      );

      return ReportModel.empty();
    }
  }

  /// Carga la siguiente página de informes.
  Future<void> loadMoreReports() async {
    // Restricciones para evitar llamadas innecesarias o duplicadas
    if (!_hasMore || _isLoadingMore || _lastDocument == null) return;

    _isLoadingMore = true;
    notifyListeners();

    await _fetchAndAppendReports(startAfterDocument: _lastDocument);

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Función privada genérica para manejar la consulta y la actualización.
  Future<void> _fetchAndAppendReports({
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      final result = await _controller.getReportsPaginated(
        lastDocument: startAfterDocument,
        // userId: '...', // Añadir aquí si tienes un AuthProvider
        // pageSize: 10,  // Definir tamaño de página
      );

      if (result.data.isNotEmpty) {
        _reports.addAll(result.data);
      }

      // Actualiza el puntero de paginación
      _lastDocument = result.lastDocument;
      _hasMore = result.lastDocument != null;
    } catch (e) {
      debugPrint("Error al obtener informes paginados: $e");
      // Manejo de error
    }
  }

  /// Añade un ReportTransactionModel creado manualmente (desde ReportTransactionCreatePage)
  /// al mapa incrustado del ReportModel y lo persiste.

  //====================================================================
  // CRUD ACCIONES
  //====================================================================

  /// Crea un informe y refresca la lista inicial.
  Future<void> createReportAndUpdate({
    required BuildContext context,
    required ReportModel newReport,
  }) async {
    try {
      // 1. Crear el informe en la base de datos
      await _controller.createReport(context: context, report: newReport);

      // 2. Refrescar la lista para incluir el nuevo informe
      await loadInitialReports();
      // Opcionalmente, podrías solo insertarlo si ya manejaste el ID en el controller.
    } catch (e) {
      debugPrint("Error al crear y actualizar el informe: $e");
      // Manejo de errores de UI si es necesario
    }
  }

  Future<void> addTransactionToReport({
    required BuildContext context,
    required ReportModel report,
    required TransactionModel transactionmodel,
  }) async {
    //1. GENERAR UN NUEVO ID ÚNICO
    // Necesitamos un ID nuevo porque esta es una nueva entrada independiente en Firestore.

    final String newReportTransactionId = _controller
        .getUniqueReportTransactionId();

    // 2. CREAR EL OBJETO ReportTransactionModel INDEPENDIENTE
    final newReportTransaction = ReportTransactionModel.fromTransactionModel(
      reportId: report.reportId,
      transaction: transactionmodel,
      newReportTransactionId: newReportTransactionId, // Usamos el ID nuevo
    );

    // 3. ACTUALIZAR EL MAPA Y EL ReportModel

    // Clonar el mapa existente para mutarlo (buena práctica de inmutabilidad)
    final updatedMap = Map<String, ReportTransactionModel>.from(
      report.reportTransactions,
    );

    // Insertar la nueva transacción en el mapa usando el nuevo ID como clave
    updatedMap[newReportTransactionId] = newReportTransaction;

    // Crear el ReportModel actualizado con el nuevo mapa
    final updatedReport = report.copyWith(reportTransactions: updatedMap);

    try {
      // 4. PERSISTIR EL CAMBIO VÍA EL CONTROLLER
      await _controller.updateReport(
        context: context,
        updatedReport: updatedReport,
      );

      //  5. ACTUALIZAR LA LISTA LOCAL Y NOTIFICAR
      final index = _reports.indexWhere((r) => r.reportId == report.reportId);
      if (index != -1) {
        _reports[index] = updatedReport;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al añadir transacción al informe: $e');
    }
  }

  Future<void> removeTransactionsOfReport({
    required BuildContext context,
    required ReportModel report,
    required List<String> transactionsIds,
  }) async {
    try {
      // 1. Clonar el mapa de transacciones existente para mantener la inmutabilidad
      final updatedMap = Map<String, ReportTransactionModel>.from(
        report.reportTransactions,
      );

      // 2.ELIMINAR las transacciones usando la lista de IDs
      for (final id in transactionsIds) {
        // remove() elimina la entrada con la clave dada. Si la clave no existe, no hace nada.
        updatedMap.remove(id);
      }

      // 3. Crear el ReportModel actualizado (usando copyWith)
      final updatedReport = report.copyWith(reportTransactions: updatedMap);

      // 4. Persistir el cambio vía el Controller (Esto llama a ReportsService.updateReport)
      await _controller.updateReport(
        context: context,
        updatedReport: updatedReport,
      );

      // 5. Actualizar la lista local (_reports) y notificar a la UI
      // Esto asume que _reports es la lista interna de ReportModel que gestiona tu Provider.
      final index = _reports.indexWhere((r) => r.reportId == report.reportId);
      if (index != -1) {
        _reports[index] = updatedReport;
        notifyListeners(); // Notifica a los oyentes (ej., ReportReadPage)
      }
    } catch (e) {
      debugPrint('Error al eliminar transacciones del informe: $e');
      // Opcional: AppUtils.showError(context, 'Fallo al eliminar transacciones del informe.');
      rethrow;
    }
  }

  Future<void> addManualReportTransaction({
    required BuildContext context,
    required ReportModel report,
    required ReportTransactionModel newTransaction,
  }) async {
    try {
      // 1. Clonar el mapa de transacciones existente para mantener la inmutabilidad
      final updatedMap = Map<String, ReportTransactionModel>.from(
        report.reportTransactions,
      );

      // 2. Insertar el objeto completo en el mapa usando su ID como clave
      // Esto es lo que permite que la transacción quede incrustada.
      updatedMap[newTransaction.reportTransactionId] = newTransaction;

      // 3. Crear el ReportModel actualizado
      final updatedReport = report.copyWith(reportTransactions: updatedMap);

      // 4. Persistir el cambio vía el Controller
      // El _controller se encarga de llamar al ReportsService.updateReport(...)
      await _controller.updateReport(
        context: context,
        updatedReport: updatedReport,
      );

      // 5. Actualizar la lista local (_reports) y notificar a la UI
      final index = _reports.indexWhere((r) => r.reportId == report.reportId);
      if (index != -1) {
        _reports[index] = updatedReport;
        notifyListeners();
        // Opcional: AppUtils.showSuccess(context, 'Movimiento manual añadido con éxito.');
      }
    } catch (e) {
      debugPrint('Error al añadir movimiento manual al informe: $e');
      // Opcional: AppUtils.showError(context, 'Fallo al guardar el movimiento en el informe.');
      // Re-lanzar para que la UI pueda manejarlo si es necesario.
      rethrow;
    }
  }

  Future<void> updateReportTransaction({
    required BuildContext context,
    required ReportModel report, // El informe actual
    required ReportTransactionModel
    updatedTransaction, // La transacción con los cambios
  }) async {
    // 1. Clonar el mapa de transacciones existente
    final updatedMap = Map<String, ReportTransactionModel>.from(
      report.reportTransactions,
    );

    // 2. Reemplazar la transacción en el mapa usando su ID como clave
    // Esto sobrescribe la versión antigua con la nueva versión (updatedTransaction)
    if (updatedMap.containsKey(updatedTransaction.reportTransactionId)) {
      updatedMap[updatedTransaction.reportTransactionId] = updatedTransaction;
    } else {
      // Manejar el error si se intenta editar una transacción que no existe
      debugPrint('Error: Transaction ID not found in report map.');
      return;
    }

    // 3. Crear el ReportModel actualizado con el mapa modificado
    final updatedReport = report.copyWith(reportTransactions: updatedMap);

    try {
      // 4. Persistir el cambio vía el Controller
      await _controller.updateReport(
        context: context,
        updatedReport: updatedReport,
      );

      // 5. Actualizar la lista local y notificar
      final index = _reports.indexWhere((r) => r.reportId == report.reportId);
      if (index != -1) {
        _reports[index] = updatedReport;
        notifyListeners();
      }
      // Opcional: AppUtils.showSuccess(context, 'Transacción del informe actualizada.');
    } catch (e) {
      debugPrint('Error al actualizar transacción del informe: $e');
      // Opcional: AppUtils.showError(context, 'Fallo al actualizar la transacción.');
    }
  }

  /// Elimina un informe y actualiza la lista.
  Future<void> deleteReportAndUpdate({
    required BuildContext context,
    required String reportId,
  }) async {
    try {
      // 1. Eliminar del backend
      await _controller.deleteReport(context: context, id: reportId);

      // 2. Eliminar de la lista en memoria
      _reports.removeWhere((r) => r.reportId == reportId);

      notifyListeners();
    } catch (e) {
      debugPrint("Error al eliminar el informe: $e");
    }
  }

  // Elimina múltiples informes
  Future<void> deleteSelectedReportsAndUpdate({
    required BuildContext context,
  }) async {
    if (_reportsSelected.isEmpty) return;

    final List<String> idsToDelete = _reportsSelected.toList();

    try {
      // 1. Llamar al Controller para ejecutar el borrado en la API

      final success = await _controller.deletemultipleReports(
        context: context,
        idsToDelete: idsToDelete,
      );

      if (success) {
        // 2. Si la API tuvo éxito, actualiza la lista local:
        _reports.removeWhere((r) => _reportsSelected.contains(r.reportId));

        // 3. Limpiar la selección
        _reportsSelected.clear();

        // 4. Notificar a la UI
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error al eliminar múltiples informes: $e");
    }
  }
}
