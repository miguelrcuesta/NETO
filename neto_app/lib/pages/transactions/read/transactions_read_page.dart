import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/controllers/transaction_controller.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/models/transaction_model.dart';
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
    with SingleTickerProviderStateMixin {
  //########################################################################
  // CONTROLLERS
  //########################################################################

  late final TabController _tabController;

  TransactionController transactionController = TransactionController();

  //########################################################################
  // FUNCIONES
  //########################################################################

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

  //########################################################################
  //ESTADOS WIDGET
  //########################################################################
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
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
      ),
      body: Padding(
        padding: AppDimensions.paddingStandard,
        //child: _buildFutureExpenses(),
        child: TabBarView(
          controller: _tabController,
          children: [_buildFutureExpenses(), _buildFutureIncomes()],
        ),
      ),
      floatingActionButton: ClipOval(
        child: FloatingActionButton(
          heroTag: 'transactions_read_fab',
          onPressed: () async {
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) =>
                    const TransactionAmountCreatePage(),
              ),
            );

            if (mounted) setState(() {});
          },
          backgroundColor: colorScheme.primary,
          child: Icon(Icons.add, color: colorScheme.onPrimary),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  FutureBuilder<PaginatedTransactionResult> _buildFutureIncomes() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return FutureBuilder(
      future: _initLoadTransactions(1),
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
                      'No hay ingresos disponibles.',
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
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0,
                ),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            color: colorScheme.surface,
                            child: TransactionReadPage(
                              transactionModel: transaction,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: TransactionCard(
                    containerEnabled: true,
                    idCategory: transaction.categoryid,
                    type: transaction.type,
                    title:
                        transaction.description ??
                        Incomes.getCategoryById(
                          transaction.categoryid,
                        )?.nombre ??
                        'Sin categoría',
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

  FutureBuilder<PaginatedTransactionResult> _buildFutureExpenses() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return FutureBuilder(
      future: _initLoadTransactions(0),
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
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0,
                ),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Container(
                            padding: AppDimensions.paddingAllMedium,
                            color: colorScheme.surface,
                            child: TransactionReadPage(
                              transactionModel: transaction,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: TransactionCard(
                    containerEnabled: true,
                    idCategory: transaction.categoryid,
                    type: transaction.type,
                    title:
                        transaction.description ??
                        Expenses.getCategoryById(
                          transaction.categoryid,
                        )?.nombre ??
                        'Sin categoría',
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
}
