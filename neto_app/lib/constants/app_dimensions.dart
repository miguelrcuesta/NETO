import 'package:flutter/material.dart';

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
}
