import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:neto_app/l10n/app_localizations.dart';

// 1. Convertimos a StatefulWidget para manejar el estado de la pestaña seleccionada
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 2. Variable de estado para guardar el índice seleccionado
  

  

  @override
  Widget build(BuildContext context) {
    
    return Center(
      child: Text('Home Page',
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}