import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_enums.dart'; // Asegúrate de que esto está disponible
import 'package:neto_app/models/networth_model.dart';
import 'package:neto_app/widgets/app_bars.dart'; // Asumo que TitleAppbarBack está aquí
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:neto_app/widgets/widgets.dart'; // Asumo que NetworthTypeCardResume y decorationContainer están aquí

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  // 🔑 Función de decoración asumida, necesaria para el ListView.builder
  // Si decorationContainer es un widget externo, debes importarlo o definirlo.
  BoxDecoration decorationContainer({
    required BuildContext context,
    required Color colorFilled,
    required double radius,
  }) {
    return BoxDecoration(
      color: colorFilled,
      borderRadius: BorderRadius.circular(radius),
      // Añade otros estilos si es necesario (ej., borde)
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      body: Center(
        child: Column(
          children: [
            Text('Cuentas bancarias'),
            Text('Cuentas bancarias'),
            Text('Cuentas bancarias'),
            Text('Cuentas bancarias'),
          ],
        ),
      ),
    );
  }
}
