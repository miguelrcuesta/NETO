import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🔑 Importar Provider
import 'package:neto_app/provider/reports_provider.dart'; // 🔑 Nuevo Provider
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/controllers/reports_controller.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/pages/reports/create/report_create_page.dart';
import 'package:neto_app/pages/reports/read/report_read_page.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para DocumentSnapshot

// ⚠️ PLACEHOLDER (Necesario para evitar errores si no está definido globalmente)
class PaginatedReportResult {
  final List<ReportModel> data;
  final DocumentSnapshot? lastDocument;

  PaginatedReportResult({required this.data, this.lastDocument});
}
// FIN PLACEHOLDER

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
  //########################################################################
  // CONTROLLERS
  //########################################################################
  // Se mantiene para interactuar con la API (llamadas por el Provider)
  ReportsController reportController = ReportsController();

  //########################################################################
  // FUNCIONES
  //########################################################################

  // 🔑 Llama a clearSelection() en el Provider para limpiar la selección
  void _updateNotSelectableUI() {
    context.read<ReportsProvider>().clearSelection();
  }

  //########################################################################
  //ESTADOS WIDGET
  //########################################################################
  @override
  void initState() {
    super.initState();
    // 🔑 Iniciar la carga de informes al inicio usando el Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsProvider>().loadInitialReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      // 🔑 AppBar reactivo (usa context.watch)
      appBar: _buildReactiveAppBar(context),
      body: Padding(
        padding: AppDimensions.paddingStandard,
        child: _buildReportsView(context), // 🔑 Vista reactiva (usa Consumer)
      ),
      floatingActionButton: ClipOval(
        child: FloatingActionButton(
          onPressed: () async {
            // Aseguramos que el multiselect está desactivado
            context.read<ReportsProvider>().clearSelection();

            await showModalBottomSheet(
              backgroundColor: colorScheme.primaryContainer,
              context: context,
              builder: (context) => ReportCreatePage(),
            );
            if (!context.mounted) return;
            // 🔑 Tras cerrar el modal (si se creó algo), refrescamos la lista
            context.read<ReportsProvider>().loadInitialReports();
          },
          backgroundColor: colorScheme.primary,
          child: Icon(Icons.add, color: colorScheme.onPrimary),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  // 🔑 Método para construir el AppBar de forma reactiva (usa context.watch)
  PreferredSizeWidget? _buildReactiveAppBar(BuildContext context) {
    if (!widget.showAppBar) return null;

    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    // 🔑 context.watch fuerza la reconstrucción de este método (y por ende del AppBar)
    final provider = context.watch<ReportsProvider>();

    final isMultiselectActive = provider.isMultiselectActive;
    final isItemSelected = provider.reportsSelected.isNotEmpty;

    if (isMultiselectActive) {
      // AppBar de selección
      return AppBar(
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          onPressed: _updateNotSelectableUI, // Limpia la selección
          icon: Icon(Icons.close, color: colorScheme.primary),
        ),
        title: Text(
          '${provider.reportsSelected.length} seleccionados',
          style: textTheme.titleMedium,
        ),
        actions: [
          if (isItemSelected)
            IconButton(
              onPressed: () async {
                // 🔑 Llama al Provider para borrar
                await provider.deleteSelectedReportsAndUpdate(context: context);
              },
              icon: Icon(Icons.delete, color: colorScheme.primary, size: 20),
            ),
        ],
      );
    } else {
      return TitleAppbar(
        title: "Informes",
        color: colorScheme.primaryContainer,
      );
    }
  }

  // 🔑 Método de visualización de informes (reemplaza _buildFutureReports)
  Widget _buildReportsView(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    // 🔑 Usamos Consumer para escuchar los cambios en el Provider y reconstruir solo la lista
    return Consumer<ReportsProvider>(
      builder: (context, provider, child) {
        final reports = provider.reports;
        final isMultiselectActive = provider.isMultiselectActive;

        // 1. Estado de Carga Inicial
        if (provider.isLoadingInitial && reports.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Estado Vacío
        if (reports.isEmpty && !provider.isLoadingInitial) {
          return Center(
            child: SizedBox(
              height: 220,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder,
                    color: colorScheme.onSurfaceVariant,
                    size: 100,
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    'No hay informes disponibles.',
                    style: textTheme.titleMedium!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 3. Implementación del Scroll Infinito y RefreshIndicator
        return RefreshIndicator(
          onRefresh: provider.loadInitialReports,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent * 0.9 &&
                  !provider.isLoadingMore &&
                  provider.hasMore) {
                provider.loadMoreReports();
              }
              return false;
            },
            child: ListView.builder(
              // Sumamos 1 para el indicador de carga
              itemCount: reports.length + (provider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Indicador de "Cargando Más" al final
                if (index == reports.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                }

                final report = reports[index];

                // 🔑 Usamos el Set del Provider para saber si está seleccionado
                bool isSelected = provider.reportsSelected.contains(
                  report.reportId,
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: GestureDetector(
                    onLongPress: () {
                      // 🔑 Inicia el modo multiselección y selecciona el elemento
                      provider.toggleReportSelection(report);
                    },
                    onTap: () {
                      // 🔑 Si está activo, selecciona/deselecciona. Si no, navega.
                      if (isMultiselectActive) {
                        provider.toggleReportSelection(report);
                      } else {
                        // Navigator.push<void>(
                        //   context,
                        //   MaterialPageRoute<void>(
                        //     builder: (BuildContext context) =>
                        //         ReportReadPage(reportModel: report),
                        //   ),
                        // );
                      }
                    },
                    child: ReportCard(
                      upText: report.name,
                      dateText: AppFormatters.customDateFormatShort(
                        report.dateCreated,
                      ),
                      isSelected: isSelected, // 🔑 PROPIEDAD REQUERIDA
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
