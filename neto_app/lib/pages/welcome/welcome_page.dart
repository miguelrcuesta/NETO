import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/pages/welcome/login_page.dart';
import 'package:neto_app/pages/welcome/sing_up_page.dart';
import 'package:neto_app/widgets/app_buttons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      // Padding para simular el espacio de la barra de estado del iPhone (notch)
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.paddingAllMedium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Espacio superior
              const SizedBox(height: 48.0),
              Row(
                children: [
                  Image.asset("assets/logos/logo_1024x1024.png", scale: 20),
                  SizedBox(width: AppDimensions.spacingSmall),
                  Text(
                    "NETO",
                    textAlign: TextAlign.start,
                    style: textTheme.titleLarge!.copyWith(letterSpacing: 6, fontSize: 25),
                  ),
                ],
              ),
              const SizedBox(height: 64.0),
              Text(
                'Bienvenido\na Neto 👋',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w900,

                  color: colorScheme.onSurface,
                ),
              ),

              SizedBox(height: AppDimensions.spacingExtraLarge),

              Text(
                'Una aplicación que te ayuda a seguir tus finanzas de sencilla e intuitiva.',
                style: TextStyle(
                  fontSize: 22,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                  color:
                      colorScheme.onSurfaceVariant, // Usamos el color gris para el texto de cuerpo
                ),
              ),

              const Spacer(),

              const ActionButtons(),

              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Column(
      children: <Widget>[
        // Botón Primario: Crea una cuenta (Violeta/Relleno)
        StandarButton(
          height: AppDimensions.inputFieldHeight,
          width: double.infinity,
          onPressed: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(builder: (BuildContext context) => const SignUpPage()),
            );
          },
          text: appLocalizations.createAccount,
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        StandarButton(
          backgroundColor: colorScheme.primaryContainer,
          textColor: colorScheme.onPrimaryContainer,
          height: AppDimensions.inputFieldHeight,
          width: double.infinity,
          onPressed: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(builder: (BuildContext context) => const LoginPage()),
            );
          },
          text: appLocalizations.loginTitle,
        ),
      ],
    );
  }
}
