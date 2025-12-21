import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/controllers/reports_controller.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';

// =========================================================
// MODELOS DE APOYO
// =========================================================

class ReportSummaryData {
  final List<double> monthlyIncomes;
  final List<double> monthlyExpenses;
  final Map<String, Map<String, double>> categoryGroupedData;
  final Map<String, String> categoryTypes;

  ReportSummaryData({
    required this.monthlyIncomes,
    required this.monthlyExpenses,
    required this.categoryGroupedData,
    required this.categoryTypes,
  });
}

class PaginatedReportResult {
  final List<ReportModel> data;
  final DocumentSnapshot? lastDocument;

  PaginatedReportResult({required this.data, this.lastDocument});
}

// =========================================================
// PROVIDER PRINCIPAL
// =========================================================

class ReportsProvider extends ChangeNotifier {
  final ReportsController _controller;

  ReportsProvider() : _controller = ReportsController();

  // ---------------------------------------------------------
  // ESTADO CENTRAL
  // ---------------------------------------------------------
  List<ReportModel> _reports = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  final Set<String> _reportsSelected = {};

  // ---------------------------------------------------------
  // GETTERS
  // ---------------------------------------------------------
  List<ReportModel> get reports => _reports;
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  Set<String> get reportsSelected => _reportsSelected;
  bool get isMultiselectActive => _reportsSelected.isNotEmpty;

  // =========================================================
  // 📊 LÓGICA DE NEGOCIO Y RESUMEN
  // =========================================================

  /// Obtiene las transacciones de un informe ordenadas por fecha descendente.
  List<TransactionModel> getSortedTransactions(String reportId) {
    final report = getReportById(reportId);
    return report.reportTransactions.values.toList()
      ..sort((a, b) => b.date!.compareTo(a.date!));
  }

  /// Procesa los datos del informe para generar el desglose y el gráfico.
  ReportSummaryData getReportSummary(String reportId) {
    final transactions = getSortedTransactions(reportId);

    List<double> monthlyIncomes = List.filled(12, 0.0);
    List<double> monthlyExpenses = List.filled(12, 0.0);
    Map<String, Map<String, double>> grouped = {};
    Map<String, String> types = {};

    for (var t in transactions) {
      // 1. Datos para el gráfico por meses
      if (t.date != null) {
        int monthIdx = t.date!.month - 1;
        if (t.type == TransactionType.income.id) {
          monthlyIncomes[monthIdx] += t.amount;
        } else {
          monthlyExpenses[monthIdx] += t.amount;
        }
      }

      // 2. Agrupación por Categoría e ID de Subcategoría
      String catId = t.categoryid;
      String subCatName = t.subcategory;

      types[catId] = t.type;

      if (!grouped.containsKey(catId)) {
        grouped[catId] = {};
      }
      grouped[catId]![subCatName] =
          (grouped[catId]![subCatName] ?? 0) + t.amount;
    }

    return ReportSummaryData(
      monthlyIncomes: monthlyIncomes,
      monthlyExpenses: monthlyExpenses,
      categoryGroupedData: grouped,
      categoryTypes: types,
    );
  }

  // =========================================================
  // 🔑 LÓGICA DE SELECCIÓN
  // =========================================================

  void toggleReportSelection(ReportModel report) {
    final id = report.reportId;
    if (_reportsSelected.contains(id)) {
      _reportsSelected.remove(id);
    } else {
      _reportsSelected.add(id!);
    }
    notifyListeners();
  }

  void clearSelection() {
    _reportsSelected.clear();
    notifyListeners();
  }

  // =========================================================
  // ☁️ FIREBASE / PAGINACIÓN
  // =========================================================

  ReportModel getReportById(String reportId) {
    try {
      return _reports.firstWhere((report) => report.reportId == reportId);
    } catch (e) {
      debugPrint('Error: Reporte con ID $reportId no encontrado. $e');
      return ReportModel.empty();
    }
  }

  Future<void> loadInitialReports() async {
    if (_isLoadingInitial) return;
    _isLoadingInitial = true;
    _reports = [];
    _lastDocument = null;
    _hasMore = true;
    notifyListeners();

    await _fetchAndAppendReports(startAfterDocument: null);
    _isLoadingInitial = false;
    notifyListeners();
  }

  Future<void> loadMoreReports() async {
    if (!_hasMore || _isLoadingMore || _lastDocument == null) return;
    _isLoadingMore = true;
    notifyListeners();

    await _fetchAndAppendReports(startAfterDocument: _lastDocument);
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> _fetchAndAppendReports({
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      final result = await _controller.getReportsPaginated(
        lastDocument: startAfterDocument,
      );
      if (result.data.isNotEmpty) {
        _reports.addAll(result.data);
      }
      _lastDocument = result.lastDocument;
      _hasMore = result.lastDocument != null;
    } catch (e) {
      debugPrint("Error al obtener informes paginados: $e");
    }
  }

  // =========================================================
  // 🛠️ ACCIONES CRUD
  // =========================================================

  Future<void> createReportAndUpdate({
    required BuildContext context,
    required ReportModel newReport,
  }) async {
    try {
      await _controller.createReport(context: context, report: newReport);
      await loadInitialReports();
    } catch (e) {
      debugPrint("Error al crear y actualizar: $e");
    }
  }

  Future<void> addTransactionToReport({
    required BuildContext context,
    required ReportModel report,
    required TransactionModel transactionmodel,
  }) async {
    final String newId = _controller.getUniqueReportTransactionId();
    final newReportTransaction = transactionmodel.copyWith(
      transactionId: newId,
    );
    final updatedMap = Map<String, TransactionModel>.from(
      report.reportTransactions,
    );
    updatedMap[newId] = newReportTransaction;

    final updatedReport = report.copyWith(reportTransactions: updatedMap);

    try {
      await _controller.updateReport(
        context: context,
        updatedReport: updatedReport,
      );
      _updateLocalReport(updatedReport);
    } catch (e) {
      debugPrint('Error al añadir transacción: $e');
    }
  }

  Future<void> removeTransactionsOfReport({
    required BuildContext context,
    required ReportModel report,
    required List<String> transactionsIds,
  }) async {
    try {
      final updatedMap = Map<String, TransactionModel>.from(
        report.reportTransactions,
      );
      for (final id in transactionsIds) {
        updatedMap.remove(id);
      }
      final updatedReport = report.copyWith(reportTransactions: updatedMap);
      await _controller.updateReport(
        context: context,
        updatedReport: updatedReport,
      );
      _updateLocalReport(updatedReport);
    } catch (e) {
      debugPrint('Error al eliminar transacciones: $e');
      rethrow;
    }
  }

  Future<void> addManualReportTransaction({
    required BuildContext context,
    required ReportModel report,
    required TransactionModel newTransaction,
  }) async {
    try {
      final updatedMap = Map<String, TransactionModel>.from(
        report.reportTransactions,
      );
      updatedMap[newTransaction.transactionId!] = newTransaction;
      final updatedReport = report.copyWith(reportTransactions: updatedMap);

      await _controller.updateReport(
        context: context,
        updatedReport: updatedReport,
      );
      _updateLocalReport(updatedReport);
    } catch (e) {
      debugPrint('Error al añadir movimiento manual: $e');
      rethrow;
    }
  }

  Future<void> updateReportTransaction({
    required BuildContext context,
    required ReportModel report,
    required TransactionModel updatedTransaction,
  }) async {
    final updatedMap = Map<String, TransactionModel>.from(
      report.reportTransactions,
    );
    if (updatedMap.containsKey(updatedTransaction.transactionId)) {
      updatedMap[updatedTransaction.transactionId!] = updatedTransaction;
    } else {
      return;
    }

    final updatedReport = report.copyWith(reportTransactions: updatedMap);
    try {
      await _controller.updateReport(
        context: context,
        updatedReport: updatedReport,
      );
      _updateLocalReport(updatedReport);
    } catch (e) {
      debugPrint('Error al actualizar transacción: $e');
    }
  }

  Future<void> deleteReportAndUpdate({
    required BuildContext context,
    required String reportId,
  }) async {
    try {
      await _controller.deleteReport(context: context, id: reportId);
      _reports.removeWhere((r) => r.reportId == reportId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error al eliminar el informe: $e");
    }
  }

  Future<void> deleteSelectedReportsAndUpdate({
    required BuildContext context,
  }) async {
    if (_reportsSelected.isEmpty) return;
    final idsToDelete = _reportsSelected.toList();

    try {
      final success = await _controller.deletemultipleReports(
        context: context,
        idsToDelete: idsToDelete,
      );
      if (success) {
        _reports.removeWhere((r) => _reportsSelected.contains(r.reportId));
        _reportsSelected.clear();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error al eliminar múltiples informes: $e");
    }
  }

  // ---------------------------------------------------------
  // MÉTODOS PRIVADOS DE APOYO
  // ---------------------------------------------------------

  /// Actualiza un reporte específico en la lista local y notifica a la UI.
  void _updateLocalReport(ReportModel updatedReport) {
    final index = _reports.indexWhere(
      (r) => r.reportId == updatedReport.reportId,
    );
    if (index != -1) {
      _reports[index] = updatedReport;
      notifyListeners();
    }
  }
}
