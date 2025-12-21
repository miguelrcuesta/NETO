import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neto_app/constants/app_enums.dart';

/// Define las dimensiones, espaciados (padding/margin) y tamaños consistentes.
/// Basado en una escala de 8.
class AppDimensions {
  // -----------------------------------------------------
  // 1. ESCALADO BÁSICO (Unidades de 8)
  // -----------------------------------------------------

  // Usado para elementos muy pequeños o espacio mínimo.
  static const double spacingExtraSmall = 4.0; // 0.5x

  // Usado para espaciado dentro de componentes pequeños (ej: iconos pequeños).
  static const double spacingSmall = 10.0; // 1x

  // Usado para espaciado estándar entre elementos (el más común).
  static const double spacingMedium = 20.0; // 2x

  // Usado para secciones, márgenes de página o espaciado entre grandes bloques.
  static const double spacingLarge = 32.0; // 3x

  // Usado para grandes secciones de la pantalla (ej: encabezados, tarjetas grandes).
  static const double spacingExtraLarge = 50.0; // 4x

  // -----------------------------------------------------
  // 2. PADDINGS Y MARGINS (Ejemplos de EdgeInsets)
  // -----------------------------------------------------

  // Padding uniforme (para usar con `padding: ` en contenedores)
  static const EdgeInsets paddingAllSmall = EdgeInsets.all(spacingSmall); // 8.0

  static const EdgeInsets paddingAllMedium = EdgeInsets.all(
    spacingMedium,
  ); // 16.0

  // Padding simétrico (para usar en el Scaffold o listas)
  // Horizontal estándar para la mayoría de las pantallas: 16.0
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(
    horizontal: spacingMedium,
  );

  // Vertical estándar para espaciado de lista: 8.0
  static const EdgeInsets paddingVerticalSmall = EdgeInsets.symmetric(
    vertical: spacingSmall,
  );

  // Combinación estándar (16.0 horizontal, 8.0 vertical)
  static const EdgeInsets paddingStandard = EdgeInsets.symmetric(
    horizontal: spacingMedium,
    vertical: spacingSmall,
  );

  // -----------------------------------------------------
  // 3. BORDES Y RADIOS UI
  // -----------------------------------------------------

  // Radio de borde pequeño (para botones, campos de texto)
  static const double borderRadiusSmall = 8.0;

  // Radio de borde mediano (para tarjetas, dialogos)
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusCircular = 50.0;

  // Objeto BorderRadius para usar directamente
  static const BorderRadius standardBorderRadius = BorderRadius.all(
    Radius.circular(borderRadiusSmall),
  );

  // -----------------------------------------------------
  // 4. DIMENSIONES DE COMPONENTES
  // -----------------------------------------------------

  // Altura estándar para iconos grandes o avatares
  static const double iconSizeLarge = 32.0;

  // Altura recomendada para botones de acción flotante (FAB)
  static const double fabSize = 56.0;

  // Altura estándar de un campo de texto (sin contar el error text)
  static const double inputFieldHeight = 48.0;

  ///Segun el tamaño de un numero, hace más grande o pequeña la letra
  static getFontSizeByLength(double number) {
    // 1. Convertir el número a String para medir su longitud.
    // Usamos toStringAsFixed(2) para incluir los dos decimales en la longitud.
    final String numberString = number.toStringAsFixed(2);
    final int length = numberString.length; // Ejemplo: 125.00 tiene longitud 6

    // 2. Definir tamaños base y umbrales.
    const double baseSize =
        55.0; // Tamaño de fuente para números cortos (ej: 1.00)
    const double minSize = 37.0; // Tamaño de fuente mínimo.

    // 3. Definir los umbrales de longitud y la escala de reducción.
    // - Si la longitud es 5 (ej: 99.99), usamos el tamaño base.
    // - Si la longitud es mayor a 5, empezamos a reducir el tamaño.

    if (length <= 6) {
      return baseSize;
    } else if (length == 7) {
      return baseSize * 0.9; // 10% de reducción (ej: 21.6)
    } else if (length == 8) {
      // Para 7 dígitos enteros (ej: 12,500.00)
      return baseSize * 0.8; // 20% de reducción (ej: 19.2)
    } else if (length >= 9) {
      return minSize;
    }

    // Valor por defecto (nunca debería ocurrir si el flujo es correcto)
    return baseSize;
  }
}

// Definición de una clase estática para contener todos los formateadores de la aplicación
class AppFormatters {
  //###################################################################################
  //###################################################################################
  //MONEDAS
  //###################################################################################
  //###################################################################################

  static Locale getPlatformLocale() {
    final locales = WidgetsBinding.instance.platformDispatcher.locales;

    // Si la lista de locales de la plataforma está vacía (muy raro), usamos un fallback.
    if (locales.isEmpty) {
      return const Locale('en', 'US');
    }

    // Devolvemos el primer Locale, que es el preferido y más completo.
    return locales.first;
  }

  static String getFormatedNumber(
    String text, // Contiene la entrada del usuario (ej: "123,")
    double amount, // Contiene el valor numérico parseado (ej: 123.0)
  ) {
    // DECLARACIÓN LOCAL: Creamos el formateador aquí dentro del scope static
    final NumberFormat decimalFormatter = NumberFormat.decimalPatternDigits(
      locale: 'es_ES',
      decimalDigits: 2, // Fija a 2 decimales para montos
    );
    final NumberFormat intergerFormatter = NumberFormat.decimalPatternDigits(
      locale: 'es_ES',
      decimalDigits: 0, // Fija a 2 decimales para montos
    );

    // El formateador de salida siempre es a 2 decimales para moneda
    String intergerFormat = intergerFormatter.format(amount);
    String decimalFormat = decimalFormatter.format(amount);

    // 1. Verificación de Estado
    // Verificamos si la entrada es parcial (termina en ',' o '.')
    bool endsWithDecimalSeparator =
        text.endsWith(',') ||
        text.endsWith('.') ||
        text.contains(',') ||
        text.contains('.');

    // A) Si el texto está vacío o el monto es cero
    if (text.isEmpty) {
      // Si amount es 0.0, devolvemos el valor formateado de cero.
      return decimalFormatter.format(0.0);
    }

    // B) Si el usuario está ingresando decimales (termina en separador)
    // Devuelve la entrada literal para que el usuario pueda escribir el siguiente dígito.
    if (endsWithDecimalSeparator) {
      return decimalFormat;
    }

    // C) En cualquier otro caso (número completo o parte entera), devuelve el valor formateado.
    return intergerFormat;
  }

  //###################################################################################
  //###################################################################################
  //FECHAS
  //###################################################################################
  //###################################################################################

  static String customDateFormatShort(DateTime date) {
    return DateFormat.yMMMd('es').format(date);
  }

  static String customDateFormatMonthYear(DateTime date) {
    return DateFormat.yMMMM('es').format(date);
  }

  static String customDateOnlyMonth(DateTime date) {
    return DateFormat.MMMM('es').format(date);
  }
}

dynamic getCategory(String id, String type) {
  if (type == TransactionType.expense.id) {
    return Expenses.getCategoryById(id);
  } else {
    return Incomes.getCategoryById(id);
  }
}

List<Color> chartColorsStatic = [
  NetWorthAssetType.bankAccount.backgroundColor,
  NetWorthAssetType.investment.backgroundColor,
  NetWorthAssetType.longTermAsset.backgroundColor,
];
