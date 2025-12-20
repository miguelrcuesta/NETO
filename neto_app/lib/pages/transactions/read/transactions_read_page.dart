import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/provider/reports_provider.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/app_empty_states.dart';
import 'package:provider/provider.dart';
import 'package:neto_app/provider/transaction_provider.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/controllers/reports_controller.dart';
import 'package:neto_app/controllers/transaction_controller.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/pages/transactions/create/transaction_create_amount_page.dart';
import 'package:neto_app/pages/transactions/read/transaction_read_page.dart';
import 'package:neto_app/widgets/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Importación necesaria

class TransactionsReadPage extends StatefulWidget {
  final TransactionModel? transactionModel;
  const TransactionsReadPage({super.key, this.transactionModel});

  @override
  State<TransactionsReadPage> createState() => _TransactionsReadPageState();
}

class _TransactionsReadPageState extends State<TransactionsReadPage>
    with TickerProviderStateMixin {
  //########################################################################
  // VARIABLES Y CONTROLADORES
  //########################################################################
  final List selectedReports = [];
  late final TabController _tabController;
  TransactionController transactionController = TransactionController();
  ReportsController reportController = ReportsController();

  //########################################################################
  // FUNCIONES DE PROCESAMIENTO
  //########################################################################

  void _updateNotSelectableUI() {
    // Si el widget no está montado (defunct), salimos.
    if (!mounted) return;
    context.read<TransactionsProvider>().clearSelection();
  }

  // Simulación de formateador de fecha para el encabezado del mes
  String _formatMonthYear(String monthYearKey) {
    if (monthYearKey == 'Sin Fecha') return monthYearKey;

    try {
      final parts = monthYearKey.split('-');
      final year = parts[0];
      final month = int.parse(parts[1]);

      const monthNames = [
        'Enero',
        'Febrero',
        'Marzo',
        'Abril',
        'Mayo',
        'Junio',
        'Julio',
        'Agosto',
        'Septiembre',
        'Octubre',
        'Noviembre',
        'Diciembre',
      ];

      if (month >= 1 && month <= 12) {
        return '${monthNames[month - 1]} $year';
      }
      return monthYearKey;
    } catch (e) {
      return monthYearKey;
    }
  }

  // FUNCIÓN DE AGRUPACIÓN POR MES
  Map<String, List<TransactionModel>> groupTransactionsByMonth(
    List<TransactionModel> transactions,
  ) {
    final Map<String, List<TransactionModel>> groupedMap = {};

    for (var transaction in transactions) {
      // Clave: 'YYYY-MM'
      final monthYear = transaction.date != null
          ? '${transaction.date!.year}-${transaction.date!.month.toString().padLeft(2, '0')}'
          : 'Sin Fecha';

      // Inicializa la lista si la clave no existe
      if (!groupedMap.containsKey(monthYear)) {
        groupedMap[monthYear] = [];
      }

      // Añade la transacción a la lista del mes correspondiente
      groupedMap[monthYear]!.add(transaction);
    }

    return groupedMap;
  }

  void _showTransaction(
    BuildContext context,
    TextTheme textTheme,
    TransactionModel transaction,
  ) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    // La lógica de navegación se mantiene, asegurando que se compruebe 'mounted'
    // si alguna operación asíncrona ocurriera dentro de este modal.
    showCupertinoModalPopup(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CupertinoPageScaffold(
          backgroundColor: colorScheme.surface,
          navigationBar: CupertinoNavigationBar(
            leading: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateNotSelectableUI();
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

  // ACCIÓN DE DESLIZAMIENTO IZQUIERDA: Añadir a Informe
  void _onSlideToReport(TransactionModel transaction) {
    // Implementar la lógica para añadir a un informe (SHOWMODAL)
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext modalContext) {
        ColorScheme colorScheme = Theme.of(context).colorScheme;
        TextTheme textTheme = Theme.of(context).textTheme;
        //FloatingLa lógica del ReportSelectionModal

        // // El ReportsProvider ya debería estar cargado
        // // Usamos modalContext para Consumer
        // final ReportsProvider provider = modalContext
        //     .read<ReportsProvider>();

        return CupertinoPageScaffold(
          backgroundColor: colorScheme.surface,
          resizeToAvoidBottomInset: false,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: colorScheme.surface,
            automaticBackgroundVisibility: true,
            leading: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Atrás",
                style: textTheme.bodySmall!.copyWith(color: Colors.blue),
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Consumer<ReportsProvider>(
                builder: (context, provider, child) {
                  final reports = provider.reports;

                  if (provider.isLoadingInitial && reports.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (reports.isEmpty) {
                    return Center(
                      child: Text(
                        "No tienes informes creados.",
                        style: textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];

                      // Comprobar si la transacción ya existe en el mapa (clave es el reportTransactionId)
                      // Buscamos si ya existe una transacción con los mismos datos incrustados
                      // Para simplificar, asumiremos que si ya tiene una transacción con la misma descripción y monto, ya existe.
                      final bool isAlreadyInReport = report
                          .reportTransactions
                          .values
                          .any(
                            (rt) =>
                                rt.description == transaction.description &&
                                rt.amount == transaction.amount,
                          );

                      return Padding(
                        padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                        child: GestureDetector(
                          onTap: () async {
                            if (isAlreadyInReport) {
                              // Si ya está, cerramos el modal y opcionalmente mostramos un mensaje
                              Navigator.pop(modalContext);
                              // Opcional: AppUtils.showInfo(context, 'Ya está en este informe.');
                              return;
                            }

                            // 2. Añadir la transacción al informe usando el Provider
                            await provider.addTransactionToReport(
                              context: context,
                              report: report,
                              transactionmodel: transaction, // Objeto completo
                            );

                            if (!context.mounted) return;
                            // 3. Cerrar el modal
                            Navigator.pop(modalContext);
                          },
                          child: ReportCard(
                            upText: report.name,
                            // Mostrar el número de transacciones incrustadas
                            dateText: report.reportTransactions.length == 1
                                ? '1 Movimiento'
                                : '${report.reportTransactions.length} Movimientos',
                            isSelected: isAlreadyInReport,
                            // trailing: isAlreadyInReport
                            //     ? Icon(
                            //         Icons.check,
                            //         color: colorScheme.primary,
                            //       )
                            //     : null,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ACCIÓN DE DESLIZAMIENTO DERECHA: Eliminar Transacción
  Future<void> _onSlideToDelete(
    BuildContext context, // Este es el contexto SEGURO
    TransactionModel transaction,
  ) async {
    final transactionId = transaction.transactionId;
    if (transactionId == null) {
      if (mounted) {
        // Verificación de seguridad
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: ID de transacción no encontrado.'),
          ),
        );
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text(
            '¿Estás seguro de que quieres eliminar la transacción "${transaction.description}"?',
          ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                Navigator.pop(context); // Cierra el diálogo
              },
              child: const Text('Cancelar'),
            ),

            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                // 1. Cerrar el diálogo inmediatamente.
                Navigator.pop(context);

                // 2. Llamada asíncrona del Provider.
                await context.read<TransactionsProvider>().deleteTransaction(
                  id: transactionId,
                  context: context, // ✅ USAR EL CONTEXTO PADRE SEGURO
                );
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  //########################################################################
  // ESTADOS WIDGET
  //########################################################################
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

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
    final transactionsProvider = Provider.of<TransactionsProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _selectedAviableAppbar(context),
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
      floatingActionButton: transactionsProvider.transactions.isNotEmpty
          ? ClipOval(
              child: FloatingActionButton(
                heroTag: 'transactions_read_fab',
                onPressed: () async {
                  _updateNotSelectableUI();

                  await _newTransactionShowModal(context, colorScheme);
                },
                backgroundColor: colorScheme.primary,
                child: Icon(Icons.add, color: colorScheme.onPrimary),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Future<dynamic> _newTransactionShowModal(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return showCupertinoModalPopup(
      barrierDismissible: false,
      context: context,
      builder: (context) {
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
  }

  // APPBAR REACTIVO
  PreferredSizeWidget _selectedAviableAppbar(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    final provider = context.watch<TransactionsProvider>();

    final isMultiselectActive = provider.isMultiselectActive;
    final isItemSelected = provider.transactionsSelected.isNotEmpty;

    if (isMultiselectActive) {
      // AppBar de selección
      return TitleAppbar(
        //color: colorScheme.primary,
        leading: IconButton(
          onPressed: _updateNotSelectableUI,
          icon: Icon(CupertinoIcons.xmark, color: colorScheme.primary),
        ),
        title: '${provider.transactionsSelected.length} seleccionados',

        actions: [
          if (isItemSelected)
            IconButton(
              onPressed: () async {
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
      return TitleTabAppbar(
        title: "Movimientos",
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

  // FUNCIÓN PRINCIPAL DE VISUALIZACIÓN DE TRANSACCIONES (REESTRUCTURADA)
  Widget _buildTransactionsView(BuildContext context, String type) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Consumer<TransactionsProvider>(
      builder: (context, provider, child) {
        // 1. Filtrar transacciones
        final allTransactions = provider.transactions
            .where((t) => t.type == type)
            .toList();

        // 2. Agrupar por mes/año y obtener las claves
        final groupedMap = groupTransactionsByMonth(allTransactions);
        final monthKeys = groupedMap.keys.toList();

        final isMultiselectActive = provider.isMultiselectActive;

        // 3. Estados de Carga/Vacío
        if (provider.isLoadingInitial && allTransactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (allTransactions.isEmpty && !provider.isLoadingInitial) {
          return AppEmptyStates(
            asset: 'assets/animations/transactions_empty.svg',
            upText: 'No hay movimientos creados',
            downText:
                'Añade tu primer movimiento y empieza a controlar tus ingresos y gastos de forma personalizada',
            btnText: 'Crear movimiento',
            onPressed: () async {
              _updateNotSelectableUI();

              await _newTransactionShowModal(context, colorScheme);
            },
          );
        }

        // 4. Scroll Infinito y RefreshIndicator
        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadInitialTransactions();
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent * 0.8 &&
                  !provider.isLoadingMore &&
                  provider.hasMore) {
                if (scrollInfo.metrics.axis == Axis.vertical) {
                  provider.loadMoreTransactions();
                  return true;
                }
              }
              return false;
            },

            // EL ListView.builder ahora itera sobre las CLAVES (Meses)
            child: ListView.builder(
              itemCount: monthKeys.length + (provider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // --- A. Lógica de Carga (Spinner al final) ---
                if (index == monthKeys.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                }

                final monthKey = monthKeys[index];
                final monthTransactions = groupedMap[monthKey]!;
                final formattedMonth = _formatMonthYear(monthKey);

                // --- CÁLCULO DINÁMICO DEL RADIO ---
                const double cardHeight = 70.0;
                final double totalHeight =
                    monthTransactions.length * cardHeight;
                const double minRadius = 5.0;
                const double maxRadius = 15.0;
                const double referenceHeight = 400.0;
                double dynamicRadius =
                    (totalHeight / referenceHeight) * (maxRadius - minRadius) +
                    minRadius;
                dynamicRadius = dynamicRadius.clamp(minRadius, maxRadius);
                // --- FIN DEL CÁLCULO ---

                // --- B. Contenedor del Mes (que engloba todos los gastos) ---
                return Padding(
                  padding: const EdgeInsets.only(
                    top: 15.0,
                    left: 8.0,
                    right: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado del Mes (El Divider)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 15.0),
                        child: Text(
                          formattedMonth,
                          style: textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),

                      // CONTENEDOR BLANCO CON BORDES REDONDEADOS DINÁMICOS
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 7.0),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(dynamicRadius),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        // Usa ListView.builder anidado para las transacciones del mes
                        child: ListView.builder(
                          physics:
                              const NeverScrollableScrollPhysics(), // Deshabilita el scroll anidado
                          shrinkWrap:
                              true, // Se ajusta al tamaño de su contenido
                          itemCount: monthTransactions.length,
                          itemBuilder: (context, transactionIndex) {
                            final transaction =
                                monthTransactions[transactionIndex];

                            bool isSelected = provider.transactionsSelected
                                .contains(transaction.transactionId);

                            return _buildSlidableTransactionCard(
                              transaction,
                              isSelected,
                              isMultiselectActive,
                              provider,
                              textTheme,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Widget para construir la tarjeta Slidable (para evitar repetición)
  Widget _buildSlidableTransactionCard(
    TransactionModel transaction,
    bool isSelected,
    bool isMultiselectActive,
    TransactionsProvider provider,
    TextTheme textTheme,
  ) {
    // Si está en multiselección, deshabilitar Slidable
    if (isMultiselectActive) {
      return InkWell(
        onTap: () => provider.toggleTransactionSelection(transaction),
        onLongPress: () => provider.toggleTransactionSelection(transaction),
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
      );
    }

    // Slidable para acciones de swipe
    return Slidable(
      key: ValueKey(transaction.transactionId),
      groupTag: 'transaction_slidable_group',

      // Swipe a la DERECHA (Acción de FINAL) -> Eliminar
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => _onSlideToDelete(context, transaction),
            backgroundColor: Theme.of(context).colorScheme.error, // Rojo
            foregroundColor: Colors.white,
            icon: CupertinoIcons.delete,
            label: 'Eliminar',
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),

      // Swipe a la IZQUIERDA (Acción de INICIO) -> Informe
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) => _onSlideToReport(transaction),
            backgroundColor: Theme.of(context).colorScheme.primary, // Púrpura
            foregroundColor: Colors.white,
            icon: CupertinoIcons.folder,
            label: 'Informe',
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
        ],
      ),

      // Contenido de la tarjeta (Taps normales)
      child: InkWell(
        onLongPress: () {
          // Si no estaba activa la multiselección, la activamos y seleccionamos el item

          provider.toggleTransactionSelection(transaction);
        },
        onTap: () {
          // El Tap normal permite abrir si no está en multiselección
          _showTransaction(context, textTheme, transaction);
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
  }
}
