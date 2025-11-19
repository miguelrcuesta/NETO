import 'package:flutter/cupertino.dart';
import 'package:neto_app/l10n/app_localizations.dart';

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

enum TransactionFrequency {
  single(id: 'SINGLE'),
  monthly(id: 'MONTHLY'),
  annual(id: 'ANNUAL');

  final String id;

  const TransactionFrequency({required this.id});

  String getName(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return switch (this) {
      TransactionFrequency.single => localizations.freqSingle,
      TransactionFrequency.monthly => localizations.freqMonthly,
      TransactionFrequency.annual => localizations.freqAnnual,
    };
  }

  /// Método estático para obtener un enum a partir de su ID.
  static TransactionFrequency? getById(String id) {
    try {
      return TransactionFrequency.values.firstWhere((type) => type.id == id);
    } catch (e) {
      // Retorna null o lanza un error si el ID no es válido.
      return null;
    }
  }
}

// SIMULACIÓN DE CÓDIGO (SWIFT / Kotlin / TypeScript)

class EtiquetaMovimiento {
  final String categoria;
  final String subcategoria;

  EtiquetaMovimiento({required this.categoria, required this.subcategoria});

  factory EtiquetaMovimiento.fromJson(Map<String, dynamic> json) {
    return EtiquetaMovimiento(
      categoria: json['categoria'] as String,
      subcategoria: json['subcategoria'] as String,
    );
  }
}

enum CategoriaGasto {
  // Casos (instancias) del Enum, llamando al constructor:
  vivienda(
    emoji: '🏠',
    nombre: 'Vivienda y Hogar',
    subcategorias: [
      'Alquiler',
      'Hipoteca',
      'Servicios (Luz, Agua, Gas)',
      'Internet y Telefonía',
      'Reparaciones y Mantenimiento',
      'Muebles y Decoración',
    ],
  ),
  alimentacion(
    emoji: '🛒',
    nombre: 'Alimentación',
    subcategorias: [
      'Supermercado (Compras)',
      'Restaurantes (comer fuera)',
      'Comida Rápida',
      'Cafeterías y Bares',
    ],
  ),
  transporte(
    emoji: '🚗',
    nombre: 'Transporte',
    subcategorias: [
      'Combustible/Gasolina',
      'Transporte Público',
      'Taxi/VTC',
      'Mantenimiento de Vehículo',
      'Peajes y Parking',
    ],
  ),
  suscripciones(
    emoji: '🌐',
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
  ),
  salud(
    emoji: '⚕️',
    nombre: 'Salud y Cuidado',
    subcategorias: [
      'Médico y Dentista',
      'Farmacia y Medicamentos',
      'Seguro de Salud',
      'Cuidado Personal (Peluquería, cosmética)',
    ],
  ),
  ocio(
    emoji: '🎬',
    nombre: 'Ocio y Diversión',
    subcategorias: [
      'Cine/Teatro/Conciertos',
      'Viajes y Vacaciones',
      'Hobbies',
      'Compras de Electrónica',
      'Salidas nocturnas',
    ],
  ),
  ropaYAccesorios(
    emoji: '👕',
    nombre: 'Ropa y Accesorios',
    subcategorias: ['Ropa', 'Calzado', 'Accesorios', 'Lavandería/Tintorería'],
  ),
  otrosGastos(
    emoji: '',
    nombre: 'Otros',
    subcategorias: [
      'Pago de Préstamos/Tarjetas',
      'Regalos',
      'Mascotas (Comida, Veterinario)',
      'Donaciones',
      'Multas',
      'Retiro de efectivo',
    ],
  );

  static CategoriaGasto? getCategoryByName(String name) {
    try {
      return CategoriaGasto.values.firstWhere((type) => type.name == name);
    } catch (e) {
      return null;
    }
  }

  static String? getSubCategoryByName(String subcategoria) {
    try {
      for (int i = 0; i < CategoriaGasto.values.length; i++) {
        //Buscamos si una categoria sus subcategorias contiene el subcategoria dado
        if (CategoriaGasto.values[i].subcategorias.contains(subcategoria)) {
          return CategoriaGasto.values[i].subcategorias.firstWhere((id) => id == subcategoria);
        }
      }
    } catch (e) {
      // Retorna null si el nombre no es válido (ej. CategoriaGasto.values.isEmpty).
      return null;
    }
  }

  // 1. Campos (Propiedades)
  final String emoji;
  final String nombre;
  final List<String> subcategorias;

  // 2. Constructor
  const CategoriaGasto({required this.emoji, required this.nombre, required this.subcategorias});
}

enum CategoriaIngreso {
  // Casos (instancias) del Enum, llamando al constructor:
  salario(
    emoji: '💼',
    nombre: 'Salario',
    subcategorias: ['Nómina Principal', 'Horas Extra', 'Bonificaciones', 'Ingresos Freelance'],
  ),
  inversiones(
    emoji: '📈',
    nombre: 'Inversiones',
    subcategorias: [
      'Dividendos',
      'Intereses Bancarios',
      'Alquiler de Propiedades',
      'Venta de Activos',
      'Acciones',
    ],
  ),
  ventasYNegocio(
    emoji: '🛍️',
    nombre: 'Ventas/Negocio',
    subcategorias: [
      'Venta de Artículos Personales',
      'Ingresos de Negocio Propio',
      'Comisiones',
      'Devoluciones',
    ],
  ),
  otros(
    emoji: '',
    nombre: 'Otros Ingresos',
    subcategorias: [
      'Regalos Recibidos',
      'Devolución de Impuestos',
      'Reembolsos',
      'Bizum',
      'Ingresos Varios/Extraordinarios',
    ],
  );

  static CategoriaIngreso? getCategoryByName(String name) {
    try {
      // La propiedad `name` en Dart enums es el ID de texto.
      return CategoriaIngreso.values.firstWhere((type) => type.name == name);
    } catch (e) {
      // Retorna null si el nombre no es válido (ej. CategoriaGasto.values.isEmpty).
      return null;
    }
  }

  static String? getSubCategoryByName(String subcategoria) {
    try {
      for (int i = 0; i < CategoriaIngreso.values.length; i++) {
        //Buscamos si una categoria sus subcategorias contiene el subcategoria dado
        if (CategoriaIngreso.values[i].subcategorias.contains(subcategoria)) {
          return CategoriaIngreso.values[i].subcategorias.firstWhere((id) => id == subcategoria);
        }
      }
    } catch (e) {
      // Retorna null si el nombre no es válido (ej. CategoriaGasto.values.isEmpty).
      return null;
    }
  }

  // 1. Campos (Propiedades)
  final String emoji;
  final String nombre;
  final List<String> subcategorias;

  // 2. Constructor
  const CategoriaIngreso({required this.emoji, required this.nombre, required this.subcategorias});
}
