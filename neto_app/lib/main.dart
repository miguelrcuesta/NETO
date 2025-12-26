import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/firebase_options.dart';
import 'package:neto_app/pages/welcome/auth_wrapper.dart';
import 'package:neto_app/theme/theme.dart';

// Importación de Providers
import 'package:provider/provider.dart';
import 'package:neto_app/provider/user_provider.dart';
import 'package:neto_app/provider/networth_provider.dart';
import 'package:neto_app/provider/reports_provider.dart';
import 'package:neto_app/provider/shared_preferences_provider.dart';
import 'package:neto_app/provider/transaction_provider.dart';

// Importación de Páginas

import 'package:neto_app/pages/home/home.dart';
import 'package:neto_app/pages/networth/read/networth_read_page.dart';
import 'package:neto_app/pages/reports/read/reports_read_page.dart';
import 'package:neto_app/pages/transactions/read/transactions_read_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // 1. Agregamos el UserProvider a la lista
        ChangeNotifierProvider(create: (_) => UserProvider()),

        ChangeNotifierProvider(create: (_) => TransactionsProvider()..loadInitialTransactions()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()..loadInitialReports()),
        ChangeNotifierProvider(create: (_) => NetWorthAssetProvider()..loadInitialAssets()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..initializeSettings()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      title: 'NETO',
      theme: settingsProvider.currentThemeMode == 'light'
          ? CustomLightTheme.lightThemeData()
          : CustomDarkTheme.darkThemeData(),

      // 2. El home ahora es el AuthWrapper
      home: const AuthWrapper(),
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

  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const TransactionsReadPage(),
    const ReportsReadPage(showAppBar: true),
    const NetworthReadPage(),
  ];

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<BottomNavigationBarItem> _navBarItems(BuildContext context) {
    return [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
      const BottomNavigationBarItem(icon: Icon(Icons.compare_arrows_sharp), label: 'Movimientos'),
      const BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Informes'),
      const BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Activos'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colorScheme.surface,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withAlpha(60),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTabChange,
        items: _navBarItems(context),
      ),
    );
  }
}
