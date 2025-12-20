import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/pages/reports/create/report_create_page.dart';
import 'package:neto_app/pages/reports/read/report_read_page.dart';
import 'package:neto_app/provider/reports_provider.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/app_empty_states.dart';
import 'package:neto_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ReportsReadPage extends StatefulWidget {
  final bool showAppBar;
  final ReportModel? reportModel;
  const ReportsReadPage({
    super.key,
    this.reportModel,
    required this.showAppBar,
  });

  @override
  State<ReportsReadPage> createState() => _ReportsReadPageState();
}

class _ReportsReadPageState extends State<ReportsReadPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Carga inicial de datos mediante el Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReportsProvider>().loadInitialReports();
      }
    });
  }

  //====================================================================
  // UI PRINCIPAL
  //====================================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Escuchamos el estado global para decidir si mostrar el FAB
    final provider = context.watch<ReportsProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildReactiveAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _buildReportsView(context),
      ),

      floatingActionButton:
          (!provider.isMultiselectActive && provider.reports.isNotEmpty)
          ? ClipOval(
              child: FloatingActionButton(
                heroTag: null, // 👈 Solución al error de Tags duplicados
                onPressed: () => _openCreateReport(context, colorScheme),
                backgroundColor: colorScheme.primary,
                child: Icon(Icons.add, color: colorScheme.onPrimary),
              ),
            )
          : null,
    );
  }

  //====================================================================
  // COMPONENTES DE LA INTERFAZ
  //====================================================================

  PreferredSizeWidget? _buildReactiveAppBar(BuildContext context) {
    if (!widget.showAppBar) return null;

    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<ReportsProvider>();

    // AppBar dinámico según el modo de selección
    if (provider.isMultiselectActive) {
      return TitleAppbar(
        leading: IconButton(
          onPressed: () => provider.clearSelection(),
          icon: Icon(Icons.close, color: colorScheme.primary),
        ),
        title: '${provider.reportsSelected.length} seleccionados',
        actions: [
          if (provider.reportsSelected.isNotEmpty)
            IconButton(
              onPressed: () =>
                  provider.deleteSelectedReportsAndUpdate(context: context),
              icon: Icon(Icons.delete, color: colorScheme.primary),
            ),
        ],
      );
    }

    return TitleAppbar(title: "Informes", color: colorScheme.surface);
  }

  Widget _buildReportsView(BuildContext context) {
    return Consumer<ReportsProvider>(
      builder: (context, provider, child) {
        final reports = provider.reports;

        if (provider.isLoadingInitial && reports.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (reports.isEmpty) {
          return Center(
            child: AppEmptyStates(
              asset: 'assets/animations/report_empty.svg',
              upText: 'No hay informes creados',
              downText: 'Crea informes para organizar tus movimientos.',
              btnText: 'Crear informe',
              onPressed: () =>
                  _openCreateReport(context, Theme.of(context).colorScheme),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadInitialReports,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: reports.length + (provider.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == reports.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final report = reports[index];
              final isSelected = provider.reportsSelected.contains(
                report.reportId,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: GestureDetector(
                  onLongPress: () => provider.toggleReportSelection(report),
                  onTap: () {
                    if (provider.isMultiselectActive) {
                      provider.toggleReportSelection(report);
                    } else {
                      _navigateToReport(context, report);
                    }
                  },
                  child: ReportCard(
                    emoji: report.emoji,
                    upText: report.name,
                    dateText: AppFormatters.customDateFormatShort(
                      report.dateCreated,
                    ),
                    isSelected: isSelected,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  //====================================================================
  // NAVEGACIÓN Y MODALES
  //====================================================================

  void _navigateToReport(BuildContext context, ReportModel report) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReportReadPage(reportModel: report)),
    );
  }

  Future<void> _openCreateReport(
    BuildContext context,
    ColorScheme color,
  ) async {
    context.read<ReportsProvider>().clearSelection();
    await showModalBottomSheet(
      context: context,
      //isScrollControlled: true,
      backgroundColor: color.primaryContainer,
      builder: (context) => const ReportCreatePage(),
    );
  }
}
