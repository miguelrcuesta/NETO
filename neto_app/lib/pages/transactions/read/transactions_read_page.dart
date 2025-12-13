import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:neto_app/provider/transaction_provider.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart'; // Asumiendo que AppFormatters y AppDimensions están aquí
import 'package:neto_app/controllers/reports_controller.dart';
import 'package:neto_app/controllers/transaction_controller.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/pages/transactions/create/transaction_create_amount_page.dart';
import 'package:neto_app/pages/transactions/read/transaction_read_page.dart';
import 'package:neto_app/widgets/widgets.dart'; // Asumiendo que TransactionCardSmall está aquí

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
  //Eliminadas: isMultiselectAviable, selectedItems (Ahora gestionadas por TransactionsProvider)
  final List selectedReports = []; // Se mantiene si es estado local

  //########################################################################
  // CONTROLLERS
  //########################################################################
  late final TabController _tabController;
  // Se mantienen para interactuar con la API/Servicios, llamados por el Provider
  TransactionController transactionController = TransactionController();
  ReportsController reportController = ReportsController();

  //########################################################################
  // FUNCIONES
  //########################################################################

  //Limpia la selección en el Provider
  void _updateNotSelectableUI() {
    context.read<TransactionsProvider>().clearSelection();
  }

  // No necesitamos _updateSelectableUI ya que el onLongPress lo inicia implícitamente

  //########################################################################
  // ESTADOS WIDGET
  //########################################################################
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Iniciar la carga de transacciones al inicio usando el Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsProvider>().loadInitialTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: _selectedAviableAppbar(context), // AppBar ya es reactivo
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTransactionsView(context, TransactionType.expense.id),
            _buildTransactionsView(context, TransactionType.income.id),
          ],
        ),
      ),
      floatingActionButton: ClipOval(
        child: FloatingActionButton(
          heroTag: 'transactions_read_fab',
          onPressed: () async {
            _updateNotSelectableUI(); // Aseguramos que el multiselect está desactivado

            await showCupertinoModalPopup(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                //BOTON DE CREAR
                return CupertinoPageScaffold(
                  backgroundColor: colorScheme.surface,
                  navigationBar: CupertinoNavigationBar(
                    leading: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Atrás",
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall!.copyWith(color: Colors.blue),
                      ),
                    ),
                  ),
                  child: TransactionAmountCreatePage(
                    transactionModel: widget.transactionModel,
                    isEditable: false,
                    isForReport: false,
                  ),
                );
              },
            );
          },
          backgroundColor: colorScheme.primary,
          child: Icon(Icons.add, color: colorScheme.onPrimary),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  //APPBAR REACTIVO USANDO context.watch
  AppBar _selectedAviableAppbar(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    //context.watch fuerza la reconstrucción del AppBar cuando cambia el estado del Provider
    final provider = context.watch<TransactionsProvider>();

    final isMultiselectActive = provider.isMultiselectActive;
    final isItemSelected = provider.transactionsSelected.isNotEmpty;

    if (isMultiselectActive) {
      // AppBar de selección
      return AppBar(
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          onPressed: _updateNotSelectableUI, // Limpia la selección
          icon: Icon(CupertinoIcons.xmark, color: colorScheme.primary),
        ),
        title: Text(
          '${provider.transactionsSelected.length} seleccionados',
          style: textTheme.bodyMedium,
        ),
        actions: [
          if (isItemSelected)
            IconButton(
              onPressed: () async {
                //Llama al Provider para borrar
                await provider.deleteSelectedTransactionsAndUpdate(
                  context: context,
                  controller: transactionController,
                );
              },
              icon: Icon(
                CupertinoIcons.delete,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
        ],
      );
    } else {
      // AppBar normal
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

  //FUNCIÓN DE VISUALIZACIÓN DE TRANSACCIONES USANDO CONSUMER
  Widget _buildTransactionsView(BuildContext context, String type) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Consumer<TransactionsProvider>(
      builder: (context, provider, child) {
        final transactions = provider.transactions
            .where((t) => t.type == type)
            .toList();

        final isMultiselectActive = provider.isMultiselectActive;

        // 1. Estado de Carga Inicial
        if (provider.isLoadingInitial && transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Estado Vacío
        if (transactions.isEmpty && !provider.isLoadingInitial) {
          return Center(
            child: SizedBox(
              height: 220,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compare_arrows_sharp,
                    size: 120,
                    color: colorScheme.onSurfaceVariant,
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

        // 3. Scroll Infinito y RefreshIndicator
        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadInitialTransactions();
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent * 0.9 &&
                  !provider.isLoadingMore &&
                  provider.hasMore) {
                provider.loadMoreTransactions();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: transactions.length + (provider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == transactions.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                }

                final transaction = transactions[index];

                //Usamos el Set del Provider para saber si está seleccionado
                bool isSelected = provider.transactionsSelected.contains(
                  transaction.transactionId,
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 2.0,
                  ),
                  child: InkWell(
                    onLongPress: () {
                      //Inicia el modo multiselección y selecciona el elemento
                      provider.toggleTransactionSelection(transaction);
                    },
                    onTap: () {
                      // Si está activo, selecciona/deselecciona. Si no, navega.
                      if (isMultiselectActive) {
                        provider.toggleTransactionSelection(transaction);
                      } else {
                        _showTransaction(context, textTheme, transaction);
                      }
                    },
                    child: TransactionCardSmall(
                      isSelected: isSelected,
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
            ),
          ),
        );
      },
    );
  }

  void _showTransaction(
    BuildContext context,
    TextTheme textTheme,
    TransactionModel transaction,
  ) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    showCupertinoModalPopup(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateNotSelectableUI(); // Limpia la selección por si acaso
              },
              child: Text(
                "Atrás",
                style: textTheme.bodySmall!.copyWith(color: Colors.blue),
              ),
            ),

            trailing: TextButton(
              onPressed: () async {
                // ... (Lógica de navegación a edición) ...
                await showCupertinoModalPopup(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return CupertinoPageScaffold(
                      navigationBar: CupertinoNavigationBar(
                        backgroundColor: colorScheme.surface,
                        automaticBackgroundVisibility: false,
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
                        isForReport: false,
                      ),
                    );
                  },
                );
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
}
