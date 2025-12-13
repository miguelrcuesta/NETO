import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/provider/shared_preferences_provider.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:provider/provider.dart';

class ProfilesOptionsPage extends StatefulWidget {
  // Asume que esta es tu propiedad estática del Manager de Monedas

  const ProfilesOptionsPage({super.key});

  @override
  State<ProfilesOptionsPage> createState() => _ProfilesOptionsPageState();
}

class _ProfilesOptionsPageState extends State<ProfilesOptionsPage> {
  void showCurrencySelectionSheet(BuildContext context) {
    // Lista de códigos de moneda de ejemplo
    const List<String> availableCurrencies = ['USD', 'EUR', 'GBP'];

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        // Título opcional
        title: const Text('Seleccionar Moneda'),

        // Mensaje opcional
        message: const Text('Elige tu moneda preferida para la aplicación.'),

        // LAS ACCIONES (Equivalentes a PopupMenuItem)
        actions: availableCurrencies.map((currencyCode) {
          return CupertinoActionSheetAction(
            // Texto de la opción
            child: Text('Cambiar a $currencyCode'),

            // Estilo Destructivo (usar para 'Eliminar', 'Cancelar', etc.)
            isDestructiveAction: false,

            // Acción a ejecutar
            onPressed: () {
              // Llama a tu provider aquí:
              // Provider.of<SettingsProvider>(context, listen: false).setCurrency(currencyCode);

              Navigator.pop(
                context,
              ); // Cierra el menú modal después de seleccionar
            },
          );
        }).toList(),

        // El BOTÓN DE CANCELAR (Parte inferior separada)
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancelar'),
          isDefaultAction: true, // Se resalta como acción por defecto
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currentCurrencyCode = settingsProvider.currentCurrency;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: TitleAppbar(title: 'Perfil'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: decorationContainer(
                  context: context,
                  colorFilled: colorScheme.primaryContainer,
                  radius: 10,
                ),
                child: Column(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Miguel',
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Divider(thickness: 0.8, color: colorScheme.surface),
                    Text(
                      'Rodríguez Cuesta',
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Divider(thickness: 0.8, color: colorScheme.surface),
                    Text(
                      'rodriguezcuestamiguel@gmail.com',
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              _currencyPopUp(currentCurrencyCode, settingsProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _currencyPopUp(
    String currentCurrencyCode,
    SettingsProvider settingsProvider,
  ) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    final currentCurrency = Currency.availableCurrencies.firstWhere(
      (c) => c.code == currentCurrencyCode,
      // Si no se encuentra, usar un objeto Currency por defecto
      orElse: () => Currency(
        code: 'N/A',
        symbol: '?',
        nameEs: '',
        nameEn: '',
        locale: '',
      ),
    );
    return Container(
      height: 50,
      width: double.infinity,
      decoration: decorationContainer(
        context: context,
        colorFilled: colorScheme.primaryContainer,

        radius: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tipo de moneda',
            style: textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          PopupMenuButton<String>(
            color: colorScheme.primaryContainer,
            // 1. EL BOTÓN (Lo que se ve antes de hacer click)
            child: Text(
              currentCurrency.code,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            // 2. EL CONTENIDO DEL MENÚ (Los items que aparecen)
            itemBuilder: (BuildContext context) {
              return Currency.availableCurrencies.map((Currency currency) {
                return PopupMenuItem<String>(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  value:
                      currency.code, // El valor que se devuelve al seleccionar
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text(currency.code),
                  ),
                );
              }).toList();
            },

            // 3. LA ACCIÓN (Lo que ocurre al seleccionar un item)
            onSelected: (String selectedCode) {
              // Llama al método del SettingsProvider para guardar la nueva moneda
              settingsProvider.setCurrency(selectedCode);
            },
          ),
        ],
      ),
    );
  }
}
