import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/controllers/reports_controller.dart';
import 'package:neto_app/controllers/transaction_controller.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/pages/reports/read/reports_read_page.dart';
import 'package:neto_app/pages/transactions/create/transaction_create_amount_page.dart';
import 'package:neto_app/pages/transactions/read/transaction_read_page.dart';
import 'package:neto_app/widgets/widgets.dart';

class TransactionsReadPage extends StatefulWidget {
  final TransactionModel? transactionModel;
  const TransactionsReadPage({super.key, this.transactionModel});

  @override
  State<TransactionsReadPage> createState() => _TransactionsReadPageState();
}

class _TransactionsReadPageState extends State<TransactionsReadPage>
    with TickerProviderStateMixin {
  //########################################################################
  // VARIABLES
  //########################################################################

  bool isMultiselectAviable = false;
  bool isItemSelected = false;
  bool isReportSelected = false;
  final List selectedItems = [];
  final List selectedReports = [];

  late Future<PaginatedTransactionResult> expensesFuture;
  late Future<PaginatedTransactionResult> incomesFuture;

  //########################################################################
  // CONTROLLERS
  //########################################################################

  late final TabController _tabController;
  TransactionController transactionController = TransactionController();
  ReportsController reportController = ReportsController();

  //########################################################################
  // FUNCIONES
  //########################################################################

  Future<PaginatedReportResult> _initLoadReports() async {
    debugPrint('Cargando informes');
    return await reportController.getReportsPaginated();
  }

  void _updateNotSelectableUI() {
    setState(() {
      isMultiselectAviable = false;
      isItemSelected = false;
      transactionController.transactionsSelected.clear();
    });
  }

  void _updateSelectableUI() {
    setState(() {
      isMultiselectAviable = true;
      transactionController.transactionsSelected.clear();
    });
  }

  ///Si el índice es 0, carga gastos; si es 1, carga ingresos.
  Future<PaginatedTransactionResult> _initLoadTransactions(int index) async {
    debugPrint('Cargando transacciones para el índice: $index');
    if (index == 0) {
      return await transactionController.getTransactionsPaginated(
        type: TransactionType.expense.id,
      );
    } else {
      return await transactionController.getTransactionsPaginated(
        type: TransactionType.income.id,
      );
    }
  }

  void _refreshAllData(int index) {
    //Si es cero solo refresca los gastos para optimizar las llamadas
    if (index == 0) {
      setState(() {
        expensesFuture = _initLoadTransactions(0);
      });
    }
    //Si es uno refresca solo los ingresos para optimizar las llamadas
    if (index == 1) {
      setState(() {
        incomesFuture = _initLoadTransactions(1);
      });
    }
  }

  //########################################################################
  //ESTADOS WIDGET
  //########################################################################
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    expensesFuture = _initLoadTransactions(0);
    incomesFuture = _initLoadTransactions(1);
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
    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,

      appBar: _selectedAviableAppbar(context),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: TabBarView(
          controller: _tabController,
          children: [_buildFutureTransactions(0), _buildFutureTransactions(1)],
        ),
      ),
      floatingActionButton: ClipOval(
        child: FloatingActionButton(
          heroTag: 'transactions_read_fab',
          onPressed: () async {
            await showCupertinoModalPopup(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    leading: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Atrás",
                        style: textTheme.bodySmall!.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  child: TransactionAmountCreatePage(
                    transactionModel: widget.transactionModel,
                    isEditable: false,
                  ),
                );
              },
            );

            _refreshAllData(_tabController.index);
          },
          backgroundColor: colorScheme.primary,
          child: Icon(Icons.add, color: colorScheme.onPrimary),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  AppBar _selectedAviableAppbar(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    if (isMultiselectAviable == true) {
      return AppBar(
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          onPressed: () {
            setState(() {
              //Actualizamos la UI y luego limpiamos la lista;
              _updateNotSelectableUI();
            });
          },
          icon: Icon(CupertinoIcons.xmark, color: colorScheme.primary),
        ),

        actions: [
          if (transactionController.transactionsSelected.isNotEmpty)
            IconButton(
              onPressed: () async {
                await transactionController.deletemultipleTransactions(
                  context: context,
                );
                _updateNotSelectableUI();
                _refreshAllData(_tabController.index);
              },
              icon: Icon(
                CupertinoIcons.delete,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
          if (transactionController.transactionsSelected.isNotEmpty)
            IconButton(
              onPressed: () async {
                //_showfolders...
                _showAllReports(context);
              },
              icon: Icon(
                Icons.folder_copy_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
        ],
      );
    } else {
      return AppBar(
        backgroundColor: colorScheme.primaryContainer,
        title: Text("Movimientos", style: textTheme.titleSmall),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 50),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: appLocalizations.typeExpense),
              Tab(text: appLocalizations.typeIncome),
            ],
          ),
        ),
      );
    }
  }

  FutureBuilder<PaginatedTransactionResult> _buildFutureTransactions(
    int index,
  ) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    Future<PaginatedTransactionResult> future = index == 0
        ? expensesFuture
        : incomesFuture;
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final transactions = snapshot.data!.data;
          if (transactions.isEmpty) {
            return Center(
              child: SizedBox(
                height: 220,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      width: 180,
                      child: Image.asset(
                        'assets/animations/sad_pig.png',
                        fit: BoxFit.cover,
                      ),
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
          return ListView.builder(
            //shrinkWrap: true,
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              bool transactionsSelected = transactionController
                  .transactionsSelected
                  .contains(transaction.transactionId);
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 6.0,
                ),
                child: InkWell(
                  onLongPress: () {
                    setState(() {
                      _updateSelectableUI();
                    });
                  },

                  onTap: () {
                    /// Si el multiselect esta activado, activamos el selector y añadimos a la lista si no
                    /// abrimos el movimiento para ver el detalle.
                    if (isMultiselectAviable) {
                      transactionController.selectTransactionAction(
                        transaction,
                      );
                    } else {
                      _showTransaction(context, textTheme, transaction);
                    }

                    setState(() {
                      transactionsSelected = !transactionsSelected;
                    });
                  },

                  child: TransactionCardSmall(
                    isSelected: transactionsSelected,
                    idCategory: transaction.categoryid,
                    type: transaction.type,
                    title: transaction.description ?? 'Sin categoría',
                    subtitle: AppFormatters.customDateFormatShort(
                      transaction.date ?? DateTime.now(),
                    ),
                    amount: transaction.amount.toStringAsFixed(2),
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

  void _showTransaction(
    BuildContext context,
    TextTheme textTheme,
    TransactionModel transaction,
  ) {
    showCupertinoModalPopup(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Atrás",
                style: textTheme.bodySmall!.copyWith(color: Colors.blue),
              ),
            ),
            trailing: TextButton(
              onPressed: () async {
                await showCupertinoModalPopup(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return CupertinoPageScaffold(
                      navigationBar: CupertinoNavigationBar(
                        leading: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Atrás",
                            style: textTheme.bodySmall!.copyWith(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      child: TransactionAmountCreatePage(
                        transactionModel: transaction,
                        isEditable: true,
                      ),
                    );
                  },
                );
                _refreshAllData(_tabController.index);
              },

              child: Text(
                "Editar",
                style: textTheme.bodySmall!.copyWith(color: Colors.blue),
              ),
            ),
          ),
          child: TransactionReadPage(transactionModel: transaction),
        );
      },
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
                                transactionsIds:
                                    transactionController.transactionsSelected,
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
