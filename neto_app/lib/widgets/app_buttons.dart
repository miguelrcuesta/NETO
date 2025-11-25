import 'package:flutter/material.dart';

//########################################################################
//APPBAR BUTTONS
//########################################################################
class SimpleCircleButton extends StatelessWidget {
  final IconData icon; // El ícono a mostrar dentro del círculo
  final Color?
  backgroundColor; // El color de fondo del círculo (opcional, por defecto transparente)
  final Color? iconColor; // El color del ícono
  final double size; // El tamaño del círculo (width y height)
  final double iconSize;
  final BoxBorder? boxBorder; // El tamaño del ícono
  final VoidCallback onTap; // La función a ejecutar al tocar el botón

  const SimpleCircleButton({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.size = 30,
    this.iconSize = 20,
    this.boxBorder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor, // Asigna el color de fondo aquí
            // border: boxBorder ?? Border.all(color: colorScheme.outlineVariant, width: 1.5),
          ),
          child: Center(
            child: Icon(icon, size: iconSize, color: iconColor ?? colorScheme.surface),
          ),
        ),
      ),
    );
  }
}

class CupertinoColors {}

class StandarButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final double? height;
  final double? width;
  final double? radius;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final BorderSide? side;

  const StandarButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.radius,
    this.height,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.textStyle,
    this.side,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    //double mediaWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor ?? colorScheme.primary,
          minimumSize: Size(width ?? double.infinity, height ?? 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 4.0),
            //borderRadius: AppDimensions.standardBorderRadius,
            side: side ?? BorderSide.none,
            // -----------------------------------------------------------------
          ),
        ),
        child: Text(
          text,
          style: onPressed == null
              ? textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor ?? colorScheme.onSurfaceVariant,
                )
              : textStyle ??
                    textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor ?? colorScheme.onPrimary,
                    ),
        ),
      ),
    );
  }
}
