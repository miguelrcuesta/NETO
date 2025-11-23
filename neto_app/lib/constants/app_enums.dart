import 'package:flutter/material.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'dart:convert';

enum TransactionType {
  income(id: 'INCOME'),
  expense(id: 'EXPENSE');

  final String id;

  const TransactionType({required this.id});

  String getName(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return switch (this) {
      TransactionType.income => localizations.typeIncome,
      TransactionType.expense => localizations.typeExpense,
    };
  }

  /// Método estático para obtener un enum a partir de su ID.
  static TransactionType? getById(String id) {
    try {
      return TransactionType.values.firstWhere((type) => type.id == id);
    } catch (e) {
      // Retorna null o lanza un error si el ID no es válido.
      return null;
    }
  }
}

enum Frecuency {
  single(id: 'SINGLE'),
  monthly(id: 'MONTHLY'),
  annual(id: 'ANNUAL');

  final String id;

  const Frecuency({required this.id});

  String getName(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return switch (this) {
      Frecuency.single => localizations.freqSingle,
      Frecuency.monthly => localizations.freqMonthly,
      Frecuency.annual => localizations.freqAnnual,
    };
  }

  /// Método estático para obtener un enum a partir de su ID.
  static Frecuency? getById(String id) {
    try {
      return Frecuency.values.firstWhere((type) => type.id == id);
    } catch (e) {
      // Retorna null o lanza un error si el ID no es válido.
      return null;
    }
  }
}

///#####################################################################
///#####################################################################
///CATEGORIAS
///#####################################################################
///#####################################################################
enum Expenses {
  // Casos (instancias) del Enum, llamando al constructor:
  vivienda(
    id: 'VIVIENDA',
    emoji: '🏠',
    iconData: Icons.home_filled,
    nombre: 'Vivienda y Hogar',
    subcategorias: [
      'Alquiler',
      'Hipoteca',
      'Servicios (Luz, Agua, Gas)',
      'Internet y Telefonía',
      'Reparaciones y Mantenimiento',
      'Muebles y Decoración',
    ],
    color: Colors.purple,
  ),
  alimentacion(
    id: 'ALIMENTACION',
    emoji: '🛒',
    iconData: Icons.shopping_cart,
    nombre: 'Alimentación',
    subcategorias: [
      'Supermercado (Compras)',
      'Restaurantes (comer fuera)',
      'Comida Rápida',
      'Cafeterías y Bares',
    ],
    color: Colors.grey,
  ),
  transporte(
    id: 'TRANSPORTE',
    emoji: '🚗',
    iconData: Icons.directions_car_filled,
    nombre: 'Transporte',
    subcategorias: [
      'Combustible/Gasolina',
      'Transporte Público',
      'Taxi/VTC',
      'Mantenimiento de Vehículo',
      'Peajes y Parking',
    ],
    color: Colors.orange,
  ),
  suscripciones(
    id: 'SUSCRIPCIONES',
    emoji: '🌐',
    iconData: Icons.event_repeat,
    nombre: 'Suscripciones y Cuotas',
    subcategorias: [
      'Netflix',
      'Amazon Prime',
      'Amazon Music',
      'Apple TV',
      'Apple iCloud',
      'Apple Music',
      'Disney+',
      'Youtube Premium',
      'HBO',
      'Movistar',
      'Plataforma Streaming',
      'Gimnasio/Deportes',
      'Software/Apps',
      'Cursos de Formación',
      'Cuotas bancarias',
    ],
    color: Colors.red,
  ),
  salud(
    id: 'SALUD',
    emoji: '⚕️',
    iconData: Icons.local_hospital,
    nombre: 'Salud y Cuidado',
    subcategorias: [
      'Médico y Dentista',
      'Farmacia y Medicamentos',
      'Seguro de Salud',
      'Cuidado Personal (Peluquería, cosmética)',
    ],
    color: Colors.redAccent,
  ),
  ocio(
    id: 'OCIO',
    emoji: '🎬',
    iconData: Icons.videogame_asset,
    nombre: 'Ocio y Diversión',
    subcategorias: [
      'Cine/Teatro/Conciertos',
      'Viajes y Vacaciones',
      'Hobbies',
      'Compras de Electrónica',
      'Salidas nocturnas',
    ],
    color: Colors.blueAccent,
  ),
  ropaYAccesorios(
    id: 'ROPA',
    emoji: '👕',
    iconData: Icons.local_offer,
    nombre: 'Ropa y Accesorios',
    subcategorias: ['Ropa', 'Calzado', 'Accesorios', 'Lavandería/Tintorería'],
    color: Colors.amber,
  ),
  otrosGastos(
    id: 'OTROS',
    emoji: '',
    iconData: Icons.shopping_bag_rounded,
    nombre: 'Otros',
    subcategorias: [
      'Pago de Préstamos/Tarjetas',
      'Regalos',
      'Mascotas (Comida, Veterinario)',
      'Donaciones',
      'Multas',
      'Retiro de efectivo',
    ],
    color: Colors.blueGrey,
  );

  static Expenses? getCategoryById(String id) {
    try {
      return Expenses.values.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }

  final String id;
  final String emoji;
  final IconData iconData;
  final String nombre;
  final List<String> subcategorias;
  final Color color;

  // 2. Constructor
  const Expenses({
    required this.id,
    required this.emoji,
    required this.iconData,
    required this.nombre,
    required this.subcategorias,
    required this.color,
  });
}

enum Incomes {
  // Casos (instancias) del Enum, llamando al constructor:
  salario(
    id: 'SALARIO',
    iconData: Icons.work,
    emoji: '💼',
    nombre: 'Salario',
    subcategorias: ['Nómina Principal', 'Horas Extra', 'Bonificaciones', 'Ingresos Freelance'],
    color: Colors.lightGreen,
  ),
  inversiones(
    id: 'INVERSIONES',
    iconData: Icons.assured_workload,
    emoji: '📈',
    nombre: 'Inversiones',
    subcategorias: [
      'Dividendos',
      'Intereses Bancarios',
      'Alquiler de Propiedades',
      'Venta de Activos',
      'Acciones',
    ],
    color: Colors.blueGrey,
  ),
  ventasYNegocio(
    id: 'VENTAS',
    iconData: Icons.store,
    emoji: '🛍️',
    nombre: 'Ventas/Negocio',
    subcategorias: [
      'Venta de Artículos Personales',
      'Ingresos de Negocio Propio',
      'Comisiones',
      'Devoluciones',
    ],
    color: Colors.blueGrey,
  ),
  otros(
    id: 'OTROS',
    iconData: Icons.arrow_downward,
    emoji: '',
    nombre: 'Otros Ingresos',
    subcategorias: [
      'Regalos Recibidos',
      'Devolución de Impuestos',
      'Reembolsos',
      'Bizum',
      'Ingresos Varios/Extraordinarios',
    ],
    color: Colors.blueGrey,
  );

  static Incomes? getCategoryById(String id) {
    try {
      // La propiedad `name` en Dart enums es el ID de texto.
      return Incomes.values.firstWhere((type) => type.id == id);
    } catch (e) {
      // Retorna null si el nombre no es válido (ej. CategoriaGasto.values.isEmpty).
      return null;
    }
  }

  final String id;
  final String emoji;
  final IconData iconData;
  final String nombre;
  final List<String> subcategorias;
  final Color color;

  const Incomes({
    required this.id,
    required this.emoji,
    required this.iconData,
    required this.nombre,
    required this.subcategorias,
    required this.color,
  });
}

///#####################################################################
///#####################################################################
///MONEDAS
///#####################################################################
///#####################################################################

class Currency {
  final String code;
  final String symbol;
  final String nameEs;
  final String nameEn;
  final String locale;

  const Currency({
    required this.code,
    required this.symbol,
    required this.nameEs,
    required this.nameEn,
    required this.locale,
  });

  // Constructor de Fábrica para deserializar desde Map
  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] as String,
      symbol: json['symbol'] as String,
      nameEs: json['name_es'] as String,
      nameEn: json['name_en'] as String,
      locale: json['locale'] as String,
    );
  }

  // =========================================================
  // ⭐️ ESTRUCTURA DE DATOS EMBEBIDA ⭐️
  // =========================================================

  // 1. JSON como String constante
  static const String _currenciesJsonString = '''
[
  {
    "code": "USD",
    "symbol": "\$",
    "name_es": "Dólar estadounidense",
    "name_en": "US Dollar",
    "locale": "en_US"
  },
  {
    "code": "EUR",
    "symbol": "€",
    "name_es": "Euro",
    "name_en": "Euro",
    "locale": "es_ES"
  },
  {
    "code": "GBP",
    "symbol": "£",
    "name_es": "Libra esterlina",
    "name_en": "British Pound",
    "locale": "en_GB"
  },
  {
    "code": "MXN",
    "symbol": "\$",
    "name_es": "Peso mexicano",
    "name_en": "Mexican Peso",
    "locale": "es_MX"
  },
  {
    "code": "COP",
    "symbol": "\$",
    "name_es": "Peso colombiano",
    "name_en": "Colombian Peso",
    "locale": "es_CO"
  }
]
'''; // Puedes ampliar esta lista con todas las que necesites

  // 2. ⭐️ Getter para obtener la lista de objetos Currency ⭐️
  static List<Currency> get availableCurrencies {
    // Decodifica el string JSON.
    final List<dynamic> jsonList = jsonDecode(_currenciesJsonString);

    // Mapea la lista de Maps a una lista de objetos Currency.
    return jsonList.map((jsonMap) => Currency.fromJson(jsonMap as Map<String, dynamic>)).toList();
  }
}
