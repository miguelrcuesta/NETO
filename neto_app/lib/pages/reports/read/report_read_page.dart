import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/provider/reports_provider.dart';
import 'package:provider/provider.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/pages/reports/create/report_transaction_create_page.dart';
import 'package:neto_app/models/reports_model.dart';
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
  // VARIABLES Y CONTROLADORES
  //########################################################################

  late final TabController _tabController;

  // 🔑 Listado de transacciones local para manejar la animación
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Lista local para mantener el estado de la lista visible
  late List<ReportTransactionModel> _animatedTransactions;

  // 🔑 VARIABLES PARA SELECCIÓN MÚLTIPLE
  bool _isSelectionMode = false;
  final Set<String> _selectedTransactionIds =
      {}; // Usamos un Set para eficiencia

  //########################################################################
  // FUNCIONES DE UTILIDAD
  //########################################################################

  // Función para obtener la categoría (Placeholder)
  dynamic _getCategory(String typeId, String categoryId) {
    if (typeId == TransactionType.expense.id) {
      return (
        color: Colors.red,
        iconData: CupertinoIcons.arrow_down,
        nombre: 'Gasto',
      );
    } else {
      return (
        color: Colors.green,
        iconData: CupertinoIcons.arrow_up,
        nombre: 'Ingreso',
      );
    }
  }

  /// Procesa y ordena síncronamente las transacciones incrustadas de UN MODELO.
  List<ReportTransactionModel> _processReportTransactions(ReportModel report) {
    final List<ReportTransactionModel> transactions = report
        .reportTransactions
        .values
        .toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  /// TOGGLE DE SELECCIÓN
  void _toggleSelection(ReportTransactionModel transaction) {
    setState(() {
      final id = transaction.reportTransactionId;
      if (_selectedTransactionIds.contains(id)) {
        _selectedTransactionIds.remove(id);
      } else {
        _selectedTransactionIds.add(id);
      }

      // Salir del modo de selección si no queda nada seleccionado
      if (_selectedTransactionIds.isEmpty) {
        _isSelectionMode = false;
      } else {
        _isSelectionMode = true;
      }
    });
  }

  /// ELIMINAR TRANSACCIONES SELECCIONADAS
  Future<void> _deleteSelectedTransactions() async {
    if (_selectedTransactionIds.isEmpty) return;

    final provider = context.read<ReportsProvider>();
    final List<String> idsToDelete = _selectedTransactionIds.toList();

    // 1. Mostrar diálogo de confirmación
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

    // 2. Ejecutar la eliminación en el Provider (y persistencia)
    try {
      // Usamos el reporte más reciente del provider
      final currentReport = provider.getReportById(widget.reportModel.reportId);
      if (!context.mounted) return;

      await provider.removeTransactionsOfReport(
        context: context,
        report: currentReport,
        transactionsIds: idsToDelete,
      );

      // 3. Eliminación local y animación
      setState(() {
        for (final id in idsToDelete) {
          final index = _animatedTransactions.indexWhere(
            (t) => t.reportTransactionId == id,
          );
          if (index != -1) {
            final removedItem = _animatedTransactions.removeAt(index);
            _listKey.currentState!.removeItem(
              index,
              (context, animation) => _buildItem(
                removedItem,
                index,
                animation,
                Theme.of(context).colorScheme,
                Theme.of(context).textTheme,
              ),
              duration: const Duration(milliseconds: 300),
            );
          }
        }
        // Resetear estado
        _selectedTransactionIds.clear();
        _isSelectionMode = false;
      });
    } catch (e) {
      debugPrint('Error al eliminarlas');
    }
  }

  /// Función para construir el ítem de la lista con animación
  Widget _buildItem(
    ReportTransactionModel transaction,
    int index,
    Animation<double> animation,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    // Usamos SlideTransition para la animación de entrada/salida
    return SizeTransition(
      // Usamos SizeTransition para la animación de cierre (eliminación)
      sizeFactor: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: _buildDismissibleItem(
          transaction,
          index,
          colorScheme,
          textTheme,
        ),
      ),
    );
  }

  /// Widget Dismissible para envolver la transacción y permitir la eliminación
  Widget _buildDismissibleItem(
    ReportTransactionModel transaction,
    int index,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final category = _getCategory(transaction.typeId, transaction.categoryId);
    var isSelected = _selectedTransactionIds.contains(
      transaction.reportTransactionId,
    );

    // Si estamos en modo de selección, deshabilitamos el Dismissible
    final bool enableDismiss = !_isSelectionMode;

    Widget listTile = Container(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: CupertinoListTile(
        padding: const EdgeInsets.only(left: 10, right: 40),

        leading: ClipRRect(
          child: Container(
            width: 45,
            height: 45,
            decoration: decorationContainer(
              context: context,
              colorFilled: category.color.withAlpha(30),
              radius: 100,
            ),
            child: Icon(category.iconData, size: 15, color: category.color),
          ),
        ),

        title: Text(
          transaction.description,
          style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurface),
        ),
        subtitle: Text(
          AppFormatters.customDateFormatShort(transaction.date),
          style: textTheme.bodyMedium!.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: SizedBox(
          width: 90,
          child: Text(
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            transaction.amount.toStringAsFixed(2),
            style: textTheme.bodyMedium!.copyWith(
              color:
                  colorScheme.onSurfaceVariant, // Color del tipo de transacción
            ),
          ),
        ),
      ),
    );

    // ENVOLVER EN UN GESTURE DETECTOR PARA ACTIVAR/SELECCIONAR
    return GestureDetector(
      // Pulsación larga: Activa el modo de selección
      onLongPress: () => _toggleSelection(transaction),
      // Toque normal: Si está en modo selección, selecciona/deselecciona. Si no, (aquí iría la navegación a editar)
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(transaction);
        } else {
          // TODO: Implementar navegación a ReportTransactionEditPage
          // Navigator.push(...);
        }
      },
      child: Container(
        // Efecto visual al seleccionar
        child: Row(
          children: [
            // Mostrar checkbox si está en modo selección
            if (_isSelectionMode)
              // Padding(
              //   padding: const EdgeInsets.only(left: 8.0),
              //   child: CupertinoCheckbox(
              //     value: isSelected,
              //     onChanged: (val) => _toggleSelection(transaction),
              //   ),
              // ),
              if (isSelected)
                IconButton(
                  onPressed: () {
                    setState(() {
                      //sSelected = !isSelected;
                      _toggleSelection(transaction);
                    });
                  },
                  icon: Icon(
                    Icons.check_circle,
                    size: 35,
                    color: colorScheme.primary,
                  ),
                ),

            Expanded(
              // Usamos el Dismissible solo si no estamos en modo selección
              child: enableDismiss
                  ? Dismissible(
                      key: ValueKey(transaction.reportTransactionId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(
                          CupertinoIcons.trash,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await _confirmDeletion(
                          context,
                          transaction,
                          index,
                        );
                      },
                      child: listTile,
                    )
                  : listTile,
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra un diálogo de confirmación para una ÚNICA eliminación (via deslizar)
  Future<bool> _confirmDeletion(
    BuildContext context,
    ReportTransactionModel transaction,
    int index,
  ) async {
    // ... (Tu lógica de diálogo y eliminación simple, ya implementada) ...

    final bool confirm =
        await showCupertinoDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => CupertinoAlertDialog(
            title: const Text('Confirmar Eliminación'),
            content: Text(
              '¿Estás seguro de que quieres eliminar "${transaction.description}"?',
            ),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.blue),
                ),
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

    if (confirm && context.mounted) {
      final provider = context.read<ReportsProvider>();

      // 1. ELIMINACIÓN LOCAL ANIMADA
      final removedItem = _animatedTransactions.removeAt(index);
      _listKey.currentState!.removeItem(
        index,
        (context, animation) => _buildItem(
          removedItem,
          index,
          animation,
          Theme.of(context).colorScheme,
          Theme.of(context).textTheme,
        ),
        duration: const Duration(milliseconds: 300),
      );

      // 2. ELIMINACIÓN EN EL PROVIDER (Y PERSISTENCIA)
      try {
        if (context.mounted) {
          await provider.removeTransactionsOfReport(
            context: context,
            report: provider.getReportById(widget.reportModel.reportId),
            transactionsIds: [transaction.reportTransactionId],
          );
        }
      } catch (e) {
        // Revertir la eliminación si falla la persistencia
        _animatedTransactions.insert(index, removedItem);
        _listKey.currentState!.insertItem(index);

        return false;
      }
      return true;
    }
    return false;
  }

  //########################################################################
  // ESTADOS WIDGET
  //########################################################################

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animatedTransactions = _processReportTransactions(widget.reportModel);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentReport = context.watch<ReportsProvider>().getReportById(
      widget.reportModel.reportId,
    );
    final newTransactions = _processReportTransactions(currentReport);

    if (newTransactions.length > _animatedTransactions.length) {
      if (newTransactions.isNotEmpty && _animatedTransactions.isEmpty) {
        _animatedTransactions = newTransactions;
        _listKey.currentState?.insertAllItems(0, newTransactions.length);
      } else {
        // Asume que la nueva está al principio (ordenado por fecha)
        final newTransaction = newTransactions.first;
        _animatedTransactions.insert(0, newTransaction);
        _listKey.currentState?.insertItem(0);
      }
    }
    if (newTransactions.length == _animatedTransactions.length) {
      _animatedTransactions = newTransactions;
    }
  }

  //  BARRA DE APLICACIÓN DINÁMICA
  PreferredSizeWidget _buildAppBar(
    ColorScheme colorScheme,
    TextTheme textTheme,
    ReportModel currentReport,
  ) {
    if (_isSelectionMode) {
      // MODO SELECCIÓN
      return AppBar(
        backgroundColor: colorScheme.primary,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSelectionMode = false;
              _selectedTransactionIds.clear();
            });
          },
        ),
        title: Text(
          '${_selectedTransactionIds.length} Seleccionado(s)',
          style: textTheme.titleSmall!.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed:
                _deleteSelectedTransactions, // 🔑 Función de eliminación masiva
            icon: const Icon(CupertinoIcons.trash, color: Colors.white),
          ),
        ],
      );
    } else {
      // MODO NORMAL
      return AppBar(
        backgroundColor: colorScheme.primaryContainer,
        title: Text(currentReport.name, style: textTheme.titleSmall),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 50),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              const Tab(text: 'Movimientos'),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.sparkles,
                      size: 18,
                      color: Colors.deepPurpleAccent,
                    ),
                    const SizedBox(width: 3),
                    const Text("Resumen"),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      ReportTransactionCreatePage(reportModel: currentReport),
                ),
              );
            },
            icon: Icon(CupertinoIcons.add, color: colorScheme.primary),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    final ReportModel currentReport = context
        .watch<ReportsProvider>()
        .getReportById(widget.reportModel.reportId);

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      // 🔑 Usamos la función dinámica del AppBar
      appBar: _buildAppBar(colorScheme, textTheme, currentReport),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsTab(context, colorScheme, textTheme, currentReport),
          Center(child: Text('Estadísticas para ${currentReport.name}')),
        ],
      ),
    );
  }

  // ... (El resto del código de _buildTransactionsTab se mantiene igual)
  Widget _buildTransactionsTab(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    ReportModel report,
  ) {
    if (_animatedTransactions.isEmpty && report.reportTransactions.isEmpty) {
      return Center(
        child: SizedBox(
          height: 220,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.folder,
                color: colorScheme.onSurfaceVariant,
                size: 100,
              ),
              Text(
                textAlign: TextAlign.center,
                'No hay movimientos disponibles para este informe.',
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
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      child: AnimatedList(
        key: _listKey,
        initialItemCount: _animatedTransactions.length,
        itemBuilder: (context, index, animation) {
          if (index >= _animatedTransactions.length) {
            return const SizedBox.shrink();
          }

          final transaction = _animatedTransactions[index];

          return Column(
            children: [
              _buildItem(transaction, index, animation, colorScheme, textTheme),
              // Separador solo si no es el último ítem
              if (index < _animatedTransactions.length - 1)
                Divider(color: colorScheme.outline, height: 1),
            ],
          );
        },
      ),
    );
  }
}
