import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🔑 Importar Provider
import 'package:neto_app/provider/transaction_provider.dart'; // 🔑 Importar el Provider
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/controllers/transaction_controller.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/services/transactions_services.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:table_calendar/table_calendar.dart';

// Nota: AppDimensions se mantiene como placeholder asumiendo que existe en app_utils.dart

class TransactionCreateDetailsPage extends StatefulWidget {
  final bool isEditable;
  final TransactionModel transactionModel;
  const TransactionCreateDetailsPage({
    super.key,
    required this.transactionModel,
    required this.isEditable,
  });

  @override
  State<TransactionCreateDetailsPage> createState() =>
      _TransactionCreateDetailsPageState();
}

class _TransactionCreateDetailsPageState
    extends State<TransactionCreateDetailsPage> {
  //#####################################################################################
  // VARIABLES
  //#####################################################################################
  DateTime transactionDate = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // El TransactionController se mantiene para la lógica de la API, pero el Provider actualizará la UI.
  final TransactionController transactionController = TransactionController();

  //#####################################################################################
  // FUNCIONES
  //#####################################################################################

  @override
  void initState() {
    super.initState();
    // Inicializar el calendario con la fecha de la transacción si está en modo edición
    if (widget.isEditable && widget.transactionModel.date != null) {
      _selectedDay = widget.transactionModel.date!;
      _focusedDay = _selectedDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TransactionsProvider provider = context.read<TransactionsProvider>();

    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    //AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppDimensions
                .paddingAllMedium, // Asumiendo AppDimensions existe
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _calendar(context, colorScheme, textTheme),
                SizedBox(
                  height: AppDimensions.spacingMedium,
                ), // Asumiendo AppDimensions existe
                Container(
                  padding: AppDimensions
                      .paddingHorizontalMedium, // Asumiendo AppDimensions existe
                  decoration: decorationContainer(
                    context: context,
                    colorFilled: colorScheme.primaryContainer,
                    radius: 10,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0.0,
                        ),
                        minVerticalPadding: 0.0,
                        visualDensity: VisualDensity.comfortable,
                        title: Text(
                          "Importe",
                          style: textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          // Usamos el formatter para mostrar el importe local
                          widget.transactionModel.amount.toString(),
                          style: textTheme.titleMedium!.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Divider(height: 1, color: colorScheme.outline),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0.0,
                        ),
                        minVerticalPadding: 0.0,
                        visualDensity: VisualDensity.comfortable,
                        title: Text(
                          "Categoría",
                          style: textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          widget.transactionModel.category.isEmpty
                              ? "-"
                              : '${widget.transactionModel.category} | ${widget.transactionModel.subcategory}',
                          style: textTheme.titleSmall!.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
        child: StandarButton(
          radius: 200,
          onPressed: () async {
            final newTransactionModel = widget.transactionModel.copyWith(
              date: _selectedDay,
              year: _selectedDay.year,
              month: _selectedDay.month,
              userId:
                  'MIGUEL_USER_ID', // Asegúrate de que este ID sea el correcto
            );

            // 🔑 LÓGICA DE GUARDADO USANDO EL PROVIDER 🔑
            if (widget.isEditable) {
              await provider.updateTransaction(
                context: context,
                updatedTransaction: newTransactionModel,
              );
            } else {
              await provider.addTransaction(
                context: context,
                newTransaction: newTransactionModel,
              );
            }

            if (!context.mounted) return;
            // Cerramos todos los modales y volvemos a la primera ruta (TransactionsReadPage)
            Navigator.of(
              context,
              rootNavigator: true,
            ).popUntil((route) => route.isFirst);
          },
          text: "Guardar",
        ),
      ),
    );
  }

  // ... (El widget _calendar se mantiene sin cambios) ...

  Container _calendar(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      height: 400,
      decoration: decorationContainer(
        context: context,
        colorFilled: colorScheme.primaryContainer,
        radius: 10,
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365 * 5)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        locale: 'es_ES',
        pageJumpingEnabled: true,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          titleTextStyle: textTheme.titleSmall!.copyWith(
            color: colorScheme.onSurface,
          ),
          titleCentered: true,
          formatButtonVisible: false,
          leftChevronVisible: true,
          rightChevronVisible: true,
          headerPadding: const EdgeInsets.symmetric(vertical: 8.0),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: textTheme.bodySmall!.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          weekendStyle: textTheme.bodySmall!.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        calendarStyle: CalendarStyle(
          tablePadding: const EdgeInsets.all(4.0),
          outsideDaysVisible: false,
          isTodayHighlighted: true,
          todayDecoration: BoxDecoration(
            color: colorScheme.secondary.withAlpha(15),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(color: colorScheme.onSurface),
          selectedDecoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(color: colorScheme.onPrimary),
          defaultTextStyle: textTheme.bodyMedium!,
          weekendTextStyle: textTheme.bodyMedium!.copyWith(
            color: colorScheme.onSurface,
          ),
          markerDecoration: BoxDecoration(
            color: colorScheme.onSurface,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
