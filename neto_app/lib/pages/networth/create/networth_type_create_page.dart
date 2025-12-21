import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/provider/networth_provider.dart';
import 'package:neto_app/provider/shared_preferences_provider.dart';
import 'package:neto_app/provider/user_provider.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:neto_app/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';

//IMPORTS NECESARIOS para la lógica del Provider
import 'package:provider/provider.dart';

import 'package:neto_app/models/networth_model.dart'; // Clase BalanceHistory

// =========================================================================
// WIDGETS
// =========================================================================

class FormModal extends StatefulWidget {
  final NetWorthAssetType assetType;
  const FormModal({super.key, required this.assetType});

  @override
  State<FormModal> createState() => _FormModalState();
}

class _FormModalState extends State<FormModal> {
  //========================================================================
  // CONTROLLERS
  //========================================================================
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String currency;

  @override
  void initState() {
    super.initState();
    amountController.addListener(_replaceCommaWithDot);
    setState(() {
      currency = Provider.of<SettingsProvider>(
        context,
        listen: false,
      ).currentCurrency;
    });
  }

  @override
  void dispose() {
    amountController.removeListener(_replaceCommaWithDot);
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // =========================================================================
  // FUNCIONES
  // =========================================================================

  //Función del Listener que hace la sustitución
  void _replaceCommaWithDot() {
    final text = amountController.text;

    if (text.contains(',')) {
      final selection = amountController.selection;
      final newText = text.replaceAll(',', '.');

      amountController.value = amountController.value.copyWith(
        text: newText,
        selection: selection,
        composing: TextRange.empty,
      );
    }
  }

  void _createAsset(BuildContext context) async {
    // 1. Validar campos
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Acceder al Provider
    final provider = Provider.of<NetWorthAssetProvider>(context, listen: false);

    final String name = nameController.text.trim();
    // Usamos double.tryParse para asegurar la conversión correcta
    final double amount = double.tryParse(amountController.text) ?? 0.0;

    // 3. Crear el objeto NetWorthAsset
    final newAsset = NetWorthAsset(
      name: name,
      type: widget.assetType.name,
      currentBalance: amount,
      currency: currency,
      history: [
        BalanceHistory(
          date: DateTime.now(),
          balance: amount,
          currency: currency,
        ),
      ],
    );

    try {
      await provider.createAssetAndRefresh(
        context: context,
        userId:
            Provider.of<UserProvider>(context, listen: false).user!.uid ?? '',
        newAsset: newAsset,
      );
    } catch (e) {
      debugPrint('Error al crear activo desde UI: $e');
    }
    if (!context.mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 40.0,
              horizontal: 15.0,
            ),
            child: Form(
              // Contiene los campos para la validación
              key: _formKey,
              child: Column(
                children: [
                  Column(
                    children: [
                      ClipOval(
                        child: Container(
                          color: widget.assetType.backgroundColor,
                          width: 100,
                          height: 100,
                          child: Icon(
                            widget.assetType.iconData,
                            size: 60,
                            color: widget.assetType.iconColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.assetType.title,
                        style: textTheme.titleSmall!.copyWith(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Campo Título
                  StandarTextField(
                    controller: nameController,
                    colorFocusBorder: Colors.transparent,
                    textInputType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    enable: true,
                    hintText: 'Título',
                    filled: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduce un título para el activo.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Campo Importe
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(
                        child: StandarTextField(
                          controller: amountController,
                          colorFocusBorder: Colors.transparent,
                          enable: true,
                          hintText: 'Importe actual',
                          filled: true,
                          textInputType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d.,]'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Introduce el importe actual.';
                            }
                            if (double.tryParse(value) == null) {
                              return 'El valor debe ser un número.';
                            }
                            return null;
                          },
                        ),
                      ),

                      Container(
                        alignment: Alignment.center,
                        height: 55,
                        width: 100,
                        decoration: decorationContainer(
                          context: context,
                          colorFilled: colorScheme.surface,
                          radius: 12,
                        ),
                        child: PopupMenuButton<String>(
                          menuPadding: EdgeInsets.only(right: 30),
                          popUpAnimationStyle: AnimationStyle(),
                          shape: RoundedRectangleBorder(
                            // Define el radio de las esquinas
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          color: colorScheme.surface,

                          child: Text(currency, style: textTheme.bodyMedium),

                          // 2. EL CONTENIDO DEL MENÚ (Los items que aparecen)
                          itemBuilder: (BuildContext context) {
                            return Currency.availableCurrencies.map((
                              Currency cur,
                            ) {
                              return PopupMenuItem<String>(
                                // onTap: () {
                                //   currency = cur.code;
                                // },
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                value: cur.code,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0,
                                  ),
                                  child: Text(cur.code),
                                ),
                              );
                            }).toList();
                          },

                          onSelected: (String selectedCode) {
                            setState(() {
                              currency = selectedCode;
                              debugPrint(currency);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // EL BOTÓN "CREAR"
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 50),
        child: StandarButton(
          onPressed: () async {
            _createAsset(context);
          },
          text: 'Crear',
          radius: 100,
        ),
      ),
    );
  }
}

// =========================================================================
// CLASE PRINCIPAL (Mantenida sin cambios)
// =========================================================================

class NetworthAssetCreatePage extends StatefulWidget {
  const NetworthAssetCreatePage({super.key});

  @override
  State<NetworthAssetCreatePage> createState() =>
      _NetworthAssetCreatePageState();
}

class _NetworthAssetCreatePageState extends State<NetworthAssetCreatePage> {
  // Función apertura del formulario modal (sin cambios)
  void _openCreationModal(BuildContext context, NetWorthAssetType assetType) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Atrás",
                style: TextStyle(
                  color: CupertinoColors.systemBlue,
                  fontSize: 16,
                ),
              ),
            ),
            middle: Text(assetType.title),
            backgroundColor: CupertinoColors.systemBackground,
          ),
          child: FormModal(assetType: assetType),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,

      //EL BODY ES AHORA DIRECTAMENTE EL CONTENIDO DE LA ANTIGUA PÁGINA 1
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '''Selecciona un tipo de activo para poder\nempezar a hacer un seguimiento de tu patrimonio.''',
                style: textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              //ListView de opciones que abren el modal (Ahora usa todo el espacio restante)
              Expanded(
                child: ListView(
                  children: NetWorthAssetType.values.map((assetType) {
                    return GestureDetector(
                      onTap: () => _openCreationModal(context, assetType),
                      child: NetworkTypeWidget(
                        title: assetType.title,
                        iconData: assetType.iconData,
                        backgrounCircleColor: assetType.backgroundColor,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
