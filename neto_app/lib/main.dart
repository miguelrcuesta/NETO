import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:neto_app/firebase_options.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/pages/home/home.dart';
import 'package:neto_app/pages/reports/read/reports_read_page.dart';
import 'package:neto_app/pages/transactions/read/transactions_read_page.dart';
import 'package:neto_app/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  int _selectedIndex = 0;
  // 3. Lista de widgets/contenidos que se mostrarán en el cuerpo (body)
  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    TransactionsReadPage(),
    const ReportsReadPage(),

    // Contenido para el índice 2: Informes
    Center(
      child: Text(
        'Página: 2 (Informes)',
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),

    // Contenido para el índice 3: Perfil
    Center(
      child: Text(
        'Página: 3 (Perfil)',
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      // body: _widgetOptions.elementAt(_selectedIndex),
      body: IndexedStack(
        index: _selectedIndex, // Usa el índice seleccionado
        children: _widgetOptions, // Pasa la lista COMPLETA de widgets
      ),
      bottomNavigationBar: Container(
        color: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: GNav(
            color: colorScheme.onSurface,
            backgroundColor: colorScheme.surface,
            activeColor: colorScheme.primary,
            tabBackgroundColor: colorScheme.primary.withAlpha(70),
            gap: 8,
            padding: const EdgeInsets.all(16),
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },

            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.compare_arrows_sharp, text: 'Movimientos'),
              GButton(
                icon: Icons.folder, // Icono más apropiado para Informes
                text: 'Informes',
              ),
              GButton(icon: Icons.person, text: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }
}
