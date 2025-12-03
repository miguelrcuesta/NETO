import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_enums.dart'; // Para TransactionType, Expenses, Incomes
import 'package:neto_app/constants/app_utils.dart'; // Para AppFormatters
import 'package:neto_app/controllers/reports_controller.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/provider/reports_provider.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:provider/provider.dart';

class ReportTransactionCreatePage extends StatefulWidget {
  final ReportModel reportModel;

  const ReportTransactionCreatePage({super.key, required this.reportModel});

  @override
  State<ReportTransactionCreatePage> createState() =>
      _ReportTransactionCreatePageState();
}

class _ReportTransactionCreatePageState
    extends State<ReportTransactionCreatePage> {
  //########################################################################
  // VARIABLES Y CONTROLADORES
  //########################################################################

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  // 🔑 VALORES DE ESTADO MUTABLES
  String selectedTransactionType = TransactionType.expense.id;
  String selectedCategoryId = Expenses.otrosGastos.id;

  final ReportsController reportsController = ReportsController();

  //########################################################################
  // FUNCIONES DE GESTIÓN DE ESTADO Y GUARDADO
  //########################################################################

  /// Función para actualizar el tipo y la categoría por defecto
  void _updateTransactionType(String newType) {
    setState(() {
      selectedTransactionType = newType;

      // Lógica para reestablecer la categoría por defecto al cambiar el tipo
      if (newType == TransactionType.expense.id) {
        selectedCategoryId = Expenses.otrosGastos.id;
      } else {
        selectedCategoryId = Incomes.salario.id;
      }
    });
  }

  String? _validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }
    return null;
  }

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El monto es obligatorio.';
    }
    if (double.tryParse(value) == null) {
      return 'Formato de monto inválido.';
    }
    return null;
  }

  Future<void> _saveTransaction() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final provider = context.read<ReportsProvider>();
    final double amount = double.parse(amountController.text.trim());

    final String newTransactionId = reportsController
        .getUniqueReportTransactionId();

    final ReportTransactionModel newReportTransaction = ReportTransactionModel(
      reportTransactionId: newTransactionId,
      reportId: widget.reportModel.reportId,
      amount: amount,
      description: descriptionController.text.trim(),
      date: selectedDate,
      typeId: selectedTransactionType,
      categoryId: selectedCategoryId,
    );

    await provider.addManualReportTransaction(
      context: context,
      report: widget.reportModel,
      newTransaction: newReportTransaction,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  //########################################################################
  // WIDGETS
  //########################################################################

  Widget _buildTransactionTypeSelector() {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    // Define el estado actual
    final bool isExpense =
        selectedTransactionType == TransactionType.expense.id;
    final Color typeColor = isExpense
        ? Colors.red.shade700
        : Colors.green.shade700;
    final String typeName = isExpense ? 'Gasto' : 'Ingreso';
    final IconData typeIcon = isExpense
        ? CupertinoIcons.circle_fill
        : CupertinoIcons.circle_fill;

    // 🔑 Usamos GestureDetector para capturar el toque rápido (click)
    return GestureDetector(
      onTap: () {
        _showTransactionTypeSheet(context);
      },
      // El child es el contenedor visual
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Tipo de Movimiento:", style: textTheme.bodyMedium),
          Row(
            children: [
              Icon(typeIcon, color: typeColor, size: 11),
              const SizedBox(width: 8),
              Text(
                typeName,
                style: textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.chevron_down,
                size: 16,
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///Función que muestra el CupertinoActionSheet al hacer un toque rápido
  void _showTransactionTypeSheet(BuildContext context) {
    final bool isExpense =
        selectedTransactionType == TransactionType.expense.id;
    final String oppositeType = isExpense
        ? TransactionType.income.id
        : TransactionType.expense.id;
    final String oppositeTypeName = isExpense ? 'Ingreso' : 'Gasto';
    final Color oppositeColor = isExpense
        ? Colors.green.shade700
        : Colors.red.shade700;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext sheetContext) => CupertinoActionSheet(
        title: const Text('Cambiar Tipo de Movimiento'),
        actions: <CupertinoActionSheetAction>[
          // Opción para cambiar al tipo opuesto
          CupertinoActionSheetAction(
            onPressed: () {
              _updateTransactionType(oppositeType);
              Navigator.pop(sheetContext);
            },
            child: Text(
              'Cambiar a $oppositeTypeName',
              style: TextStyle(color: oppositeColor, fontSize: 18),
            ),
          ),
        ],
        // Botón de Cancelar
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(sheetContext);
          },
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo Movimiento"),
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _amount(textTheme),
              const SizedBox(height: 20),

              _descripcion(textTheme),
              const SizedBox(height: 20),

              _date(textTheme, context),
              const SizedBox(height: 10),

              _buildTransactionTypeSelector(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          15.0,
          0.0,
          15.0,
          MediaQuery.of(context).viewInsets.bottom + 30.0,
        ),
        child: SafeArea(
          child: StandarButton(
            onPressed: _saveTransaction,
            text: "Añadir al informe",
            radius: 50,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Column _amount(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Monto:", style: textTheme.bodyMedium),
        StandarTextField(
          enable: true,
          filled: true,
          controller: amountController,
          validator: _amountValidator,
          textInputType: TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          hintText: "0.00",
        ),
      ],
    );
  }

  Column _descripcion(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Descripción:", style: textTheme.bodyMedium),
        StandarTextField(
          enable: true,
          filled: true,
          controller: descriptionController,
          validator: _validator,
          hintText: "Añade una descripción",
          textInputAction: TextInputAction.done,
          textInputType: TextInputType.text,
        ),
      ],
    );
  }

  Row _date(TextTheme textTheme, BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Fecha:", style: textTheme.bodyMedium),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
          decoration: decorationContainer(
            context: context,
            colorFilled: colorScheme.surface,
            radius: 100,
          ),
          child: TextButton(
            onPressed: () async {
              DateTime tempDate = selectedDate;

              await showCupertinoModalPopup(
                context: context,
                builder: (BuildContext pickerContext) {
                  return Container(
                    height: 310,
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 250,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: selectedDate,
                            maximumDate: DateTime.now(),
                            onDateTimeChanged: (DateTime newDate) {
                              tempDate = newDate;
                            },
                          ),
                        ),
                        CupertinoButton(
                          child: const Text('Aceptar'),
                          onPressed: () {
                            setState(() {
                              selectedDate = tempDate;
                            });
                            Navigator.pop(pickerContext);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Text(
              AppFormatters.customDateFormatShort(selectedDate),
              style: textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
