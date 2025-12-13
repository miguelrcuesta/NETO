import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/pages/networth/read/networth_read_page.dart';
import 'package:neto_app/pages/profile/profile_page_options.dart';
import 'package:neto_app/provider/networth_provider.dart';
import 'package:neto_app/provider/reports_provider.dart';
import 'package:neto_app/provider/shared_preferences_provider.dart';
import 'package:neto_app/provider/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:neto_app/firebase_options.dart';
import 'package:neto_app/pages/home/home.dart';
import 'package:neto_app/pages/reports/read/reports_read_page.dart';
import 'package:neto_app/pages/transactions/read/transactions_read_page.dart';
import 'package:neto_app/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionsProvider()..loadInitialTransactions(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportsProvider()..loadInitialReports(),
        ),
        ChangeNotifierProvider(
          create: (_) => NetWorthAssetProvider()..loadInitialAssets(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..initializeSettings(),
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
      //NO TOCAR
      //----------------------------------------------------
      supportedLocales: AppLocalizations.supportedLocales,
      //----------------------------------------------------
      localizationsDelegates: const [
        AppLocalizations.delegate, // Carga tus strings (.arb)
        GlobalMaterialLocalizations.delegate, // Textos Material
        GlobalWidgetsLocalizations.delegate, // Direccionalidad
        GlobalCupertinoLocalizations.delegate, // Textos Cupertino
      ],

      title: 'NETO',
      theme: CustomLightTheme.lightThemeData(),
      //home: const ProfilesOptionsPage(),
      home: const MyHomePage(),
    );
  }
}

// ----------------------------------------------------
// WIDGET PRINCIPAL DE NAVEGACIÓN (MYHOMEPAGE)
// ----------------------------------------------------

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  //Lista de widgets/contenidos
  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const TransactionsReadPage(),
    const ReportsReadPage(showAppBar: true),
    const NetworthReadPage(),
    const ProfilesOptionsPage(),
  ];

  // Función de cambio de pestaña
  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Definición de los ítems de navegación (BottomNavigationBarItem)
  List<BottomNavigationBarItem> _navBarItems(BuildContext context) {
    //AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return [
      BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Inicio'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.compare_arrows_sharp),
        label: 'Movimientos',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.folder),
        label: 'Informes',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet),
        label: 'Activos',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme
          .background, // Usar colorScheme.background o colorScheme.surface
      // MODIFICACIÓN: Usamos IndexedStack para mantener el estado de las páginas
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),

      // REEMPLAZO: BottomNavigationBar estándar de Flutter
      bottomNavigationBar: BottomNavigationBar(
        // Propiedades de diseño del BottomNavigationBar
        backgroundColor: colorScheme.surface,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor:
            colorScheme.primary, // Color del ícono y texto seleccionado
        unselectedItemColor: colorScheme.onSurface.withOpacity(
          0.6,
        ), // Color de los íconos inactivos
        type: BottomNavigationBarType
            .fixed, // Mantiene los ítems fijos y visibles
        // Lógica de navegación
        currentIndex: _selectedIndex,
        onTap: _onTabChange,

        // Ítems de navegación
        items: _navBarItems(context),
      ),
    );
  }
}
