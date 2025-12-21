import 'dart:async';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';

import 'package:intl/intl.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/controllers/reports_controller.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/pages/transactions/create/transaction_create_details_page.dart';
import 'package:neto_app/provider/reports_provider.dart';
import 'package:neto_app/provider/transaction_provider.dart';

import 'package:neto_app/services/api.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:neto_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

// Si no tienes estos métodos, DEBES implementarlos o el código fallará.

class TransactionDetailsCreatePage extends StatefulWidget {
  final bool isEditable;
  final bool isForReport;
  final TransactionModel? transactionModel;
  final ReportModel? reportModel;
  const TransactionDetailsCreatePage({
    super.key,
    this.transactionModel,
    this.reportModel,
    required this.isEditable,
    required this.isForReport,
  });

  @override
  State<TransactionDetailsCreatePage> createState() =>
      _TransactionDetailsCreatePageState();
}

class _TransactionDetailsCreatePageState
    extends State<TransactionDetailsCreatePage> {
  //#####################################################################################
  //CONTROLLERS
  //#####################################################################################
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _amountFocusNode = FocusNode();
  final ReportsController reportsController = ReportsController();

  //#####################################################################################
  //VARIABLES
  //#####################################################################################
  DateTime selectedDate = DateTime.now();

  //GEMINI
  Map<String, String>? sugerenciaGemini;

  bool isLoading = false;
  bool hasError = false;
  bool hasSuccess = false;
  Timer? _debounceTimer;
  final Locale currentLocale = AppFormatters.getPlatformLocale();

  //BBDD

  NumberFormat numberFormat = NumberFormat.decimalPatternDigits(
    locale: 'es_ES',
    decimalDigits: 2,
  );
  double amount = 0.0;
  String? descripcion;
  String? selectedCategoryId;
  String? selectedCategoryChoice;
  String? selectedSubcategoryChoice;
  TransactionType? transactionType = TransactionType.expense;
  late TransactionModel transactionModel;

  //#####################################################################################
  //FUNCIONES
  //#####################################################################################

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
          updateSelectedChoice(
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

      isLoading = true;
      sugerenciaGemini = null;

      await fetchNewIACategory(descripcion);
    }
  }

  void updateSelectedChoice(
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

  @override
  void initState() {
    transactionModel = widget.transactionModel ?? TransactionModel.empty();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Usamos el FocusScope del contexto actual para solicitar el foco
      FocusScope.of(context).requestFocus(_amountFocusNode);
    });

    //SI ES EDITABLE, ES DECIR YA TIENE DATOS LOS RE
    if (widget.isEditable) {
      final model = widget.transactionModel!;
      // amount
      amount = model.amount;
      // description
      descriptionController.text = model.description ?? '';
      descripcion = model.description;
      //category / subcategory
      selectedCategoryId = model.categoryid;
      selectedCategoryChoice = model.category;
      selectedSubcategoryChoice = model.subcategory;
      // tipo
      transactionType = TransactionType.getById(model.type);

      //Fecha
      selectedDate = widget.transactionModel!.date!;
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TransactionsProvider providerTransaction = context
        .read<TransactionsProvider>();
    final ReportsProvider providerReport = context.read<ReportsProvider>();

    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    final Map<String, Widget> myTabs = <String, Widget>{
      TransactionType.expense.id: Text(appLocalizations.typeExpense),
      TransactionType.income.id: Text(appLocalizations.typeIncome),
    };

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      //appBar: AppBar(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppDimensions.spacingLarge),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        decoration: decorationContainer(
                          context: context,
                          colorFilled: colorScheme.primaryContainer,
                          radius: 10,
                        ),
                        child: _widgetdescription(textTheme, colorScheme),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 15.0,
                        ),
                        decoration: decorationContainer(
                          context: context,
                          colorFilled: colorScheme.primaryContainer,
                          radius: 10,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _widgetType(textTheme, colorScheme, myTabs),
                            Divider(
                              color: colorScheme.outline,
                              thickness: 0.80,
                              height: 30,
                            ),
                            _widgetDate(textTheme, colorScheme, context),
                            Divider(
                              color: colorScheme.outline,
                              thickness: 0.80,
                              height: 30,
                            ),
                            _geminiCategory(textTheme, colorScheme),
                          ],
                        ),
                      ),

                      // const SizedBox(height: 20),

                      // Container(
                      //   width: double.infinity,
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: 20.0,
                      //     vertical: 20.0,
                      //   ),
                      //   decoration: decorationContainer(
                      //     context: context,
                      //     colorFilled: colorScheme.primaryContainer,
                      //     radius: 10,
                      //   ),
                      //   child: _geminiCategory(textTheme, colorScheme),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            15.0,
            0.0,
            15.0,
            MediaQuery.of(context).viewInsets.bottom + 30.0,
          ),
          child: StandarButton(
            radius: 200,
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                debugPrint(
                  'StandarButton pressed on TransactionAmountCreatePage',
                );

                transactionModel = transactionModel.copyWith(
                  amount: widget.transactionModel!.amount,
                  categoryid: selectedCategoryId,
                  category: selectedCategoryChoice,
                  subcategory: selectedSubcategoryChoice,
                  description: descripcion,
                  type: transactionType!.id,
                  date: selectedDate,
                  year: selectedDate.year,
                  month: selectedDate.month,
                  // userId: 'MIGUEL_USER_ID', // NO HACE FALTA YA QUE LO HAGO EN EL
                );

                // LÓGICA DE GUARDADO USANDO EL PROVIDER
                if (widget.isEditable) {
                  await providerTransaction.updateTransaction(
                    context: context,
                    updatedTransaction: transactionModel,
                  );
                } else {
                  //Si es para un informe concreto no hay que añadirlo a transaciones solo al informe
                  if (widget.isForReport) {
                    await providerReport.addTransactionToReport(
                      context: context,
                      report: widget.reportModel!,
                      transactionmodel: transactionModel,
                    );
                  } else {
                    //Si no se añade a gastos/ingresos en general
                    await providerTransaction.addTransaction(
                      context: context,
                      newTransaction: transactionModel,
                    );
                  }
                }

                //Retrocedo dos veces porque son dos pantallas...
                if (!context.mounted) return;
                // Cerramos todos los modales y volvemos a la primera ruta (TransactionsReadPage)
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              }
            },
            text: "Siguiente",
          ),
        ),
      ),
    );
  }

  //#####################################################################################
  // WIDGETS
  //#####################################################################################

  //=========================================================================
  //CATEGORY
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
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),

              child: SizedBox(
                child: CupertinoPageScaffold(
                  // Fondo transparente para ver el borde redondeado del Material
                  backgroundColor: colorScheme.surface,

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

                    backgroundColor: colorScheme.surface,
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
                                  style: textTheme.bodyLarge!.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category.nombre,
                                  style: textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
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
                                      : Colors.transparent,
                                  labelStyle: textTheme.bodySmall!.copyWith(
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
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
                                        updateSelectedChoice(
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
                                        updateSelectedChoice(
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

  //=========================================================================
  //DESCRIPTION
  //=========================================================================
  SizedBox _widgetdescription(TextTheme textTheme, ColorScheme colorScheme) {
    final Duration debounceDuration = const Duration(milliseconds: 1500);
    return SizedBox(
      width: 280,
      child: StandarTextField(
        paddingContent: EdgeInsets.zero,
        textAlign: TextAlign.start,
        textInputAction: TextInputAction.done,
        onChange: (value) async {
          if (_debounceTimer?.isActive ?? false) {
            _debounceTimer!.cancel();
          }
          if (value.isNotEmpty) {
            _debounceTimer = Timer(debounceDuration, () async {
              await getGeminiCategory(value);
            });
          }
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
      ),
    );
  }

  //=========================================================================
  //TYPE OF TRANSACTIION
  //=========================================================================
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

  //=========================================================================
  //DATE
  //=========================================================================
  Widget _widgetDate(
    TextTheme textTheme,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
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
                            selectedDate = tempDate;
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
                          debugPrint(selectedDate.toIso8601String());
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
}
