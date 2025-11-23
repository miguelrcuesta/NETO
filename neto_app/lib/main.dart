import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/pages/transactions/create/transaction_create_amount_page.dart';
import 'package:neto_app/pages/transactions/create/transaction_create_details_page.dart';
import 'package:neto_app/pages/transactions/read/transactions_read_page.dart';
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
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale('es', 'ES'),
      //supportedLocales: AppLocalizations.supportedLocales,
      title: 'NETO',
      theme: CustomLightTheme.lightThemeData(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: TransactionsPage());
  }
}
