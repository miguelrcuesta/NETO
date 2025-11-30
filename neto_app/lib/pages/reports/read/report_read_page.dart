import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/controllers/reports_controller.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/app_fields.dart';

class ReportReadPage extends StatefulWidget {
  final ReportModel reportModel;
  const ReportReadPage({super.key, required this.reportModel});

  @override
  State<ReportReadPage> createState() => _ReportReadPageState();
}

class _ReportReadPageState extends State<ReportReadPage>
    with SingleTickerProviderStateMixin {
  //########################################################################
  // VARIABLES
  //########################################################################
  ReportModel reportModel = ReportModel(
    reportId: 'reportId',
    userId: 'userId',
    name: 'Evolución de mis nóminas',
    dateCreated: DateTime.now(),
    listIdTransactions: [],
  );

  late Future<List<TransactionModel>> futureTransactions;
  //########################################################################
  // CONTROLLERS
  //########################################################################

  late final TabController _tabController;
  final ReportsController reportsController = ReportsController();

  //########################################################################
  // FUNCIONES
  //########################################################################

  Future<List<TransactionModel>> _initLoadReportTransactions(
    String idReport,
  ) async {
    debugPrint('Cargando movimientos del reporte');
    return await reportsController.loadAllTransactionsForReport(
      context: context,
      reportId: idReport,
    );
  }

  //########################################################################
  //ESTADOS WIDGET
  //########################################################################
  @override
  void initState() {
    super.initState();
    reportModel = widget.reportModel;
    _tabController = TabController(length: 2, vsync: this);
    futureTransactions = _initLoadReportTransactions(
      widget.reportModel.reportId,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    //Ejemplo de informe

    List<Map<String, dynamic>> mapaDeEjemplo = [
      {
        'Fecha': 'Octubre 2025',
        'Descripción': 'A',
        'Importe': 2000,
        'Categoria': 'SALARIO',
      },
      {
        'Fecha': 'Septiembre 2025',
        'Descripción': 'A',
        'Importe': 2000,
        'Categoria': 'SALARIO',
      },
      {
        'Fecha': 'Agosto 2025',
        'Descripción': 'A',
        'Importe': 2000,
        'Categoria': 'SALARIO',
      },
      {
        'Fecha': 'Junio 2025',
        'Descripción': 'A',
        'Importe': 2000,
        'Categoria': 'SALARIO',
      },
      {
        'Fecha': 'Julio 2025',
        'Descripción': 'A',
        'Importe': 2000,
        'Categoria': 'SALARIO',
      },
      {
        'Fecha': 'Mayo 2025',
        'Descripción': 'A',
        'Importe': 2000,
        'Categoria': 'SALARIO',
      },
      {
        'Fecha': 'Abril 2025',
        'Descripción': 'A',
        'Importe': 2000,
        'Categoria': 'SALARIO',
      },
      {
        'Fecha': 'Marzo 2025',
        'Descripción': 'A',
        'Importe': 2000,
        'Categoria': 'SALARIO',
      },
    ];

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: colorScheme.primaryContainer,
        title: Text(reportModel.name, style: textTheme.titleSmall),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 50),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'Movimientos'),
              Tab(text: 'Estadísticas'),
            ],
          ),
        ),
      ),
      body: FutureBuilder(
        future: futureTransactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<TransactionModel> transactions = snapshot.data!;
            if (transactions.isEmpty) {
              return Center(
                child: SizedBox(
                  height: 220,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // SizedBox(
                      //   height: 150,
                      //   width: 240,
                      //   child: Image.asset(
                      //     'assets/animations/folder.png',
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                      Icon(
                        Icons.folder,
                        color: colorScheme.onSurfaceVariant,
                        size: 100,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        'No hay movimientos disponibles.',
                        style: textTheme.titleMedium!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 10.0,
              ),
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return Divider(color: colorScheme.outline);
                },
                shrinkWrap: true,
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  dynamic getCategory(String id) {
                    if (transactions[index].type ==
                        TransactionType.expense.id) {
                      return Expenses.getCategoryById(id);
                    } else {
                      return Incomes.getCategoryById(id);
                    }
                  }

                  final category = getCategory(transactions[index].categoryid);
                  return CupertinoListTile(
                    padding: EdgeInsets.only(left: 10, right: 40),
                    leading: ClipRRect(
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: decorationContainer(
                          context: context,
                          colorFilled:
                              category.color.withAlpha(30) ??
                              colorScheme.primary.withAlpha(30),
                          radius: 100,
                        ),
                        child: Icon(
                          category.iconData,
                          size: 15,
                          color:
                              category?.color ??
                              colorScheme.primary.withAlpha(30),
                        ),
                      ),
                    ),

                    title: Text(
                      transactions[index].description ?? category.nombre,
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    subtitle: Text(
                      AppFormatters.customDateFormatShort(
                        transactions[index].date!,
                      ),
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    // subtitle: Text(
                    //   category.nombre,
                    //   style: textTheme.bodyMedium!.copyWith(
                    //     color: colorScheme.onSurfaceVariant,
                    //   ),
                    // ),
                    trailing: Text(
                      transactions[index].amount.toStringAsFixed(2),
                      style: textTheme.bodyMedium,
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: Text('No hay transacciones disponibles.'),
            );
          }
        },
      ),
    );
  }
}
