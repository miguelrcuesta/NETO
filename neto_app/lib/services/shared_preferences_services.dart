// Archivo: lib/services/preferences_manager.dart

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  // Claves
  static const String _currencyKey = 'selected_currency_code';
  static const String _languageKey = 'selected_language_code';
  static const String _themeKey = 'selected_theme_mode'; // 'light' o 'dark'

  // Valores por Defecto
  static const String defaultCurrency = 'EUR';
  static const String defaultLanguage = 'es_ES';
  static const String defaultTheme = 'light';

  // Caché (Acceso Rápido después de la carga inicial)
  String currency = defaultCurrency;
  String language = defaultLanguage;
  String themeMode = defaultTheme;

  late SharedPreferences _prefs;

  // Singleton Pattern
  static final PreferencesManager _instance = PreferencesManager._internal();
  factory PreferencesManager() => _instance;
  PreferencesManager._internal();

  // 1. 🚀 Inicialización Asíncrona (Carga Inicial)
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // Carga los valores de forma asíncrona a la caché
    currency = _prefs.getString(_currencyKey) ?? defaultCurrency;
    language = _prefs.getString(_languageKey) ?? defaultLanguage;
    themeMode = _prefs.getString(_themeKey) ?? defaultTheme;
  }

  // 2. 💾 Setters Asíncronos (Guardar en disco y actualizar caché)

  Future<void> saveCurrency(String newCurrency) async {
    currency = newCurrency; // Actualiza la caché
    await _prefs.setString(_currencyKey, newCurrency);
  }

  Future<void> saveLanguage(String newLanguage) async {
    language = newLanguage; // Actualiza la caché
    await _prefs.setString(_languageKey, newLanguage);
  }

  Future<void> saveThemeMode(String newTheme) async {
    themeMode = newTheme; // Actualiza la caché
    await _prefs.setString(_themeKey, newTheme);
  }
}
