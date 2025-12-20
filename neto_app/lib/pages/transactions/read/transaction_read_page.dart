import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/provider/reports_provider.dart';
import 'package:neto_app/provider/transaction_provider.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:provider/provider.dart'; //FloatingImportar Provider
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/controllers/reports_controller.dart';
import 'package:neto_app/controllers/transaction_controller.dart'; // Mantenemos el Controller para funciones que no son de estado (ej: reportes)
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:neto_app/widgets/widgets.dart';

class TransactionReadPage extends StatefulWidget {
  final TransactionModel transactionModel;
  final bool? readFromReport;

  const TransactionReadPage({
    super.key,
    required this.transactionModel,
    this.readFromReport,
  });

  @override
  State<TransactionReadPage> createState() => _TransactionReadPageState();
}

class _TransactionReadPageState extends State<TransactionReadPage> {
  //########################################################################
  // CONTROLLERS
  //########################################################################
  ReportsController reportController = ReportsController();

  // Mantenemos una instancia si la necesitamos para funciones auxiliares no relacionadas con el estado (ej: multi-select de reportes si se necesita)
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
      //Asumo que Expenses.getCategoryById existe
      return Expenses.getCategoryById(id);
    } else {
      // Asumo que Incomes.getCategoryById existe
      return Incomes.getCategoryById(id);
    }
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

    // Obtenemos una referencia al Provider (listen: false) para disparar acciones
    final provider = context.read<TransactionsProvider>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                        color: colorScheme.onSurfaceVariant,
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
                        fontSize: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLarge),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    minVerticalPadding: 0.0,
                    visualDensity: VisualDensity.comfortable,
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
                  // ... (ListTile de Fecha sin cambios) ...
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    minVerticalPadding: 0.0,
                    visualDensity: VisualDensity.comfortable,
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
                  // ... (ListTile de Importe sin cambios) ...
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    minVerticalPadding: 0.0,
                    visualDensity: VisualDensity.comfortable,
                    title: Text(
                      "Tipo de movimiento",
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      TransactionType.getById(
                            widget.transactionModel.type,
                          )?.getName(context) ??
                          "-",
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              if (widget.readFromReport == false)
                StandarButton(
                  radius: 50,
                  backgroundColor: colorScheme.primary,
                  textColor: colorScheme.onPrimary,
                  text: "Añadir a un informe",
                  onPressed: () {
                    final TransactionModel currentTransaction =
                        widget.transactionModel;

                    // Muestra el modal de selección de informes
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext modalContext) {
                        //FloatingLa lógica del ReportSelectionModal

                        // // El ReportsProvider ya debería estar cargado
                        // // Usamos modalContext para Consumer
                        // final ReportsProvider provider = modalContext
                        //     .read<ReportsProvider>();

                        return Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Seleccionar informe",
                                style: textTheme.titleMedium,
                              ),
                              Divider(color: colorScheme.outline),
                              Expanded(
                                //FloatingUsamos Consumer para escuchar los cambios del ReportsProvider
                                child: Consumer<ReportsProvider>(
                                  builder: (context, provider, child) {
                                    final reports = provider.reports;

                                    if (provider.isLoadingInitial &&
                                        reports.isEmpty) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
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
                                                  rt.description ==
                                                      currentTransaction
                                                          .description &&
                                                  rt.amount ==
                                                      currentTransaction.amount,
                                            );

                                        return Padding(
                                          padding: EdgeInsetsGeometry.symmetric(
                                            vertical: 10,
                                          ),
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
                                                transactionmodel:
                                                    currentTransaction, // Objeto completo
                                              );

                                              if (!context.mounted) return;
                                              // 3. Cerrar el modal
                                              Navigator.pop(modalContext);
                                            },
                                            child: ReportCard(
                                              upText: report.name,
                                              // Mostrar el número de transacciones incrustadas
                                              dateText:
                                                  report
                                                          .reportTransactions
                                                          .length ==
                                                      1
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
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 10),

              // Botón Eliminar usando el Provider
              if (widget.readFromReport == false)
                TextButton(
                  onPressed: () async {
                    debugPrint("Eliminar movimiento");

                    // Llamar al método del Provider para eliminar y notificar a la UI
                    await provider.deleteTransaction(
                      context: context,
                      id: widget.transactionModel.transactionId!,
                    );

                    if (!context.mounted) return;
                    // Volver a la pantalla anterior (TransactionsReadPage)
                    // El TransactionsReadPage se actualizará automáticamente gracias al notifyListeners()
                    Navigator.pop(context, true);
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
}
