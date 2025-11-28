import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TitleAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? color;

  const TitleAppbar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: color ?? colorScheme.surface,
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

class TitleTabAppbar extends StatelessWidget implements PreferredSizeWidget {
  // Título del AppBar, es requerido.
  final String title;

  // Acciones opcionales a la derecha (ej: botón de configuración).
  final List<Widget>? actions;

  // Si deseas un botón de retroceso (leading) diferente al predeterminado.
  final PreferredSizeWidget? bottom;

  const TitleTabAppbar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

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
      bottom: bottom,
    );
  }

  // Define el tamaño preferido del widget AppBar.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ignore: must_be_immutable
class TitleAppbarBack extends StatelessWidget implements PreferredSizeWidget {
  // Título del AppBar, es requerido.
  final String title;
  PreferredSizeWidget? bottom;

  // Acciones opcionales a la derecha (ej: botón de configuración).
  final List<Widget>? actions;

  TitleAppbarBack({super.key, required this.title, this.actions, this.bottom});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      toolbarHeight: 200,
      backgroundColor: colorScheme.surface,
      title: Text(title, style: textTheme.titleSmall),
      centerTitle: true,
      actions: actions,
      leading: Container(
        alignment: Alignment.topLeft,
        margin: const EdgeInsets.only(left: 24.0),
        child: ClipRRect(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(CupertinoIcons.chevron_back, size: 20),
            ),
          ),
        ),
      ),
      bottom: bottom,
    );
  }
  // onTap: () {
  //   if (Navigator.canPop(context)) {
  //     Navigator.pop(context);
  //   }
  // },

  // Define el tamaño preferido del widget AppBar.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
