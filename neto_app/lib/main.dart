import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:neto_app/provider/reports_provider.dart';
import 'package:neto_app/provider/transaction_provider.dart';
import 'package:provider/provider.dart'; // 🔑 Importar Provider
import 'package:neto_app/firebase_options.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/pages/home/home.dart';
import 'package:neto_app/pages/reports/read/reports_read_page.dart';
import 'package:neto_app/pages/transactions/read/transactions_read_page.dart';
import 'package:neto_app/theme/theme.dart';
// Asumiendo que transactions_provider.dart existe en providers/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // 1. TransactionsProvider
        ChangeNotifierProvider(
          create: (_) => TransactionsProvider()..loadInitialTransactions(),
        ),
        // 2. ReportsProvider
        ChangeNotifierProvider(
          create: (_) => ReportsProvider()..loadInitialReports(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('es', 'ES'),
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

  // Lista de widgets/contenidos con ValueKey para AnimatedSwitcher
  final List<Widget> _widgetOptions = <Widget>[
    // 🔑 CLAVE: Usar ValueKey para que AnimatedSwitcher pueda distinguir los Widgets
    const HomePage(key: ValueKey(0)),
    TransactionsReadPage(key: const ValueKey(1)),
    const ReportsReadPage(showAppBar: true, key: ValueKey(2)),
    Center(
      key: const ValueKey(3),
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

  // Función de cambio de pestaña
  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,

      // 🔑 CLAVE: Reemplazar IndexedStack por AnimatedSwitcher para la transición
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350), // Duración de la animación
        switchOutCurve: Curves.easeIn,
        switchInCurve: Curves.easeOut,

        // // Constructor de transición (Fade + Scale)
        // transitionBuilder: (child, animation) {
        //   // Animación de escala (entra ligeramente más pequeño)
        //   final scaleAnimation = Tween<double>(
        //     begin: 0.95,
        //     end: 1.0,
        //   ).animate(animation);

        //   // Combinación de Fade y Scale para una transición suave y elegante
        //   return FadeTransition(
        //     opacity: animation,
        //     child: ScaleTransition(scale: scaleAnimation, child: child),
        //   );
        // },
        child: _widgetOptions[_selectedIndex], // El widget que se muestra
      ),

      bottomNavigationBar: Container(
        color: colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: GNav(
            color: colorScheme.onSurface,
            backgroundColor: colorScheme.primaryContainer,
            activeColor: colorScheme.primary,
            tabBackgroundColor: colorScheme.primary.withAlpha(70),
            gap: 8,
            padding: const EdgeInsets.all(16),
            selectedIndex: _selectedIndex,
            onTabChange: _onTabChange,

            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.compare_arrows_sharp, text: 'Movimientos'),
              GButton(icon: Icons.folder, text: 'Informes'),
              GButton(icon: Icons.person, text: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }
}
