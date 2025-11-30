import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/controllers/reports_controller.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/pages/reports/create/report_create_page.dart';
import 'package:neto_app/pages/reports/read/report_read_page.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/widgets.dart';

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
  late Future<PaginatedReportResult> futureReports;
  //########################################################################
  // CONTROLLERS
  //########################################################################

  ReportsController reportController = ReportsController();

  //########################################################################
  // FUNCIONES
  //########################################################################

  void _refreshAllData() {
    setState(() {
      futureReports = _initLoadReports();
    });
  }

  ///Si el índice es 0, carga gastos; si es 1, carga ingresos.
  Future<PaginatedReportResult> _initLoadReports() async {
    debugPrint('Cargando informes');
    return await reportController.getReportsPaginated();
  }

  //########################################################################
  //ESTADOS WIDGET
  //########################################################################
  @override
  void initState() {
    futureReports = _initLoadReports();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: widget.showAppBar ? TitleAppbar(title: "Informes") : null,
      body: Padding(
        padding: AppDimensions.paddingStandard,
        child: _buildFutureReports(),
      ),
      floatingActionButton: ClipOval(
        child: FloatingActionButton(
          onPressed: () async {
            await showModalBottomSheet(
              backgroundColor: colorScheme.primaryContainer,
              context: context,
              builder: (context) => ReportCreatePage(),
            );

            _refreshAllData();
          },
          backgroundColor: colorScheme.primary,
          child: Icon(Icons.add, color: colorScheme.onPrimary),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  FutureBuilder<PaginatedReportResult> _buildFutureReports() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return FutureBuilder(
      future: futureReports,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final reports = snapshot.data!.data;
          if (reports.isEmpty) {
            return Center(
              child: SizedBox(
                height: 220,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      width: 180,
                      child: Image.asset(
                        'assets/animations/happy_pig.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      'No hay gastos disponibles.',
                      style: textTheme.titleMedium!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            ReportReadPage(reportModel: report),
                      ),
                    );
                  },
                  child: ReportCard(
                    upText: report.name,
                    dateText: AppFormatters.customDateFormatShort(
                      report.dateCreated,
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No hay transacciones disponibles.'));
        }
      },
    );
  }
}
