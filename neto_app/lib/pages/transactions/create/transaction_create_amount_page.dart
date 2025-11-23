import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:neto_app/constants/app_strings.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/constants/app_enums.dart'; // Asumimos que aquí están tus enums
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/pages/transactions/create/transaction_create_details_page.dart';
import 'package:neto_app/services/api.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:neto_app/widgets/widgets.dart';

// Si no tienes estos métodos, DEBES implementarlos o el código fallará.

class TransactionAmountCreatePage extends StatefulWidget {
  const TransactionAmountCreatePage({super.key});

  @override
  State<TransactionAmountCreatePage> createState() => _TransactionAmountCreatePageState();
}

class _TransactionAmountCreatePageState extends State<TransactionAmountCreatePage> {
  //#####################################################################################
  //CONTROLLERS
  //#####################################################################################
  TextEditingController descriptionTransactiontextController = TextEditingController();

  //#####################################################################################
  //VARIABLES
  //#####################################################################################
  String amountString = '';
  String transactionType = TransactionType.expense.id;
  Map<String, String>? sugerenciaGemini;

  final Locale currentLocale = AppFormatters.getPlatformLocale();

  String? subcategoryGasto;
  String? subcategoryIngreso;
  String? selectedCategoryChoice;
  String? selectedSubcategoryChoice;
  bool isLoading = false;
  Timer? _debounceTimer;

  //#####################################################################################
  //FUNCIONES
  //#####################################################################################

  void _updateAmount(String newAmount) {
    setState(() {
      amountString = newAmount;
    });
  }

  Future<void> fetchNewIACategory(String transactionDescription) async {
    final service = TransactionService();
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
      // Manejo de errores de red o servicio
      debugPrint('⚠️ Error al contactar al servicio de IA: $e');
    }

    // 2. Ejecutamos setState para actualizar la UI con el resultado
    setState(() {
      isLoading = false; // Finaliza la carga

      if (classificationResult != null) {
        final category = classificationResult['categoria']!;
        final subcategory = classificationResult['subcategoria']!;
        final iaStatus = classificationResult['ia_status']!;

        sugerenciaGemini = classificationResult;

        if (iaStatus == 'SUCCESS') {
          debugPrint('✅ Clasificación IA Exitosa: $category / $subcategory');
          updateSelectedChoice(category, subcategory); // Asignar a los campos de la UI
        } else {
          isLoading=false;
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

  void updateSelectedChoice(String categoriaName, String subcategoriaString) {
    setState(() {
      selectedCategoryChoice = categoriaName;
      selectedSubcategoryChoice = subcategoriaString;
    });
  }

  @override
  Widget build(BuildContext context) {
    TransactionModel transactionModel = TransactionModel.empty();
    final double amount = double.tryParse(amountString.replaceAll(',', '.')) ?? 0;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final amountFormatter = AppFormatters.getLocalizedNumberFormatterByLocale(currentLocale);
    final String symbol = AppFormatters.getCurrencySymbolByLocale(currentLocale);

    String formattedAmount;

    if (amountString.isEmpty) {
      formattedAmount = amountFormatter.format(amount);
    } else if (amountString.contains('.') && amountString.split('.').length == 2) {
      formattedAmount = amountString;
      formattedAmount = amountFormatter.format(amount);
    } else {
      formattedAmount = amountString;
    }

    final Map<String, Widget> myTabs = <String, Widget>{
      TransactionType.expense.id: Text(appLocalizations.typeExpense),
      TransactionType.income.id: Text(appLocalizations.typeIncome),
    };

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      appBar: TitleAppbarBack(title: appLocalizations.newTransactionTitle),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppDimensions.spacingMedium),
                _typetransaction(colorScheme, myTabs),
                const SizedBox(height: AppDimensions.spacingExtraLarge),
                _amount(formattedAmount, textTheme, amount, colorScheme, symbol),
                _descriptionamount(textTheme, colorScheme),
                const SizedBox(height: AppDimensions.spacingSmall),
                _geminiCategory(textTheme, colorScheme),
                const SizedBox(height: AppDimensions.spacingExtraLarge),
                TransactionKeyBoardWidget(
                  initialAmount: amountString,
                  onAmountChange: _updateAmount,
                ),
                
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0,horizontal: 15.0),
          child: StandarButton(
            radius: 200,
            onPressed: () {
              transactionModel = transactionModel.copyWith(
                amount: amount,
                category: selectedCategoryChoice,
                subcategory: selectedSubcategoryChoice,
              );

              Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      TransactionCreateDetailsPage(transactionModel: transactionModel),
                ),
              );
            },
            text: "Siguiente",
          ),
        ),
    );
  }

  //#####################################################################################
  // WIDGETS
  //#####################################################################################

  Row _geminiCategory(TextTheme textTheme, ColorScheme colorScheme) {
    // Determinar qué categoría se debe mostrar
    String displayCategory = "Sin categoría";

    if (selectedCategoryChoice != null) {
      // Intenta obtener el nombre legible usando el getter de la extensión (asumiendo su existencia)
      if (transactionType == TransactionType.expense.id) {
        displayCategory =
            Expenses.getCategoryById(selectedCategoryChoice!)?.nombre ?? selectedCategoryChoice!;
      } else {
        displayCategory =
            Incomes.getCategoryById(selectedCategoryChoice!)?.nombre ?? selectedCategoryChoice!;
      }

      if (selectedSubcategoryChoice != null) {
        displayCategory += " \n$selectedSubcategoryChoice";
      }
    }

    return Row(
      children: [
        
        
        Expanded(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
            minVerticalPadding: 0.0,
            visualDensity: VisualDensity.compact,
            //title: Text("Categoría", style: textTheme.titleSmall),
            title: _geminiCategorySubtitle(
              textTheme,
              colorScheme,
              displayCategory,
            ), // Usamos la nueva variable
          ),
        ),
        TextButton(
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              useSafeArea: true,
              isScrollControlled: true,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, myState) {
                    Widget buildIngresoChips(Incomes choice) {
                      // Si queremos que el chip muestre si está seleccionado *antes* de abrir el modal,
                      // usamos la variable del state, pero no es necesario para la corrección del bug.
                      bool isSelected;
                      TextTheme textTheme = Theme.of(context).textTheme;
                      ColorScheme colorScheme = Theme.of(context).colorScheme;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${choice.emoji} ${choice.nombre}", style: textTheme.titleMedium),
                            SizedBox(height: AppDimensions.spacingMedium),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: List.generate(choice.subcategorias.length, (index) {
                                String subCategoria = choice.subcategorias[index];
                                isSelected = subcategoryIngreso == choice.subcategorias[index];
                                return ActionChip(
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                                  padding: EdgeInsets.zero,
                                  label: Text(subCategoria),
        
                                  backgroundColor: isSelected
                                      ? colorScheme.primaryContainer
                                      : colorScheme.surfaceBright,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? colorScheme.primary
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
                                      subcategoryIngreso = choice.subcategorias[index];
                                      updateSelectedChoice(
                                        choice.nombre,
                                        choice.subcategorias[index],
                                      );
                                      debugPrint(choice.nombre);
                                      debugPrint(choice.subcategorias[index]);
                                    });
        
                                    //Navigator.pop(context, choice);
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    }
        
                    Widget buildGastoChips(Expenses choice) {
                      // Si queremos que el chip muestre si está seleccionado *antes* de abrir el modal,
                      // usamos la variable del state, pero no es necesario para la corrección del bug.
                      bool isSelected;
                      TextTheme textTheme = Theme.of(context).textTheme;
                      ColorScheme colorScheme = Theme.of(context).colorScheme;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(choice.emoji + choice.nombre, style: textTheme.titleMedium),
                            SizedBox(height: AppDimensions.spacingMedium),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: List.generate(choice.subcategorias.length, (index) {
                                isSelected = subcategoryGasto == choice.subcategorias[index];
                                String subCategoria = choice.subcategorias[index];
        
                                return ActionChip(
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                                  padding: EdgeInsets.zero,
                                  label: Text(subCategoria),
        
                                  backgroundColor: isSelected
                                      ? colorScheme.primaryContainer
                                      : colorScheme.surface,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : Colors.grey.shade400, // Color del borde
                                      width: isSelected ? 1.5 : 1.0, // Grosor del borde
                                    ),
                                  ),
                                  onPressed: () {
                                    myState(() {
                                      subcategoryGasto = choice.subcategorias[index];
                                      updateSelectedChoice(
                                        choice.nombre,
                                        choice.subcategorias[index],
                                      );
        
                                      debugPrint(choice.nombre);
                                      debugPrint(choice.subcategorias[index]);
                                    });
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    }
        
                    return Scaffold(
                      appBar: TitleAppbarBack(title: "Elige una categoría"),
                      body: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          // Se usa mainAxisSize.min para ajustar la altura al contenido
                          child: Column(
                             
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Categorías de Gasto
                              if (transactionType == TransactionType.expense.id)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8.0,
        
                                  children: Expenses.values
                                      .map(
                                        (categoria) => buildGastoChips(categoria),
                                      ) // Llama a la función que crea el Chip
                                      .toList(),
                                ),
                              // Categorías de Ingreso
                              if (transactionType == TransactionType.income.id)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8.0,
        
                                  children: Incomes.values
                                      .map(
                                        (categoria) => buildIngresoChips(categoria),
                                      ) // Llama a la función que crea el Chip
                                      .toList(),
                                ),
        
                              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
          child: Text(
            "Cambiar",
            style: textTheme.bodySmall!.copyWith(color: colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _geminiCategorySubtitle(
    TextTheme textTheme,
    ColorScheme colorScheme,
    String displayCategory,
  ) {
    // Lógica para mostrar la categorización de Gemini o la selección del usuario
    if (isLoading) {
      return Row(
            children: [
              const Icon(CupertinoIcons.sparkles, size: 18),
              Text(
                "Categorizando...",
                style: textTheme.titleSmall!.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 1500.ms, color: colorScheme.surface, blendMode: BlendMode.colorDodge)
          .fadeIn(duration: 800.ms, curve: Curves.easeOut)
          .then(delay: 100.ms)
          .fadeOut(duration: 800.ms, curve: Curves.easeIn);
    }

    if (selectedCategoryChoice != null || (sugerenciaGemini != null)) {
      return Row(
        children: [
          const Icon(CupertinoIcons.sparkles, size: 18),
          const SizedBox(width: 4),
          Text(
            displayCategory,
            style: textTheme.titleSmall!.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      );
    }

    return Text(
      "Sin categoría",
      style: textTheme.titleSmall!.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }

  SizedBox _descriptionamount(TextTheme textTheme, ColorScheme colorScheme) {
    final Duration debounceDuration = const Duration(milliseconds: 500);
    return SizedBox(
      width: 280,
      child: SmallTextField(
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
        },
        enable: true,
        controller: descriptionTransactiontextController,
        textInputType: TextInputType.text,
        hintText: "supermercado",
        textAlign: TextAlign.center,
        textInputTheme: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant),
        colorFocusBorder: Colors.transparent,
      ),
    );
  }

  SizedBox _amount(
    String formattedAmount,
    TextTheme textTheme,
    double amount,
    ColorScheme colorScheme,
    String symbol,
  ) {
    return SizedBox(
      width: 350,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            width: 280,
            child: Text(
              formattedAmount,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: amountString.isNotEmpty
                  ? textTheme.titleLarge!.copyWith(
                      fontSize: AppDimensions.getFontSizeByLength(amount),
                      fontWeight: FontWeight.bold,
                    )
                  : textTheme.titleLarge!.copyWith(
                      fontSize: AppDimensions.getFontSizeByLength(amount),
                      color: colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
          // Text(
          //   symbol,
          //   style: textTheme.titleLarge!.copyWith(
          //     fontSize: 30,
          //     color: colorScheme.onSurfaceVariant,
          //   ),
          // ),
        ],
      ),
    );
  }

  SizedBox _typetransaction(ColorScheme colorScheme, Map<String, Widget> myTabs) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<String>(
        proportionalWidth: true,
        groupValue: transactionType,
        thumbColor: colorScheme.primaryContainer,
        backgroundColor: Colors.grey.shade200,
        children: myTabs,
        onValueChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              transactionType = newValue;
              selectedCategoryChoice = null;
              selectedSubcategoryChoice = null;
            });
          }
          debugPrint(transactionType.toString());
        },
      ),
    );
  }
}
