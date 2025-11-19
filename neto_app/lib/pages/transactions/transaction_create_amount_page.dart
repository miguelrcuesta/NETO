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
  CategoriaGasto? selectedChoiceGasto;
  CategoriaIngreso? selectedChoiceIngreso;
  String? subcategoryGasto;
  String? subcategoryIngreso;
  String? selectedCategoryChoice; // ID (name) de la categoría seleccionada
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

  // Las funciones _updateSelectionGasto e _updateSelectionIngreso ya no son necesarias
  // porque el estado se actualiza directamente en el onSelected del modal.

  void updateSelectedChoice(String categoriaName, String subcategoriaString) {
    if (transactionType == TransactionType.expense.id) {
      setState(() {
        selectedCategoryChoice = categoriaName;
        selectedSubcategoryChoice = subcategoriaString;
      });
    } else {
      setState(() {
        selectedCategoryChoice = categoriaName;
        selectedSubcategoryChoice = subcategoriaString;
      });
    }
  }

  Future<Map<String, String>?> procesarRespuesta(String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);

      final String categoria = data['categoria'].toString();
      final String subcategoria = data['subcategoria'].toString();

      return {'categoria': categoria, 'subcategoria': subcategoria};
    } catch (e) {
      return null;
    }
  }

  // **NOTA:** La función geminiGetCategory usa la clave de forma insegura,
  // esto debe ser corregido con variables de entorno.
  Future<String?> geminiGetCategory(String description) async {
    final String apiKey = "AIzaSyBha_Lty0xq1Fxkc72POAwKTzNghJ7_0Ck";
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    final String prompt = AppStrings.getPromtCategory(description);
    try {
      final response = await model.generateContent([Content.text(prompt)]);
      debugPrint(response.text?.trim());
      return response.text?.trim();
    } catch (e) {
      debugPrint('Error al clasificar con Gemini: $e');
    }

    return null;
  }

  Future<void> obtenerSugerenciaDeCategoria(String descripcion) async {
    Map<String, String>? output;
    if (descripcion.isNotEmpty) {
      if (isLoading) return;

      setState(() {
        isLoading = true;
        sugerenciaGemini = null;
      });

      String? resultado = await geminiGetCategory(descripcion);
      if (resultado != null) {
        output = await procesarRespuesta(resultado);
      }

      setState(() {
        sugerenciaGemini = output;
        isLoading = false;
        if (sugerenciaGemini != null) {
          updateSelectedChoice(sugerenciaGemini!["categoria"]!, sugerenciaGemini!["subcategoria"]!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double amount = double.tryParse(amountString.replaceAll(',', '.')) ?? 0;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Locale currentLocale = AppFormatters.getPlatformLocale();
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
                const SizedBox(height: AppDimensions.spacingExtraLarge),
                _typetransaction(colorScheme, myTabs),
                const SizedBox(height: AppDimensions.spacingExtraLarge),
                _amount(formattedAmount, textTheme, amount, colorScheme, symbol),
                _descriptionamount(textTheme, colorScheme),
                _geminiCategory(textTheme, colorScheme),
                const SizedBox(height: AppDimensions.spacingMedium),
                TransactionKeyBoardWidget(
                  initialAmount: amountString,
                  onAmountChange: _updateAmount,
                ),
                TextButton(
                  onPressed: () {
                    debugPrint(selectedCategoryChoice.toString());
                    debugPrint(selectedSubcategoryChoice.toString());
                  },
                  child: Text("data"),
                ),
              ],
            ),
          ),
        ),
      ),
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: StandarButton(onPressed: () {}, text: "Siguiente"),
        ),
      ],
      persistentFooterDecoration: const BoxDecoration(),
    );
  }

  //#####################################################################################
  // WIDGETS
  //#####################################################################################

  // ⭐️ FUNCION ARREGLADA: EL onPresed DEL TextButton ES ASÍNCRONO ⭐️
  Column _geminiCategory(TextTheme textTheme, ColorScheme colorScheme) {
    // Determinar qué categoría se debe mostrar
    String displayCategory = "Sin categoría";

    if (selectedCategoryChoice != null) {
      // Intenta obtener el nombre legible usando el getter de la extensión (asumiendo su existencia)
      if (transactionType == TransactionType.expense.id) {
        displayCategory =
            CategoriaGasto.getCategoryByName(selectedCategoryChoice!)?.nombre ??
            selectedCategoryChoice!;
      } else {
        displayCategory =
            CategoriaIngreso.getCategoryByName(selectedCategoryChoice!)?.nombre ??
            selectedCategoryChoice!;
      }

      if (selectedSubcategoryChoice != null) {
        displayCategory += " \n$selectedSubcategoryChoice";
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Categoría", style: textTheme.titleSmall),
            TextButton(
              onPressed: () async {
                final selectedChoice = await showModalBottomSheet(
                  context: context,
                  useSafeArea: true,
                  isScrollControlled: true,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, myState) {
                        Widget buildIngresoChips(CategoriaIngreso choice) {
                          // Si queremos que el chip muestre si está seleccionado *antes* de abrir el modal,
                          // usamos la variable del state, pero no es necesario para la corrección del bug.
                          bool isSelected;
                          TextTheme textTheme = Theme.of(context).textTheme;
                          ColorScheme colorScheme = Theme.of(context).colorScheme;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Column(
                              children: [
                                Text(choice.emoji + choice.nombre, style: textTheme.titleSmall),
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
                                          selectedChoiceIngreso = choice;
                                          subcategoryIngreso = choice.subcategorias[index];
                                          debugPrint(subcategoryIngreso);
                                        });
                                        updateSelectedChoice(
                                          selectedChoiceIngreso!.name,
                                          subCategoria,
                                        );
                                        //Navigator.pop(context, choice);
                                      },
                                    );
                                  }),
                                ),
                              ],
                            ),
                          );
                        }

                        Widget buildGastoChips(CategoriaGasto choice) {
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
                                          selectedChoiceGasto = choice;
                                          subcategoryGasto = choice.subcategorias[index];
                                          debugPrint(subcategoryGasto);
                                        });
                                        updateSelectedChoice(
                                          selectedChoiceGasto!.name,
                                          subCategoria,
                                        );
                                        //Navigator.pop(context, choice);
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
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Categorías de Gasto
                                  if (transactionType == TransactionType.expense.id)
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      spacing: 8.0,

                                      children: CategoriaGasto.values
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

                                      children: CategoriaIngreso.values
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

                if (selectedChoice != null) {
                  setState(() {
                    if (selectedChoice is CategoriaGasto) {
                      transactionType = TransactionType.expense.id;
                      updateSelectedChoice(selectedChoiceGasto!.name, "");
                    } else if (selectedChoice is CategoriaIngreso) {
                      transactionType = TransactionType.income.id;
                      updateSelectedChoice(selectedChoiceIngreso!.name, "");
                    }
                  });
                }
              },
              child: Text(
                "Cambiar",
                style: textTheme.bodySmall!.copyWith(color: colorScheme.primary),
              ),
            ),
          ],
        ),
        ListTile(
          //contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
          visualDensity: VisualDensity.comfortable,
          //title: Text("Categoría", style: textTheme.titleSmall),
          title: _geminiCategorySubtitle(
            textTheme,
            colorScheme,
            displayCategory,
          ), // Usamos la nueva variable
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
              await obtenerSugerenciaDeCategoria(value);
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
          Text(
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
          Text(
            symbol,
            style: textTheme.titleLarge!.copyWith(
              fontSize: 30,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
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
              // Resetear la selección al cambiar el tipo (Gasto/Ingreso)
              selectedChoiceGasto = null;
              selectedChoiceIngreso = null;
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
