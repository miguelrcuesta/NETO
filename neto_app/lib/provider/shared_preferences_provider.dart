// Archivo: lib/providers/settings_provider.dart

import 'package:flutter/foundation.dart';
import 'package:neto_app/services/shared_preferences_services.dart';

class SettingsProvider with ChangeNotifier {
  final PreferencesManager _prefsManager = PreferencesManager();
  bool _initialized = false;

  // Getters que usan la CACHÉ del Manager (acceso síncrono)
  String get currentCurrency => _prefsManager.currency;
  String get currentLanguage => _prefsManager.language;
  String get currentThemeMode => _prefsManager.themeMode;
  bool get isInitialized => _initialized;

  // 1. Inicialización: Llama al Manager para cargar los valores del disco
  Future<void> initializeSettings() async {
    if (_initialized) return;

    await _prefsManager.initialize();
    _initialized = true;
    notifyListeners(); // Notifica que los valores iniciales están listos
  }

  // 2. Métodos para Cambiar y Persistir (Moneda)
  Future<void> setCurrency(String newCurrencyCode) async {
    if (currentCurrency == newCurrencyCode) return;

    // 1. Persistencia: Guarda en SharedPreferences y actualiza la caché del Manager
    await _prefsManager.saveCurrency(newCurrencyCode);

    // 2. Estado: Notifica a la UI
    notifyListeners();
  }

  // 3. 🔄 Métodos para Cambiar y Persistir (Idioma)
  Future<void> setLanguage(String newLanguageCode) async {
    if (currentLanguage == newLanguageCode) return;

    await _prefsManager.saveLanguage(newLanguageCode);
    notifyListeners();
  }

  // 4. 🔄 Métodos para Cambiar y Persistir (Tema Oscuro/Claro)
  Future<void> setThemeMode(String newTheme) async {
    if (currentThemeMode == newTheme) return;

    await _prefsManager.saveThemeMode(newTheme);
    notifyListeners();
  }
}
