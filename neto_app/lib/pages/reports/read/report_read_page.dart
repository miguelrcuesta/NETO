import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/pages/transactions/create/transaction_create_amount_page.dart';
import 'package:neto_app/pages/transactions/read/transaction_read_page.dart';
import 'package:neto_app/provider/reports_provider.dart';
import 'package:neto_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ReportReadPage extends StatefulWidget {
  final ReportModel reportModel;
  const ReportReadPage({super.key, required this.reportModel});

  @override
  State<ReportReadPage> createState() => _ReportReadPageState();
}

class _ReportReadPageState extends State<ReportReadPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Lista local espejo para gestionar los índices de la animación
  final List<TransactionModel> _animatedTransactions = [];

  bool _isSelectionMode = false;
  final Set<String> _selectedTransactionIds = {};
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  /// Sincronización entre Provider y AnimatedList
  void _syncTransactions(List<TransactionModel> providerData) {
    if (!_isInitialized) {
      _animatedTransactions.addAll(providerData);
      _isInitialized = true;
      return;
    }

    // Detectar Inserciones
    if (providerData.length > _animatedTransactions.length) {
      for (var item in providerData) {
        if (!_animatedTransactions.any(
          (t) => t.transactionId == item.transactionId,
        )) {
          _animatedTransactions.insert(0, item);
          _listKey.currentState?.insertItem(
            0,
            duration: const Duration(milliseconds: 400),
          );
        }
      }
    }

    // Detectar Ediciones
    if (providerData.length == _animatedTransactions.length) {
      for (int i = 0; i < providerData.length; i++) {
        _animatedTransactions[i] = providerData[i];
      }
    }
  }

  //====================================================================
  // ACCIÓN DE BORRADO (Diálogo Cupertino original)
  //====================================================================

  Future<void> _deleteTransactions(
    ReportsProvider provider,
    ReportModel report,
    ColorScheme color,
  ) async {
    final idsToDelete = _selectedTransactionIds.toList();

    // 1. Diálogo de confirmación Cupertino (Como lo tenías antes)
    final bool confirm =
        await showCupertinoDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => CupertinoAlertDialog(
            title: const Text('Eliminar Movimientos'),
            content: Text(
              '¿Estás seguro de que quieres eliminar ${idsToDelete.length} movimientos seleccionados?',
            ),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(dialogContext, false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Eliminar'),
                onPressed: () => Navigator.pop(dialogContext, true),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      // 2. Persistencia en Backend
      await provider.removeTransactionsOfReport(
        context: context,
        report: report,
        transactionsIds: idsToDelete,
      );

      // 3. Animaciones de salida locales
      for (var id in idsToDelete) {
        final index = _animatedTransactions.indexWhere(
          (t) => t.transactionId == id,
        );
        if (index != -1) {
          final removedItem = _animatedTransactions.removeAt(index);
          _listKey.currentState?.removeItem(
            index,
            (context, animation) =>
                _buildItem(removedItem, index, animation, true, color),
            duration: const Duration(milliseconds: 300),
          );
        }
      }

      setState(() {
        _selectedTransactionIds.clear();
        _isSelectionMode = false;
      });
    } catch (e) {
      debugPrint("Error al eliminar movimientos: $e");
    }
  }

  //====================================================================
  // BUILDERS DE UI
  //====================================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final provider = context.watch<ReportsProvider>();
    final currentReport = provider.getReportById(widget.reportModel.reportId!);
    final sortedData = provider.getSortedTransactions(
      widget.reportModel.reportId!,
    );

    _syncTransactions(sortedData);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme, textTheme, currentReport, provider),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsTab(colorScheme, textTheme),
          Center(
            child: Text('Resumen del Informe', style: textTheme.bodyLarge),
          ),
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
          icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
          onPressed: () => setState(() {
            _isSelectionMode = false;
            _selectedTransactionIds.clear();
          }),
        ),
        title: Text(
          '${_selectedTransactionIds.length} Seleccionados',
          style: text.titleSmall!.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.trash, color: Colors.white),
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

  Widget _buildTransactionsTab(ColorScheme color, TextTheme text) {
    if (_animatedTransactions.isEmpty) {
      return Center(child: Text("No hay movimientos", style: text.bodyMedium));
    }

    return AnimatedList(
      key: _listKey,
      initialItemCount: _animatedTransactions.length,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      itemBuilder: (context, index, animation) {
        if (index >= _animatedTransactions.length) {
          return const SizedBox.shrink();
        }
        return _buildItem(
          _animatedTransactions[index],
          index,
          animation,
          false,
          color,
        );
      },
    );
  }

  Widget _buildItem(
    TransactionModel item,
    int index,
    Animation<double> animation,
    bool isRemoving,
    ColorScheme color,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: Column(
          children: [
            GestureDetector(
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
            const Divider(height: 1, indent: 70),
          ],
        ),
      ),
    );
  }

  //====================================================================
  // UTILIDADES
  //====================================================================

  void _toggleSelection(TransactionModel transaction) {
    setState(() {
      final id = transaction.transactionId!;
      if (_selectedTransactionIds.contains(id)) {
        _selectedTransactionIds.remove(id);
      } else {
        _selectedTransactionIds.add(id);
      }
      _isSelectionMode = _selectedTransactionIds.isNotEmpty;
    });
  }

  void _openCreatePage(ColorScheme color, TextTheme text, ReportModel report) {
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
          backgroundColor: color.surface,
          leading: TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cerrar"),
          ),
        ),
        child: TransactionReadPage(transactionModel: item),
      ),
    );
  }
}
