import 'package:flutter/material.dart';

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
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('NETO - Home'),
        backgroundColor: colorScheme.surface,
      ),
      body: Center(
        child: Text(
          'Home Page',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
