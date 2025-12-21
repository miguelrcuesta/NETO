import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

// Modelos y Constantes
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/l10n/app_localizations.dart';

// Controllers y Providers
import 'package:neto_app/controllers/transaction_controller.dart';
import 'package:neto_app/provider/transaction_provider.dart';
import 'package:neto_app/provider/reports_provider.dart';

// Páginas y Widgets
import 'package:neto_app/pages/transactions/create/transaction_create_amount_page.dart';
import 'package:neto_app/pages/transactions/read/transaction_read_page.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/app_charts.dart';
import 'package:neto_app/widgets/app_empty_states.dart';
import 'package:neto_app/widgets/widgets.dart';

class TransactionsReadPage extends StatefulWidget {
  final TransactionModel? transactionModel;
  const TransactionsReadPage({super.key, this.transactionModel});

  @override
  State<TransactionsReadPage> createState() => _TransactionsReadPageState();
}

class _TransactionsReadPageState extends State<TransactionsReadPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final TransactionController _transactionController = TransactionController();

  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  // int? selectedYear;
  // int? selectedMonth;
  final List<int> years = List.generate(
    10,
    (index) => DateTime.now().year - index,
  );

  final List<int> months = List.generate(13, (index) => index);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsProvider>().loadInitialTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ########################################################################
  // 1. BUILD PRINCIPAL
  // ########################################################################

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<TransactionsProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surface, // Fondo usando surface
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsListView(context, TransactionType.expense.id),
          _buildTransactionsListView(context, TransactionType.income.id),
          _buildSummaryAllView(context),
        ],
      ),
      floatingActionButton: provider.transactions.isNotEmpty
          ? ClipOval(
              child: FloatingActionButton(
                heroTag: 'transactions_read_fab',
                onPressed: () => _openNewTransactionModal(context, colorScheme),
                backgroundColor: colorScheme.primary,
                child: Icon(Icons.add, color: colorScheme.onPrimary),
              ),
            )
          : null,
    );
  }

  // ########################################################################
  // 2. CONSTRUCTORES DE APPBAR
  // ########################################################################

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final provider = context.watch<TransactionsProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    if (provider.isMultiselectActive) {
      return TitleAppbar(
        leading: IconButton(
          onPressed: () => provider.clearSelection(),
          icon: Icon(CupertinoIcons.xmark, color: colorScheme.primary),
        ),
        title: '${provider.transactionsSelected.length} seleccionados',
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.delete, color: colorScheme.primary),
            onPressed: () => provider.deleteSelectedTransactionsAndUpdate(
              context: context,
              controller: _transactionController,
            ),
          ),
        ],
      );
    }

    return TitleTabAppbar(
      title: "Movimientos",
      bottom: PreferredSize(
        preferredSize: const Size(double.infinity, 50),
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.typeExpense),
            Tab(text: AppLocalizations.of(context)!.typeIncome),
            const Tab(text: "Resumen"),
          ],
        ),
      ),
    );
  }

  // ########################################################################
  // 3. VISTAS DE PESTAÑAS (TAB VIEWS)
  // ########################################################################

  // --- Vista de Resumen (Gráfico y Categorías) ---
  Widget _buildSummaryAllView(BuildContext context) {
    final provider = context.watch<TransactionsProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 1. Estructuras de datos para agrupación completa
    List<double> incomes = List.filled(12, 0.0);
    List<double> expenses = List.filled(12, 0.0);

    // Mapa: { "idCategoria": { "NombreSubcategoria": total } }
    Map<String, Map<String, double>> categoryGroupedData = {};
    Map<String, String> categoryTypes = {};

    // 2. Lógica de procesamiento
    for (var t in provider.transactions) {
      // Datos para el gráfico
      int monthIdx = t.date!.month - 1;
      if (t.type == TransactionType.income.id) {
        incomes[monthIdx] += t.amount;
      } else {
        expenses[monthIdx] += t.amount;
      }

      // Datos para el desglose (Categoría y Subcategoría)
      final String catId = t.categoryid ?? 'no_category';
      final String subName = t.subcategory ?? 'General';

      categoryTypes[catId] = t.type;
      categoryGroupedData.putIfAbsent(catId, () => {});

      // Sumamos a la subcategoría específica
      categoryGroupedData[catId]![subName] =
          (categoryGroupedData[catId]![subName] ?? 0) + t.amount;
    }

    if (categoryGroupedData.isEmpty) {
      return AppEmptyStates(
        asset: 'assets/animations/transactions_empty.svg',
        upText: 'Añade movimientos',
        downText: 'Añade tus gastos e ingresos para poder hacer un análisis',
        btnText: 'Añadir',
        onPressed: () => _openNewTransactionModal(context, colorScheme),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildYearPickerButton(colorScheme, textTheme),
          const SizedBox(height: 24),

          Text(
            "Balance Mensual",
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Contenedor del Gráfico (Altura fija para evitar errores de layout)
          Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TransactionBarChart(
              incomes: incomes,
              expenses: expenses,
              colorScheme: colorScheme,
            ),
          ),

          const SizedBox(height: 30),
          Text(
            "Desglose Detallado",
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 3. Renderizado de Categorías y sus Subcategorías
          ...categoryGroupedData.entries.map((categoryEntry) {
            final String catId = categoryEntry.key;
            final Map<String, double> subcategories = categoryEntry.value;

            // Calculamos el total de la categoría sumando sus subcategorías
            final double categoryTotal = subcategories.values.fold(
              0,
              (sum, val) => sum + val,
            );

            return Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
                //border: Border.all(color: color.outlineVariant),
              ),
              child: Column(
                children: [
                  // Tarjeta de la Categoría Principal
                  CategoryCard(
                    idCategory: catId,
                    type: categoryTypes[catId] ?? TransactionType.expense.id,
                    title: null,
                    amount: categoryTotal.toStringAsFixed(2),
                  ),

                  // Lista de Subcategorías (Indentadas)
                  ...subcategories.entries.map((subEntry) {
                    return Container(
                      margin: const EdgeInsets.only(
                        left: 12,

                        bottom: 6,
                        top: 2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      // decoration: BoxDecoration(
                      //   color: colorScheme.surface,
                      //   borderRadius: BorderRadius.circular(12),
                      //   border: Border.all(
                      //     color: colorScheme.outlineVariant.withOpacity(0.4),
                      //   ),
                      // ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(subEntry.key, style: textTheme.bodySmall),
                          Text(
                            subEntry.value.toStringAsFixed(2),
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // --- Vista de Listado de Transacciones ---
  Widget _buildTransactionsListView(BuildContext context, String type) {
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<TransactionsProvider>();
    final transactions = provider.transactions
        .where((t) => t.type == type)
        .toList();

    if (provider.isLoadingInitial && transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.isEmpty) {
      return AppEmptyStates(
        asset: 'assets/animations/transactions_empty.svg',
        upText: 'No hay movimientos',
        downText: '',
        btnText: 'Añadir',
        onPressed: () => _openNewTransactionModal(context, colorScheme),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadInitialTransactions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == transactions.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final item = transactions[index];
          final bool showHeader =
              index == 0 ||
              (item.date!.month != transactions[index - 1].date!.month);
          final bool isLast =
              (index + 1 == transactions.length) ||
              (item.date!.month != transactions[index + 1].date!.month);

          return _buildTransactionItem(
            item,
            showHeader,
            isLast,
            provider,
            colorScheme,
          );
        },
      ),
    );
  }

  // ########################################################################
  // 4. COMPONENTES DE ITEM Y UI
  // ########################################################################

  Widget _buildTransactionItem(
    TransactionModel item,
    bool showHeader,
    bool isLast,
    TransactionsProvider provider,
    ColorScheme color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Text(
              AppFormatters.customDateFormatMonthYear(item.date!),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: color.primaryContainer,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(showHeader ? 16 : 0),
              bottom: Radius.circular(isLast ? 16 : 0),
            ),
          ),
          child: _buildSlidableCard(item, provider, color),
        ),
        if (isLast) const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSlidableCard(
    TransactionModel item,
    TransactionsProvider provider,
    ColorScheme color,
  ) {
    bool isSelected = provider.transactionsSelected.contains(
      item.transactionId,
    );

    return Slidable(
      key: ValueKey(item.transactionId),
      enabled: !provider.isMultiselectActive,
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _onSlideToReport(item),
            backgroundColor: color.primary,
            icon: CupertinoIcons.folder,
            label: 'Informe',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (ctx) => _onSlideToDelete(ctx, item),
            backgroundColor: color.error,
            icon: CupertinoIcons.delete,
            label: 'Eliminar',
          ),
        ],
      ),
      child: InkWell(
        onTap: () => provider.isMultiselectActive
            ? provider.toggleTransactionSelection(item)
            : _showTransactionDetail(context, item),
        onLongPress: () => provider.toggleTransactionSelection(item),
        child: TransactionCardSmall(
          isSelected: isSelected,
          idCategory: item.categoryid,
          type: item.type,
          title: item.description ?? 'Sin descripción',
          subtitle: AppFormatters.customDateFormatShort(item.date!),
          amount: item.amount.toStringAsFixed(2),
        ),
      ),
    );
  }

  Widget _buildYearPickerButton(ColorScheme color, TextTheme text) {
    return Row(
      spacing: 20,
      children: [
        GestureDetector(
          onTap: () => _showYearPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: color.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 18,
                  color: color.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  "Año $selectedYear",
                  style: text.bodyMedium?.copyWith(
                    color: color.onPrimaryContainer,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: color.onPrimaryContainer),
              ],
            ),
          ),
        ),

        GestureDetector(
          onTap: () => _showMonthPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: color.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Mes $selectedMonth",
                  style: text.bodyMedium?.copyWith(
                    color: color.onPrimaryContainer,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: color.onPrimaryContainer),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ########################################################################
  // 5. LÓGICA DE MODALES Y ACCIONES
  // ########################################################################

  void _showYearPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            _buildPickerHeader(context),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 35,
                scrollController: FixedExtentScrollController(
                  initialItem: years.indexOf(selectedYear),
                ),
                onSelectedItemChanged: (i) {
                  setState(() => selectedYear = years[i]);
                },
                children: years
                    .map((y) => Center(child: Text(y.toString())))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            _buildPickerHeader(context),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 35,
                scrollController: FixedExtentScrollController(
                  initialItem: months.indexOf(selectedMonth),
                ),
                onSelectedItemChanged: (i) {
                  setState(() => selectedMonth = months[i]);
                },
                children: months
                    .map((m) => Center(child: Text(m.toString())))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CupertinoButton(
            child: const Text('Hecho'),
            onPressed: () async {
              await context
                  .read<TransactionsProvider>()
                  .loadTransactionsByFilter(
                    year: selectedYear,
                    month: selectedMonth,
                  );

              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _onSlideToDelete(
    BuildContext context,
    TransactionModel t,
  ) async {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Eliminar'),
        content: Text('¿Eliminar "${t.description}"?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('No'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TransactionsProvider>().deleteTransaction(
                id: t.transactionId!,
                context: context,
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _onSlideToReport(TransactionModel t) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoPageScaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        navigationBar: CupertinoNavigationBar(
          middle: const Text("Añadir a Informe"),
        ),
        child: Consumer<ReportsProvider>(
          builder: (ctx, reportProv, _) => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reportProv.reports.length,
            itemBuilder: (ctx, i) => ListTile(
              title: Text(reportProv.reports[i].name),
              onTap: () {
                reportProv.addTransactionToReport(
                  context: context,
                  report: reportProv.reports[i],
                  transactionmodel: t,
                );
                Navigator.pop(ctx);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, TransactionModel t) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoPageScaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        navigationBar: CupertinoNavigationBar(
          leading: TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Atrás"),
          ),
        ),
        child: TransactionReadPage(transactionModel: t),
      ),
    );
  }

  Future<void> _openNewTransactionModal(
    BuildContext context,
    ColorScheme color,
  ) async {
    context.read<TransactionsProvider>().clearSelection();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Atrás"),
          ),
        ),
        backgroundColor: color.surface,
        child: const TransactionAmountCreatePage(
          isEditable: false,
          isForReport: false,
        ),
      ),
    );
  }
}
