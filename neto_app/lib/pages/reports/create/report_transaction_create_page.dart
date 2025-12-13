import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neto_app/constants/app_enums.dart'; // Para TransactionType, Expenses, Incomes
import 'package:neto_app/constants/app_utils.dart'; // Para AppFormatters
import 'package:neto_app/controllers/reports_controller.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/provider/reports_provider.dart';
import 'package:neto_app/services/api.dart';
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

  //VALORES DE ESTADO MUTABLES
  String selectedTransactionType = TransactionType.expense.id;
  String? selectedCategoryId = Expenses.otrosGastos.id;
  String? selectedCategoryChoice;
  String? selectedSubcategoryChoice;
  TransactionType? transactionType = TransactionType.expense;
  final ReportsController reportsController = ReportsController();
  final Locale currentLocale = AppFormatters.getPlatformLocale();

  //GEMINI
  Map<String, String>? sugerenciaGemini;

  bool isLoading = false;
  bool hasError = false;
  bool hasSuccess = false;

  Timer? _debounceTimer;
  String? descripcion;

  //########################################################################
  // FUNCIONES
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

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El monto es obligatorio.';
    }
    if (double.tryParse(value) == null) {
      return 'Formato de monto inválido.';
    }
    return null;
  }

  void _updateSelectedChoice(
    String idCategory,
    String categoriaName,
    String subcategoriaString,
  ) {
    setState(() {
      selectedCategoryId = idCategory;
      selectedCategoryChoice = categoriaName;
      selectedSubcategoryChoice = subcategoriaString;
    });
  }

  Future<void> fetchNewIACategory(String transactionDescription) async {
    final service = ApiService();
    Map<String, String>? classificationResult;

    // El setState que inicia la carga ya debe estar en obtenerSugerenciaDeCategoria

    try {
      debugPrint('Intentando clasificar: $transactionDescription');
      // Usamos await en la llamada de servicio
      classificationResult = await service.classifyGeminiTransaction(
        transactionDescription,
        currentLocale.languageCode,
      );
    } catch (e) {
      hasError = true;
      hasSuccess = false;
      // Manejo de errores de red o servicio
      debugPrint('⚠️ Error al contactar al servicio de IA: $e');
    }

    // 2. Ejecutamos setState para actualizar la UI con el resultado
    setState(() {
      isLoading = false; // Finaliza la carga

      if (classificationResult != null) {
        final idCategory = classificationResult['idcategoria']!;
        final category = classificationResult['categoria']!;
        final subcategory = classificationResult['subcategoria']!;
        final iaStatus = classificationResult['ia_status']!;

        sugerenciaGemini = classificationResult;
        debugPrint(
          'Clasificación IA recibida: ${classificationResult.toString()}',
        );

        if (iaStatus == 'SUCCESS') {
          debugPrint('✅ Clasificación IA Exitosa: $category / $subcategory');
          hasSuccess = false;
          hasError = false;
          _updateSelectedChoice(
            idCategory,
            category,
            subcategory,
          ); // Asignar a los campos de la UI
        } else {
          hasError = true;
          hasSuccess = false;
          isLoading = false;
          debugPrint('⚠️ Clasificación IA Fallida. Estado: $iaStatus');
        }
      } else {
        sugerenciaGemini = null;
      }
    });
  }

  Future<void> getGeminiCategory(String descripcion) async {
    if (descripcion.isNotEmpty) {
      if (isLoading) return;

      setState(() {
        isLoading = true;
        sugerenciaGemini = null;
      });

      await fetchNewIACategory(descripcion);
    }
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
      categoryId: selectedCategoryId ?? '',
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

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    final Map<String, Widget> myTabs = <String, Widget>{
      TransactionType.expense.id: Text(appLocalizations.typeExpense),
      TransactionType.income.id: Text(appLocalizations.typeIncome),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nuevo movimiento del informe",
          style: textTheme.bodyMedium,
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _amount(textTheme),
                const SizedBox(height: 20),
                _description(textTheme, colorScheme),
                const SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //_buildTransactionTypeSelector(),
                    _widgetType(textTheme, colorScheme, myTabs),
                    Divider(
                      color: colorScheme.outline,
                      thickness: 0.80,
                      height: 30,
                    ),
                    _date(textTheme, context),
                    Divider(
                      color: colorScheme.outline,
                      thickness: 0.80,
                      height: 30,
                    ),
                    _geminiCategory(textTheme, colorScheme),
                  ],
                ),
              ],
            ),
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

  //########################################################################
  // WIDGETS
  //########################################################################
  //=========================================================================
  //CANTIDAD
  //=========================================================================
  Widget _amount(TextTheme textTheme) {
    return StandarTextField(
      enable: true,
      filled: true,
      controller: amountController,
      validator: _amountValidator,
      textInputType: TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      hintText: "0.00",
    );
  }

  //=========================================================================
  //DESCRIPTION
  //=========================================================================
  Widget _description(TextTheme textTheme, ColorScheme colorScheme) {
    //final Duration debounceDuration = const Duration(milliseconds: 500);
    return StandarTextField(
      filled: true,

      paddingContent: EdgeInsets.symmetric(horizontal: 8.0),
      textAlign: TextAlign.start,
      textInputAction: TextInputAction.done,
      onChange: (value) async {
        await getGeminiCategory(value);
        setState(() {
          descripcion = value;
        });
      },
      enable: true,
      controller: descriptionController,
      textInputType: TextInputType.text,
      hintText: "Añade una descripción...",
      textInputTheme: textTheme.bodyMedium!.copyWith(
        color: colorScheme.onSurface,
      ),
      colorFocusBorder: Colors.transparent,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'La descripción es obligatoria';
        }
        return null;
      },
    );
  }

  //=========================================================================
  //FECHA
  //=========================================================================
  Row _date(TextTheme textTheme, BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Fecha",
          style: textTheme.bodyMedium!.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: () async {
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
                            setState(() {
                              selectedDate = tempDate;
                            });
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
            style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  //=========================================================================
  //GEMINI CATEGORY
  //=========================================================================
  Widget _geminiCategory(TextTheme textTheme, ColorScheme colorScheme) {
    String displayCategory = "Sin categoría";

    if (selectedCategoryChoice != null) {
      if (transactionType == TransactionType.expense) {
        displayCategory =
            Expenses.getCategoryById(selectedCategoryChoice!)?.nombre ??
            selectedCategoryChoice!;
      } else {
        displayCategory =
            Incomes.getCategoryById(selectedCategoryChoice!)?.nombre ??
            selectedCategoryChoice!;
      }

      if (selectedSubcategoryChoice != null) {
        displayCategory += "\n$selectedSubcategoryChoice";
      }
    }

    return GestureDetector(
      onTap: () {
        showCustomCupertinoListSheet(context, textTheme, colorScheme);
      },
      child: _categoryAnimation(textTheme, colorScheme, displayCategory),
    );
  }

  Widget _categoryAnimation(
    TextTheme textTheme,
    ColorScheme colorScheme,
    String displayCategory,
  ) {
    if (isLoading) {
      return Row(
            mainAxisSize:
                MainAxisSize.min, // El contenedor se ajusta al contenido
            children: [
              // 1. Icono con un efecto de pulsación sutil
              const Icon(CupertinoIcons.sparkles, size: 18)
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scaleXY(
                    end: 1.1,
                    duration: 800.ms,
                    curve: Curves.easeInOutSine,
                  ),

              const SizedBox(width: 8),

              // 2. Texto de carga con el estilo de shimmer deseado
              Text(
                "Categorizando...",
                style: textTheme.bodyMedium!.copyWith(
                  // Usamos el color principal de la aplicación
                  color: colorScheme.primary,
                ),
              ),
            ],
          )
          // Aplicamos una animación base al Row para controlar la repetición
          .animate(onPlay: (controller) => controller.repeat())
          // Esto es un 'wave' o 'shimmer' continuo que da sensación de actividad
          .custom(
            duration: 1800.ms,
            builder: (context, value, child) {
              // El valor 'value' va de 0.0 a 1.0, lo usamos para desplazar el degradado
              final double wavePosition =
                  value * 2.0 - 1.0; // Recorre de -1.0 a 1.0

              return ShaderMask(
                shaderCallback: (bounds) {
                  // Crea un degradado linear que simula la onda de brillo
                  return LinearGradient(
                    begin: Alignment(wavePosition - 0.5, 0),
                    end: Alignment(wavePosition + 0.5, 0),
                    colors: [
                      colorScheme.primary.withAlpha(70), // Color base
                      colorScheme.primaryContainer.withAlpha(
                        90,
                      ), // Pico del brillo
                      colorScheme.primary.withAlpha(98), // Color base
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds);
                },
                child: child, // El Row (Icono + Texto) es el hijo
              );
            },
          );
    }

    if (selectedCategoryChoice != null) {
      dynamic category = getCategory(selectedCategoryId!, transactionType!.id);
      return Row(
        children: [
          ClipOval(
            child: Container(
              width: 40,
              height: 40,
              color:
                  category?.color.withAlpha(60) ?? colorScheme.onSurfaceVariant,
              child: Icon(
                category.iconData ?? Icons.circle,
                color: category.color ?? colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 10),
          Text(
            displayCategory,
            style: textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: 150,
      child: Text(
        displayCategory,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyMedium!.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  void showCustomCupertinoListSheet(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext dialogContext) {
        // 1. Obtener la lista de categorías basada en el tipo de transacción
        final List categories = (transactionType == TransactionType.expense)
            ? Expenses
                  .values // Asume que esta enum/clase existe
            : Incomes.values; // Asume que esta enum/clase existe

        // 2. StatefulBuilder para manejar el cambio de selección de chips
        return StatefulBuilder(
          builder: (context, myState) {
            // 3. ENVOLVER en Material: Corrige el error "No Material widget found"
            return Material(
              color: CupertinoColors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),

              child: SizedBox(
                child: CupertinoPageScaffold(
                  // Fondo transparente para ver el borde redondeado del Material
                  backgroundColor: CupertinoColors.white,

                  navigationBar: CupertinoNavigationBar(
                    leading: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Atrás", // Corregido a "Atrás"
                        style: textTheme.bodySmall!.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    backgroundColor: CupertinoColors.white,
                    border: const Border(
                      bottom: BorderSide(
                        color: CupertinoColors.systemGrey5,
                        width: 0.0,
                      ),
                    ),
                  ),

                  // 4. BODY: ListView.builder para las secciones
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      // Asume que 'subcategorias' es una propiedad de tu objeto category
                      final List subcategories = category.subcategorias;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Fila de Categoría Principal ---
                            Row(
                              children: [
                                Text(
                                  category.emoji,
                                  style: textTheme.bodyLarge,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category.nombre,
                                  style: textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // --- Chips de Subcategorías ---
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: List.generate(subcategories.length, (
                                j,
                              ) {
                                final String subcategoryName = subcategories[j];
                                final bool isSelected =
                                    selectedSubcategoryChoice ==
                                    subcategoryName;

                                return ActionChip(
                                  labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  padding: EdgeInsets.zero,
                                  label: Text(subcategoryName),

                                  backgroundColor: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.surfaceBright,
                                  labelStyle: textTheme.bodySmall!.copyWith(
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : Colors.grey.shade800,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  onPressed: () {
                                    myState(() {
                                      if (!isSelected) {
                                        _updateSelectedChoice(
                                          category.id,
                                          category.nombre,
                                          subcategoryName,
                                        );
                                      }

                                      debugPrint(selectedCategoryChoice);
                                      debugPrint(selectedSubcategoryChoice);
                                    });

                                    setState(() {
                                      if (!isSelected) {
                                        _updateSelectedChoice(
                                          category.id,
                                          category.nombre,
                                          subcategoryName,
                                        );
                                      }

                                      debugPrint(selectedCategoryChoice);
                                      debugPrint(selectedSubcategoryChoice);
                                    });
                                  },
                                );
                              }),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 12.0),
                              child: Divider(height: 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  //=========================================================================
  //TIPO DE GASTO
  //=========================================================================
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

    //Usamos GestureDetector para capturar el toque rápido (click)
    return GestureDetector(
      onTap: () {
        _showTransactionTypeSheet(context);
      },
      // El child es el contenedor visual
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Tipo de Movimiento:",
            style: textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
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

  Widget _widgetType(
    TextTheme textTheme,
    ColorScheme colorScheme,
    Map<String, Widget> myTabs, // Aunque esta variable no se usa, la mantengo.
  ) {
    final List<TransactionType> items = [
      TransactionType.expense,
      TransactionType.income,
    ];

    // 1. Crear los PopupMenuItems
    // Usaremos el valor TransactionType directamente como el 'value'
    final List<PopupMenuItem<TransactionType>> popupItems = items
        .map<PopupMenuItem<TransactionType>>((TransactionType item) {
          return PopupMenuItem<TransactionType>(
            value: item,
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Asegura que el Row no sea muy ancho
              children: [
                // Icono (rojo/verde)
                Icon(
                  Icons.circle,
                  color: item == TransactionType.expense
                      ? Colors.red
                      : Colors.green,
                  size: 10,
                ),
                const SizedBox(width: 8),
                // Texto del ítem
                Text(
                  item.getName(context),
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        })
        .toList();

    return Row(
      children: [
        // 1. Texto Fijo (Simulando el Leading de ListTile)
        Text(
          "Movimiento",
          style: textTheme.bodyMedium!.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(), // Empuja el PopupMenuButton a la derecha
        // 2.  PopupMenuButton: El widget interactivo
        PopupMenuButton<TransactionType>(
          //  1. Callback de selección: Lo que sucede cuando se elige un ítem
          onSelected: (TransactionType selected) {
            setState(() {
              transactionType = selected;
              selectedCategoryChoice = null;
              selectedSubcategoryChoice = null;
              selectedCategoryId = null;
            });
          },

          //  2. Construye los ítems del menú emergente
          itemBuilder: (BuildContext context) => popupItems,

          //  4. Estilo del menú emergente (para esquinas redondeadas y fondo)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          color: Colors.white, // Fondo del menú emergente
          elevation: 8.0,

          //  3. El CHILD define el botón o área que el usuario toca.
          // Muestra el nombre del tipo de transacción actual.
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                // Muestra el nombre del tipo de transacción actual
                transactionType!.getName(context),
                style: textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 24.0), // Icono de flecha
            ],
          ), // Sombra
          // Opcional: Icono por defecto (si no se especifica 'child')
          // icon: const Icon(Icons.more_vert),
        ),
      ],
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
}
