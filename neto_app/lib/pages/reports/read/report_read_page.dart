import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Constantes y Enums
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';

// Modelos
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';

// Páginas y Providers
import 'package:neto_app/pages/transactions/create/transaction_create_amount_page.dart';
import 'package:neto_app/pages/transactions/read/transaction_read_page.dart';
import 'package:neto_app/provider/reports_provider.dart';

// Widgets
import 'package:neto_app/widgets/app_charts.dart';
import 'package:neto_app/widgets/widgets.dart';

class ReportReadPage extends StatefulWidget {
  final ReportModel reportModel;
  const ReportReadPage({super.key, required this.reportModel});

  @override
  State<ReportReadPage> createState() => _ReportReadPageState();
}

class _ReportReadPageState extends State<ReportReadPage>
    with TickerProviderStateMixin {
  // --- Controladores y Keys ---
  late final TabController _tabController;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // --- Estado de Transacciones y Selección ---
  final List<TransactionModel> _animatedTransactions = [];
  bool _isSelectionMode = false;
  final Set<String> _selectedTransactionIds = {};
  bool _isInitialized = false;

  // --- Estado de Filtros (UI) ---
  int? _selectedYear;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedYear = DateTime.now().year; // Año inicial
  }

  // ########################################################################
  // 1. LÓGICA DE SINCRONIZACIÓN
  // ########################################################################

  void _syncTransactions(List<TransactionModel> providerData) {
    if (!_isInitialized) {
      _animatedTransactions.addAll(providerData);
      _isInitialized = true;
      return;
    }

    // --- LÓGICA DE ELIMINACIÓN (Nueva) ---
    if (providerData.length < _animatedTransactions.length) {
      // Buscamos qué elementos están en la lista local pero NO en el provider
      for (int i = _animatedTransactions.length - 1; i >= 0; i--) {
        final localItem = _animatedTransactions[i];
        bool existsInProvider = providerData.any(
          (p) => p.transactionId == localItem.transactionId,
        );

        if (!existsInProvider) {
          final removedItem = _animatedTransactions.removeAt(i);
          _listKey.currentState?.removeItem(
            i,
            (context, animation) => _buildAnimatedItem(
              removedItem,
              i,
              animation,
              true, // isRemoving = true
              Theme.of(context).colorScheme,
              Theme.of(context).textTheme,
              false,
            ),
            duration: const Duration(milliseconds: 400),
          );
        }
      }
    }

    // --- LÓGICA DE INSERCIÓN (Existente mejorada) ---
    if (providerData.length > _animatedTransactions.length) {
      for (int i = 0; i < providerData.length; i++) {
        final item = providerData[i];
        if (!_animatedTransactions.any(
          (t) => t.transactionId == item.transactionId,
        )) {
          _animatedTransactions.insert(i, item);
          _listKey.currentState?.insertItem(
            i,
            duration: const Duration(milliseconds: 400),
          );
        }
      }
    }

    // --- LÓGICA DE ACTUALIZACIÓN ---
    if (providerData.length == _animatedTransactions.length) {
      for (int i = 0; i < providerData.length; i++) {
        _animatedTransactions[i] = providerData[i];
      }
    }
  }

  // ########################################################################
  // 2. PESTAÑA: RESUMEN (Con Filtro de Año)
  // ########################################################################

  Widget _buildSummaryTab(
    ReportsProvider provider,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (_animatedTransactions.isEmpty) {
      return Center(
        child: Text("Sin datos para el resumen", style: textTheme.bodyMedium),
      );
    }

    // A. Obtener años únicos disponibles en el reporte
    final List<int> availableYears =
        _animatedTransactions.map((t) => t.date!.year).toSet().toList()
          ..sort((a, b) => b.compareTo(a));

    // B. Asegurar que el año seleccionado sea válido
    if (!availableYears.contains(_selectedYear) && availableYears.isNotEmpty) {
      _selectedYear = availableYears.first;
    }

    // C. Filtrar y procesar datos para el año seleccionado
    final filtered = _animatedTransactions
        .where((t) => t.date!.year == _selectedYear)
        .toList();

    List<double> monthlyIncomes = List.filled(12, 0.0);
    List<double> monthlyExpenses = List.filled(12, 0.0);
    Map<String, Map<String, double>> categoryGroupedData = {};
    Map<String, String> categoryTypes = {};

    for (var t in filtered) {
      int monthIdx = t.date!.month - 1;
      if (t.type == TransactionType.income.id) {
        monthlyIncomes[monthIdx] += t.amount;
      } else {
        monthlyExpenses[monthIdx] += t.amount;
      }

      final catId = t.categoryid;
      categoryTypes[catId] = t.type;
      categoryGroupedData.putIfAbsent(catId, () => {});

      final subName = t.subcategory;
      categoryGroupedData[catId]![subName] =
          (categoryGroupedData[catId]![subName] ?? 0) + t.amount;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            "Análisis anual",
            textTheme,
            trailing: "$_selectedYear",
          ),
          const SizedBox(height: 16),

          // Selector de Años (Chips)
          _buildYearSelector(availableYears, colorScheme, textTheme),

          const SizedBox(height: 16),
          // Gráfico
          _buildChartCard(monthlyIncomes, monthlyExpenses, colorScheme),

          const SizedBox(height: 30),
          _buildSectionHeader("Desglose de gastos e ingresos", textTheme),
          const SizedBox(height: 12),

          // Lista de Categorías
          ...categoryGroupedData.entries.map((categoryEntry) {
            final String catId = categoryEntry.key;
            final Map<String, double> subcategories = categoryEntry.value;
            final double categoryTotal = subcategories.values.fold(
              0,
              (sum, val) => sum + val,
            );

            return _buildCategoryGroup(
              catId,
              categoryTypes[catId] ?? TransactionType.expense.id,
              categoryTotal,
              subcategories,
              colorScheme,
              textTheme,
            );
          }),
        ],
      ),
    );
  }

  // ########################################################################
  // 3. PESTAÑA: MOVIMIENTOS (Lista Animada)
  // ########################################################################

  Widget _buildTransactionsTab(ColorScheme color, TextTheme text) {
    if (_animatedTransactions.isEmpty) {
      return Center(child: Text("No hay movimientos", style: text.bodyMedium));
    }

    return AnimatedList(
      key: _listKey,
      initialItemCount: _animatedTransactions.length,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      itemBuilder: (context, index, animation) {
        if (index >= _animatedTransactions.length) {
          return const SizedBox.shrink();
        }

        final item = _animatedTransactions[index];
        bool showMonthHeader =
            index == 0 ||
            (item.date!.month !=
                _animatedTransactions[index - 1].date!.month) ||
            (item.date!.year != _animatedTransactions[index - 1].date!.year);

        return _buildAnimatedItem(
          item,
          index,
          animation,
          false,
          color,
          text,
          showMonthHeader,
        );
      },
    );
  }

  // ########################################################################
  // 4. COMPONENTES DE UI (SUB-WIDGETS)
  // ########################################################################

  Widget _buildYearSelector(
    List<int> years,
    ColorScheme color,
    TextTheme text,
  ) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: years.length,
        itemBuilder: (context, index) {
          final year = years[index];
          final isSelected = year == _selectedYear;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(year.toString()),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedYear = year),
              selectedColor: color.primary.withAlpha(90),
              backgroundColor: color.primaryContainer,
              checkmarkColor: color.primary,
              labelStyle: text.bodySmall?.copyWith(
                color: isSelected ? color.primary : color.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard(
    List<double> inc,
    List<double> exp,
    ColorScheme color,
  ) {
    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: TransactionBarChart(
        incomes: inc,
        expenses: exp,
        colorScheme: color,
      ),
    );
  }

  Widget _buildCategoryGroup(
    String id,
    String type,
    double total,
    Map<String, double> subs,
    ColorScheme color,
    TextTheme text,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: color.primaryContainer,
        borderRadius: BorderRadius.circular(10),
        //border: Border.all(color: color.outlineVariant),
      ),
      child: Column(
        children: [
          CategoryCard(
            idCategory: id,
            type: type,
            title: null,
            amount: total.toStringAsFixed(2),
          ),
          ...subs.entries.map(
            (sub) => Container(
              margin: const EdgeInsets.only(left: 12, bottom: 6, top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sub.key,
                    style: text.bodySmall!.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    sub.value.toStringAsFixed(2),
                    style: text.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, TextTheme text, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (trailing != null)
          Text(trailing, style: text.labelSmall?.copyWith(color: Colors.grey)),
      ],
    );
  }

  // ########################################################################
  // 5. BUILD PRINCIPAL Y APPBAR
  // ########################################################################

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final provider = context.watch<ReportsProvider>();
    final currentReport = provider.getReportById(widget.reportModel.reportId!);
    final sortedData = provider.getSortedTransactions(
      widget.reportModel.reportId,
    );

    _syncTransactions(sortedData);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme, textTheme, currentReport, provider),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsTab(colorScheme, textTheme),
          _buildSummaryTab(provider, colorScheme, textTheme),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ColorScheme color,
    TextTheme text,
    ReportModel report,
    ReportsProvider provider,
  ) {
    if (_isSelectionMode) {
      return AppBar(
        backgroundColor: color.surface,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark),
          onPressed: () => setState(() {
            _isSelectionMode = false;
            _selectedTransactionIds.clear();
          }),
        ),
        title: Text(
          '${_selectedTransactionIds.length} Seleccionados',
          style: text.bodyMedium,
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.trash, color: color.error),
            onPressed: () => _deleteTransactions(provider, report, color),
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: color.surface,
      title: Text(report.name, style: text.titleSmall),
      centerTitle: true,
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Movimientos'),
          Tab(text: 'Resumen'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.add),
          onPressed: () => _openCreatePage(color, text, report),
        ),
      ],
    );
  }

  // ########################################################################
  // 6. MÉTODOS DE SOPORTE (Detalle, Animación, Navegación)
  // ########################################################################

  Widget _buildAnimatedItem(
    TransactionModel item,
    int index,
    Animation<double> animation,
    bool isRemoving,
    ColorScheme color,
    TextTheme text,
    bool showMonthHeader,
  ) {
    bool isLastOfMonth = true;
    if (index + 1 < _animatedTransactions.length) {
      final nextItem = _animatedTransactions[index + 1];
      if (item.date!.month == nextItem.date!.month &&
          item.date!.year == nextItem.date!.year) {
        isLastOfMonth = false;
      }
    }

    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showMonthHeader)
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 10, left: 4),
                child: Text(
                  AppFormatters.customDateFormatMonthYear(item.date!),
                  style: text.titleSmall!,
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: color.primaryContainer,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(showMonthHeader ? 16 : 0),
                  bottom: Radius.circular(isLastOfMonth ? 16 : 0),
                ),
              ),
              child: GestureDetector(
                onLongPress: () => isRemoving ? null : _toggleSelection(item),
                onTap: () => _isSelectionMode
                    ? _toggleSelection(item)
                    : _openDetailPage(item, color),
                child: TransactionCardSmall(
                  isSelected: _selectedTransactionIds.contains(
                    item.transactionId,
                  ),
                  idCategory: item.categoryid,
                  type: item.type,
                  title: item.description,
                  subtitle: AppFormatters.customDateFormatShort(item.date!),
                  amount: item.amount.toStringAsFixed(2),
                ),
              ),
            ),
            if (isLastOfMonth) const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _toggleSelection(TransactionModel transaction) {
    setState(() {
      final id = transaction.transactionId!;
      _selectedTransactionIds.contains(id)
          ? _selectedTransactionIds.remove(id)
          : _selectedTransactionIds.add(id);
      _isSelectionMode = _selectedTransactionIds.isNotEmpty;
    });
  }

  Future<void> _deleteTransactions(
    ReportsProvider provider,
    ReportModel report,
    ColorScheme color,
  ) async {
    final idsToDelete = _selectedTransactionIds.toList();

    // Opcional: Mostrar un diálogo de carga o confirmación aquí

    await provider.removeTransactionsOfReport(
      context: context,
      report: report,
      transactionsIds: idsToDelete,
    );

    setState(() {
      _isSelectionMode = false;
      _selectedTransactionIds.clear();
    });
  }

  void _openCreatePage(ColorScheme color, TextTheme text, ReportModel report) {
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
        child: TransactionAmountCreatePage(
          isEditable: false,
          isForReport: true,
          reportModel: report,
        ),
      ),
    );
  }

  void _openDetailPage(TransactionModel item, ColorScheme color) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoPageScaffold(
        backgroundColor: color.surface,
        navigationBar: CupertinoNavigationBar(
          leading: TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Atrás"),
          ),
        ),
        child: TransactionReadPage(transactionModel: item),
      ),
    );
  }
}
