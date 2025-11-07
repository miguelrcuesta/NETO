import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/pages/login_page.dart';
import 'package:neto_app/pages/sing_up_page.dart';
import 'package:neto_app/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 1. Dónde están las traducciones de la app
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'NETO',
      theme: CustomLightTheme.lightThemeData(),
      home: const MyHomePage(title: 'Hola!!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SignUpPage());
  }
}
