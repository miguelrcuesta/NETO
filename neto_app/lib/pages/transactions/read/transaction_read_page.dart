import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/controllers/reports_controller.dart';
import 'package:neto_app/controllers/transaction_controller.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/pages/transactions/create/transaction_create_details_page.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/pages/transactions/create/transaction_create_amount_page.dart';
import 'package:neto_app/widgets/app_fields.dart';

class TransactionReadPage extends StatefulWidget {
  final TransactionModel transactionModel;
  const TransactionReadPage({super.key, required this.transactionModel});

  @override
  State<TransactionReadPage> createState() => _TransactionReadPageState();
}

class _TransactionReadPageState extends State<TransactionReadPage> {
  //########################################################################
  // CONTROLLERS
  //########################################################################
  ReportsController reportController = ReportsController();
  TransactionController transactionController = TransactionController();

  //########################################################################
  // VARIABLES
  //########################################################################
  dynamic category;

  //########################################################################
  // FUNCIONES
  //########################################################################
  dynamic getCategory(String id) {
    if (widget.transactionModel.type == TransactionType.expense.id) {
      return Expenses.getCategoryById(id);
    } else {
      return Incomes.getCategoryById(id);
    }
  }

  Future<PaginatedReportResult> _initLoadReports() async {
    debugPrint('Cargando informes');
    return await reportController.getReportsPaginated();
  }

  @override
  void initState() {
    category = getCategory(widget.transactionModel.categoryid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    //AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              Column(
                children: [
                  const SizedBox(height: AppDimensions.spacingMedium),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text(
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      widget.transactionModel.description ?? "-",
                      style: textTheme.titleMedium!.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text(
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      widget.transactionModel.amount.toStringAsFixed(2),
                      style: textTheme.titleLarge!.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    minVerticalPadding: 0.0,
                    visualDensity: VisualDensity.comfortable,
                    //title: Text("Categoría", style: textTheme.titleSmall),
                    leading: ClipRRect(
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: decorationContainer(
                          context: context,
                          colorFilled:
                              category.color.withAlpha(30) ??
                              colorScheme.primary.withAlpha(30),
                          radius: 50,
                        ),
                        child: Icon(
                          category.iconData,
                          size: 20,
                          color: category.color ?? colorScheme.primary,
                        ),
                      ),
                    ),
                    title: Text(
                      widget.transactionModel.category,
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      widget.transactionModel.category.isEmpty
                          ? "-"
                          : widget.transactionModel.subcategory,
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: colorScheme.outline),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    minVerticalPadding: 0.0,
                    visualDensity: VisualDensity.comfortable,
                    //title: Text("Categoría", style: textTheme.titleSmall),
                    title: Text(
                      "Fecha",
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      AppFormatters.customDateFormatShort(
                        widget.transactionModel.date!,
                      ),
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: colorScheme.outline),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    minVerticalPadding: 0.0,
                    visualDensity: VisualDensity.comfortable,
                    //title: Text("Categoría", style: textTheme.titleSmall),
                    title: Text(
                      "Importe",
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      widget.transactionModel.amount.toStringAsFixed(2),
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  //Divider(height: 1, color: colorScheme.outline),
                  const SizedBox(height: 50),
                  GestureDetector(
                    onTap: () {
                      _showAllReports(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: decorationContainer(
                        context: context,
                        colorFilled: colorScheme.primaryContainer,
                        colorBorder: Colors.blue,
                        radius: 10,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0.0,
                        ),
                        minVerticalPadding: 0.0,
                        visualDensity: VisualDensity.comfortable,
                        leading: Icon(
                          Icons.drive_folder_upload_rounded,
                          color: Colors.blue,
                        ),
                        title: Text(
                          "Añadir a un informe",
                          style: textTheme.bodySmall!.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),

              TextButton(
                onPressed: () {
                  debugPrint("Eliminar movimiento");
                },
                child: Text(
                  "Eliminar movimiento",
                  style: textTheme.bodyMedium!.copyWith(color: Colors.red),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showAllReports(BuildContext context) {
    //AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    Future<PaginatedReportResult> futureReports = _initLoadReports();

    return showCupertinoModalPopup(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, myState) {
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                leading: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    transactionController.transactionsSelected.clear();
                  },
                  child: Text(
                    "Atrás",
                    style: textTheme.bodySmall!.copyWith(color: Colors.blue),
                  ),
                ),
                trailing: reportController.reportsSelected.isNotEmpty
                    ? TextButton(
                        onPressed: () async {
                          await reportController
                              .addMultipleTransactionsToReport(
                                context: context,
                                transactionsIds: [
                                  widget.transactionModel.transactionId!,
                                ],
                              );
                          if (!context.mounted) return;
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).popUntil((route) => route.isFirst);
                        },
                        child: Text(
                          "Añadir",
                          style: textTheme.bodySmall!.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                      )
                    : null,
              ),
              child: FutureBuilder(
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
                    return ListView.separated(
                      separatorBuilder: (context, index) {
                        return Divider(color: colorScheme.outline);
                      },
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        bool reportsSelected = reportController
                            .reportAlreadySelected(report.reportId);

                        return CupertinoListTile(
                          leading: Icon(
                            Icons.folder,

                            color: colorScheme.onSurfaceVariant,
                          ),
                          title: Text(
                            report.name,
                            style: textTheme.titleSmall!.copyWith(
                              color: colorScheme.onSurface,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            AppFormatters.customDateFormatShort(
                              report.dateCreated,
                            ),
                            style: textTheme.bodySmall!.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              reportController.selectReportAction(report);

                              myState(() {
                                reportsSelected = !reportsSelected;
                              });
                            },
                            icon: reportsSelected
                                ? Icon(Icons.check_circle, color: Colors.blue)
                                : Icon(Icons.circle),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('No hay transacciones disponibles.'),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
