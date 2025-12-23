import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/provider/shared_preferences_provider.dart';
import 'package:neto_app/provider/user_provider.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:neto_app/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void showFavoriteCategoriesSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => const FavoriteCategoriesModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currentCurrencyCode = settingsProvider.currentCurrency;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text('Perfil', style: textTheme.bodyMedium),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _userdata(context, colorScheme, textTheme, userProvider),
              _currencyPopUp(
                currentCurrencyCode,
                settingsProvider,
                userProvider,
              ),
              _themeSwitch(settingsProvider, userProvider),
              Container(
                height: 50,
                width: double.infinity,
                decoration: decorationContainer(
                  context: context,
                  colorFilled: colorScheme.primaryContainer,
                  radius: 10,
                ),
                padding: const EdgeInsets.only(
                  left: 16.0,
                  top: 8.0,
                  bottom: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categorías favoritas',
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      onPressed: () => showFavoriteCategoriesSheet(
                        context,
                      ), // También en el icono
                      icon: const Icon(CupertinoIcons.chevron_right, size: 15),
                    ),
                  ],
                ),
              ),

              Spacer(),

              _logout(colorScheme, context),
              _deleteAcount(textTheme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Padding _deleteAcount(TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextButton(
        onPressed: () {},

        child: Text(
          'Eliminar cuenta',
          style: textTheme.bodyMedium!.copyWith(color: colorScheme.error),
        ),
      ),
    );
  }

  Padding _logout(ColorScheme colorScheme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
      child: StandarButton(
        radius: 100,
        backgroundColor: colorScheme.primary,
        textColor: colorScheme.onPrimary,
        height: AppDimensions.inputFieldHeight,
        width: double.infinity,
        onPressed: () {
          Provider.of<UserProvider>(context, listen: false).logout();
        },
        text: 'Cerrar sesión',
      ),
    );
  }

  Widget _userdata(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    UserProvider userProvider,
  ) {
    return Container(
      width: double.infinity,
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
            userProvider.user!.email ?? 'Sin información',
            style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _currencyPopUp(
    String currentCurrencyCode,
    SettingsProvider settingsProvider,
    UserProvider userProvider,
  ) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    final currentCurrency = Currency.availableCurrencies.firstWhere(
      (c) => c.code == currentCurrencyCode,
      // Si no se encuentra, usar un objeto Currency por defecto
      orElse: () => Currency(
        code: 'EUR',
        symbol: '€',
        nameEs: 'Euro',
        nameEn: 'Euro',
        locale: 'es_ES',
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
            menuPadding: EdgeInsets.only(right: 30),
            popUpAnimationStyle: AnimationStyle(),
            shape: RoundedRectangleBorder(
              // Define el radio de las esquinas
              borderRadius: BorderRadius.circular(20.0),
            ),
            color: colorScheme.surface,
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

  Widget _themeSwitch(
    SettingsProvider settingsProvider,
    UserProvider userProvider,
  ) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    bool darktheme = settingsProvider.currentThemeMode == 'dark';

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
            'Modo oscuro',
            style: textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          CupertinoSwitch(
            value: settingsProvider.currentThemeMode == 'dark' ? true : false,
            onChanged: (value) {
              setState(() {
                darktheme = value;
                if (darktheme == false) {
                  settingsProvider.setThemeMode('light');
                } else {
                  settingsProvider.setThemeMode('dark');
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
