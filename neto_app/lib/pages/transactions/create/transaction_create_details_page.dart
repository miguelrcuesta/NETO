
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/controllers/transaction_controller.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/services/transactions_services.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:table_calendar/table_calendar.dart';

class TransactionCreateDetailsPage extends StatefulWidget {
  final TransactionModel transactionModel;
  const TransactionCreateDetailsPage({super.key, required this.transactionModel});

  @override
  State<TransactionCreateDetailsPage> createState() => _TransactionCreateDetailsPageState();
}

class _TransactionCreateDetailsPageState extends State<TransactionCreateDetailsPage> {
  //#####################################################################################
  //CONTROLLERS
  //#####################################################################################
  

  //#####################################################################################
  //VARIABLES
  //#####################################################################################
  DateTime transactionDate = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  //#####################################################################################
  //FUNCIONES
  //#####################################################################################

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TransactionController transactionController = TransactionController(service: TransactionService());
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      appBar: TitleAppbarBack(title: appLocalizations.newTransactionTitle),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppDimensions.paddingAllMedium,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _calendar(context, colorScheme, textTheme),
              SizedBox(height: AppDimensions.spacingMedium),
              Container(
                padding: AppDimensions.paddingHorizontalMedium,
                decoration: decorationContainer(
                  context: context,
                  colorFilled: colorScheme.primaryContainer,
                  radius: 10,
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                      minVerticalPadding: 0.0,
                      visualDensity: VisualDensity.comfortable,
                      //title: Text("Categoría", style: textTheme.titleSmall),
                      title: Text(
                        "Importe",
                        style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        widget.transactionModel.amount.toStringAsFixed(2),
                        style: textTheme.titleMedium!.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    Divider(height: 1, color: colorScheme.outline),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                      minVerticalPadding: 0.0,
                      visualDensity: VisualDensity.comfortable,
                      //title: Text("Categoría", style: textTheme.titleSmall),
                      title: Text(
                        "Categoría",
                        style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        widget.transactionModel.category.isEmpty
                            ? "-"
                            : '${widget.transactionModel.category} | ${widget.transactionModel.subcategory}',
                        style: textTheme.titleSmall!.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0,horizontal: 15.0),
          child: StandarButton(
            radius: 200,
            onPressed: () async{
              final updatedTransactionModel = widget.transactionModel.copyWith(
                date: _selectedDay,
                year: _selectedDay.year,
                month: _selectedDay.month,
                userId: 'MIGUEL_USER_ID'
              );
              await transactionController.createNewTransaction( context: context, newTransaction: updatedTransactionModel);
              if (!context.mounted) return;
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            text: "Siguiente",
          ),
        ),
      
    );
  }

  

  Container _calendar(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      height: 400,
      decoration: decorationContainer(
        context: context,
        colorFilled: colorScheme.primaryContainer,
        radius: 10,
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365 * 5)),
        lastDay: DateTime.now().add(const Duration(days: 365)), // Ampliado un año en el futuro

        selectedDayPredicate: (day) {
          // Devuelve TRUE si el día del calendario es el mismo que el día guardado en el estado.
          return isSameDay(_selectedDay, day);
        },

        // 4. LÓGICA AL SELECCIONAR UN DÍA
        onDaySelected: (selectedDay, focusedDay) {
          // Verificamos que el día seleccionado no sea el mismo que ya está guardado
          if (!isSameDay(_selectedDay, selectedDay)) {
            // 5. Actualizamos el estado para reflejar la nueva selección
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay; // Mantener el enfoque actualizado
            });
          }
        },

        // IMPORTANTE: Eliminamos rangeSelectionMode para evitar la selección de rangos.
        // rangeSelectionMode: RangeSelectionMode.disabled, // (o simplemente no lo incluimos)

        // El día que determina qué mes/semana se muestra.
        focusedDay: _focusedDay,

        calendarFormat: CalendarFormat.month,
        locale: 'es_ES',
        pageJumpingEnabled: true,
        startingDayOfWeek: StartingDayOfWeek.monday, // Lunes como inicio de semana
        // ===============================================================
        // ESTILOS (Optimizados y Usando el Tema)
        // ===============================================================
        headerStyle: HeaderStyle(
          titleTextStyle: textTheme.titleSmall!.copyWith(color: colorScheme.onSurface),
          titleCentered: true,
          formatButtonVisible: false,
          leftChevronVisible: true,
          rightChevronVisible: true,
          headerPadding: const EdgeInsets.symmetric(vertical: 8.0),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: textTheme.bodySmall!.copyWith(color: colorScheme.onSurfaceVariant),
          weekendStyle: textTheme.bodySmall!.copyWith(
            color: colorScheme.onSurfaceVariant,
          ), // Fin de semana en rojo
        ),
        calendarStyle: CalendarStyle(
          tablePadding: const EdgeInsets.all(4.0),
          outsideDaysVisible: false,
          isTodayHighlighted: true,

          // Estilo del día de hoy
          todayDecoration: BoxDecoration(
            color: colorScheme.secondary.withAlpha(15), // Un color sutil para hoy
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(color: colorScheme.onSurface),

          // Estilo del día seleccionado (usa el color primario)
          selectedDecoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
          selectedTextStyle: TextStyle(color: colorScheme.onPrimary),

          // Estilo de los números normales de los días
          defaultTextStyle: textTheme.bodyMedium!,
          weekendTextStyle: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurface),

          // Si tienes eventos, aquí irían los marcadores de eventos
          markerDecoration: BoxDecoration(
            color: colorScheme.onSurface, // Color de un marcador de evento
            shape: BoxShape.circle,
            // width y height para el tamaño del marcador
          ),
        ),
      ),
    );
  }
}
