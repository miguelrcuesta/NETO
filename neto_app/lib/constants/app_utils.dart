import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  static const EdgeInsets paddingAllMedium = EdgeInsets.all(spacingMedium); // 16.0

  // Padding simétrico (para usar en el Scaffold o listas)
  // Horizontal estándar para la mayoría de las pantallas: 16.0
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(horizontal: spacingMedium);

  // Vertical estándar para espaciado de lista: 8.0
  static const EdgeInsets paddingVerticalSmall = EdgeInsets.symmetric(vertical: spacingSmall);

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
    const double baseSize = 55.0; // Tamaño de fuente para números cortos (ej: 1.00)
    const double minSize = 25.0; // Tamaño de fuente mínimo.

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

  // ----------------------------------------------------
  // A. FORMATOS DE MONEDA
  // ----------------------------------------------------

  // Formato para EURO (€) - Convención ES (punto miles, coma decimal)
  static final NumberFormat euroCurrency = NumberFormat.currency(
    locale: 'es_ES',
    symbol: '€',
    decimalDigits: 2,
  );

  // Formato para DÓLAR ($) - Convención US (coma miles, punto decimal)
  static final NumberFormat usdCurrency = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );
  static final NumberFormat poundCurrency = NumberFormat.currency(
    locale: 'en_GB',
    symbol: '£',
    decimalDigits: 2,
  );

  // ----------------------------------------------------
  // B. FORMATOS DE NÚMERO (SIN SÍMBOLO DE MONEDA)
  // ----------------------------------------------------

  // Formato de miles simple con convención española (1.234.567,89)
  static final numberFormatterES = NumberFormat.decimalPattern('es_ES');

  // Formato de miles simple con convención americana (1,234,567.89)
  static final numberFormatterUS = NumberFormat.decimalPattern('en_US');

  // Formato para porcentajes
  static final percentage = NumberFormat.percentPattern();

  // ----------------------------------------------------
  // C. FUNCIÓN DINÁMICA
  // ----------------------------------------------------

  // ---  EXTRACCIÓN DEL NUMERO CON SIMBOLO ---
  /// Devuelve el formateador de moneda (NumberFormat) apropiado
  /// basándose en el Locale del sistema.
  ///
  /// @param locale El Locale actual del contexto (obtenido vía Localizations.localeOf(context)).
  /// @returns Un NumberFormat predefinido. Por defecto, devuelve euroCurrency.
  static NumberFormat getCurrencyFormatterByLocale(Locale locale) {
    // Usamos el código de país (countryCode) para determinar la moneda.
    // Lo convertimos a mayúsculas para asegurar la coincidencia.
    final String? countryCode = locale.countryCode?.toUpperCase();

    // Mapeo de códigos de país a formateadores de moneda
    switch (countryCode) {
      case 'US':
        return usdCurrency;
      case 'GB':
        return poundCurrency;
      case 'ES': // España
      case 'FR': // Francia
      case 'DE': // Alemania
      case 'IT': // Italia
      case 'NL': // Países Bajos
      case 'BE': // Bélgica
      case 'AT': // Austria
      case 'IE': // Irlanda
      case 'PT': // Portugal
      case 'GR': // Grecia
      case 'FI': // Finlandia
      case 'SK': // Eslovaquia
      case 'SI': // Eslovenia
      case 'LT': // Lituania
      case 'LV': // Letonia
      case 'EE': // Estonia
      case 'CY': // Chipre
      case 'MT': // Malta
      case 'HR': // Croacia
        return euroCurrency;

      default:
        switch (locale.languageCode) {
          // Si el idioma es español, asumimos EURO (convención ES)
          case 'es':
            return euroCurrency;
          // Si el idioma es inglés, asumimos DÓLAR (convención US)
          case 'en':
            return usdCurrency;
          // Si no hay país ni idioma conocido, volvemos a un fallback seguro
          default:
            return usdCurrency;
        }
    }
  }

  // ---  EXTRACCIÓN DEL NUMERO SIN SIMBOLO ---
  /// Retorna un [NumberFormat] basado en el [locale] para formatear un valor
  /// numérico SIN NINGÚN SÍMBOLO DE MONEDA. Solo aplica separadores localizados.
  static NumberFormat getLocalizedNumberFormatterByLocale(Locale locale) {
    // 1. Obtenemos el formateador de moneda base para el locale dado.
    // Esto asegura que se usa la convención de puntuación correcta (., o ,.)
    final baseFormatter = getCurrencyFormatterByLocale(locale);

    // 2. Creamos un nuevo NumberFormat que COPIA TODAS las propiedades del base
    // (como el locale, decimalDigits, patrones de agrupación),
    // pero establece el símbolo de moneda (symbol) a una cadena vacía ('').
    return NumberFormat.currency(
      locale: baseFormatter.locale,
      // La clave es pasar una cadena vacía para que no muestre el símbolo.
      symbol: '',
      decimalDigits: baseFormatter.decimalDigits,
      // La propiedad name se usa para el patrón de número, si es necesario.
      name: baseFormatter.currencyName,
    );
  }

  // ---  EXTRACCIÓN DEL SÍMBOLO ---

  /// Retorna el símbolo de moneda de tres caracteres (por ejemplo, '€', '\$', '£')
  /// basado en el [locale] de Flutter.
  static String getCurrencySymbolByLocale(Locale locale) {
    // Reutilizamos la lógica de getCurrencyFormatterByLocale para determinar la moneda.
    final formatter = getCurrencyFormatterByLocale(locale);

    // Devolvemos la propiedad currencySymbol del formateador.
    return formatter.currencySymbol;
  }

  static Locale getPlatformLocale() {
    final locales = WidgetsBinding.instance.platformDispatcher.locales;

    // Si la lista de locales de la plataforma está vacía (muy raro), usamos un fallback.
    if (locales.isEmpty) {
      return const Locale('en', 'US');
    }

    // Devolvemos el primer Locale, que es el preferido y más completo.
    return locales.first;
  }

  //###################################################################################
  //###################################################################################
  //FECHAS
  //###################################################################################
  //###################################################################################

  static String customDateFormatShort(DateTime date) {
    String format = "";

    if (date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      format = "Hoy";
    } else if (date.day == DateTime.now().day + 1 &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      format = "Mañana";
    } else if (date.day == DateTime.now().day - 1 &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year) {
      format = "Ayer";
    } else {
      format = DateFormat.yMMMd('es').format(date);
    }
    return format;
  }
}
