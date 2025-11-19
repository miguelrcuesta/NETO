import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_strings.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class TransactionCreateDetailsPage extends StatefulWidget {
  const TransactionCreateDetailsPage({super.key});

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
  CategoriaGasto? _selectedChoice;
  String? sugerenciaGemini;
  bool isLoading = false;

  //#####################################################################################
  //FUNCIONES
  //#####################################################################################

  // Función que se llama cuando se selecciona un chip.
  void _updateSelection(CategoriaGasto choice) {
    setState(() {
      _selectedChoice = choice;
    });
  }

  Future<String?> geminiGetCategory(String description) async {
    // 1. Inicializar el modelo con tu clave API
    // IMPORTANTE: Reemplaza con una variable de entorno
    final String apiKey = "AIzaSyBha_Lty0xq1Fxkc72POAwKTzNghJ7_0Ck";
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    // 2. Construir el prompt con el diccionario de categorías (como definimos antes)

    final String prompt = AppStrings.getPromtCategory(description);
    try {
      final response = await model.generateContent([Content.text(prompt)]);

      debugPrint(response.text?.trim());
      return response.text?.trim();
      // if (jsonString != null && jsonString.isNotEmpty) {
      //   // Intenta parsear el JSON y convertirlo a un Map
      //   final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      //   return EtiquetaMovimiento.fromJson(jsonMap);
      // }
    } catch (e) {
      debugPrint('Error al clasificar con Gemini: $e');
    }

    return null; // Retorna nulo si hay un error
  }

  Future<void> obtenerSugerenciaDeCategoria(String descripcion) async {
    // Aseguramos que solo haya una llamada activa
    if (isLoading) return;

    // 1. Iniciamos la carga y limpiamos la sugerencia anterior
    setState(() {
      isLoading = true;
      sugerenciaGemini = null;
    });

    // 2. Llamamos a la función asíncrona
    String? resultado = await geminiGetCategory(descripcion);

    // 3. Actualizamos el estado con el resultado
    setState(() {
      sugerenciaGemini = resultado;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      appBar: TitleAppbarBack(title: appLocalizations.newTransactionTitle),
      body: Padding(
        padding: AppDimensions.paddingAllMedium,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 350,
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: CategoriaGasto.values.length,
                itemBuilder: (context, index) {
                  List list = CategoriaGasto.values
                      .map((choice) => buildGastoChips(choice))
                      .toList();
                  return list[index];
                },
                // spacing: 8.0,
                // children: CategoriaGasto.values.map((choice) => buildGastoChips(choice)).toList(),
              ),
            ),
            TextField(
              onSubmitted: (descripcion) async {
                // Llama a la función al presionar Enter/Done
                await obtenerSugerenciaDeCategoria(descripcion);
              },
              // ... otras propiedades
            ),
            //_calendar(context, colorScheme, textTheme),
            if (isLoading) const CircularProgressIndicator(),
            if (sugerenciaGemini != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Sugerencia de Gemini: ${sugerenciaGemini!}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            if (sugerenciaGemini != null)
              ElevatedButton(
                onPressed: () {
                  // Lógica para aplicar la categoría y subcategoría a tu formulario
                  debugPrint('Aplicando categoría: ${sugerenciaGemini!}');
                },
                child: const Text('Aplicar Sugerencia'),
              ),
          ],
        ),
      ),
    );
  }

  Container _calendar(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: decorationContainer(
        context: context,
        colorFilled: colorScheme.primaryContainer,
        radius: 10,
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 100)),
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

  Widget buildGastoChips(CategoriaGasto choice) {
    final bool isSelected = _selectedChoice == choice;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        labelPadding: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.zero,
        label: Text(choice.emoji + choice.nombre),
        selected: isSelected,
        selectedColor: colorScheme.primary,
        backgroundColor: Colors.grey.shade300,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade800,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.all(Radius.circular(20))),
        onSelected: (selected) {
          // Solo actualizamos la selección si el chip fue tocado (selected es true).
          if (selected) {
            _updateSelection(choice);
          }
        },
      ),
    );
  }
}
