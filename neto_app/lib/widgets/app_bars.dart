import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/widgets/app_buttons.dart';

class TitleAppbar extends StatelessWidget implements PreferredSizeWidget {
  // Título del AppBar, es requerido.
  final String title;

  // Acciones opcionales a la derecha (ej: botón de configuración).
  final List<Widget>? actions;

  // Si deseas un botón de retroceso (leading) diferente al predeterminado.
  final Widget? leading;

  const TitleAppbar({super.key, required this.title, this.actions, this.leading});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(title, style: textTheme.titleSmall),
      centerTitle: true,
      actions: actions,
      leading: leading,
    );
  }

  // Define el tamaño preferido del widget AppBar.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class TitleAppbarBack extends StatelessWidget implements PreferredSizeWidget {
  // Título del AppBar, es requerido.
  final String title;

  // Acciones opcionales a la derecha (ej: botón de configuración).
  final List<Widget>? actions;

  const TitleAppbarBack({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(title, style: textTheme.titleSmall),
      centerTitle: true,
      actions: actions,
      leading: SimpleCircleButton(
        icon: CupertinoIcons.add, // El ícono que quieras
        backgroundColor: colorScheme.surface, // Color de fondo
        iconColor: colorScheme.onSurface, // Color del ícono
        size: 50, // Tamaño del botón
        iconSize: 25, // Tamaño del ícono
        onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  // Define el tamaño preferido del widget AppBar.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
