// Archivo: lib/services/preferences_manager.dart

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  // Claves existentes
  static const String _currencyKey = 'selected_currency_code';
  static const String _languageKey = 'selected_language_code';
  static const String _themeKey = 'selected_theme_mode';

  // Claves nuevas para Categorías
  static const String _favExpensesKey = 'fav_expenses_ids';
  static const String _favIncomesKey = 'fav_incomes_ids';

  // Valores por Defecto
  static const String defaultCurrency = 'EUR';
  static const String defaultLanguage = 'es_ES';
  static const String defaultTheme = 'light';

  // Caché
  String currency = defaultCurrency;
  String language = defaultLanguage;
  String themeMode = defaultTheme;

  // Caché de Favoritos (Listas de IDs de tus Enums)
  List<String> favExpenses = [];
  List<String> favIncomes = [];

  late SharedPreferences _prefs;

  static final PreferencesManager _instance = PreferencesManager._internal();
  factory PreferencesManager() => _instance;
  PreferencesManager._internal();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    currency = _prefs.getString(_currencyKey) ?? defaultCurrency;
    language = _prefs.getString(_languageKey) ?? defaultLanguage;
    themeMode = _prefs.getString(_themeKey) ?? defaultTheme;

    // Cargar favoritos de categorías
    favExpenses = _prefs.getStringList(_favExpensesKey) ?? [];
    favIncomes = _prefs.getStringList(_favIncomesKey) ?? [];
  }

  // --- Setters Existentes ---

  Future<void> saveCurrency(String newCurrency) async {
    currency = newCurrency;
    await _prefs.setString(_currencyKey, newCurrency);
  }

  Future<void> saveLanguage(String newLanguage) async {
    language = newLanguage;
    await _prefs.setString(_languageKey, newLanguage);
  }

  Future<void> saveThemeMode(String newTheme) async {
    themeMode = newTheme;
    await _prefs.setString(_themeKey, newTheme);
  }

  String _getSubId(String catId, String subName) => "$catId:$subName";

  Future<void> toggleFavoriteSubcategory({
    required String catId,
    required String catName,
    required String subName,
    required bool isExpense,
  }) async {
    // 1. Definimos el formato: "ID_CAT|NOM_CAT|NOM_SUB"
    // Usamos "|" porque es más seguro que ":" si los nombres contienen puntos o comas
    final String favString = "$catId|$catName|$subName";

    final key = isExpense ? _favExpensesKey : _favIncomesKey;
    final list = isExpense ? favExpenses : favIncomes;

    // 2. Buscamos si ya existe esa subcategoría exacta en la lista
    // Usamos any/firstWhere por si el ID es el mismo pero el nombre cambió
    bool exists = list.any(
      (item) => item.contains(subName) && item.contains(catId),
    );

    if (exists) {
      // Si existe, la eliminamos buscando el elemento que coincida con el ID y Subnombre
      list.removeWhere(
        (item) => item.contains(subName) && item.contains(catId),
      );
    } else {
      // Si no existe, añadimos el string completo
      list.add(favString);
    }

    // 3. Persistimos en disco y actualizamos la memoria
    await _prefs.setStringList(key, list);

    // Opcional: imprimir para depuración
    debugPrint("Favoritos actualizados: $list");
  }

  bool isSubFavorite(String catId, String subName, bool isExpense) {
    // 1. Seleccionamos la lista correspondiente
    final List<String> list = isExpense ? favExpenses : favIncomes;

    // 2. Buscamos si algún elemento de la lista contiene AMBOS: el ID de categoría y el nombre de subcategoría
    // Esto evita falsos positivos si dos categorías diferentes tienen subcategorías con el mismo nombre.
    return list.any((item) {
      final parts = item.split('|');
      if (parts.length < 3) return false;

      // parts[0] es catId, parts[2] es subName
      return parts[0] == catId && parts[2] == subName;
    });
  }

  Future<void> clearAllFavorites(bool isExpense) async {
    final key = isExpense ? _favExpensesKey : _favIncomesKey;

    if (isExpense) {
      favExpenses.clear();
    } else {
      favIncomes.clear();
    }

    await _prefs.setStringList(key, []);
  }
}
