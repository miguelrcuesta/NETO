import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/pages/welcome/welcome_page.dart';
import 'package:neto_app/provider/user_provider.dart';
import 'package:neto_app/widgets/app_empty_states.dart';
import 'package:provider/provider.dart';

import 'package:neto_app/main.dart'; // Para referenciar MyHomePage

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Cargando conexión con Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Si hay un usuario autenticado en Firebase Auth
        if (snapshot.hasData && snapshot.data != null) {
          // Usamos un Consumer para reaccionar cuando el UserProvider se llene
          return Consumer<UserProvider>(
            builder: (context, userProv, child) {
              // Si el modelo aún no está cargado, lo pedimos y mostramos carga
              if (userProv.user == null) {
                userProv.loadUserDataLocally(snapshot.data!.uid);
                return Scaffold(
                  body: Center(
                    child: AppEmptyStates(
                      heightAsset: 150,
                      asset: 'assets/animations/error.svg',
                      upText: 'Ups ha ocurrido un error',
                      downText:
                          'Ha ocurrido un error inesperado a la hora de iniciar sesión. Disculpe las molestias.',
                      btnText: 'Volver',
                      onPressed: () {
                        Provider.of<UserProvider>(
                          context,
                          listen: false,
                        ).logout();
                      },
                    ),
                  ),
                );
              }

              // Si el modelo ya existe en el Provider, vamos a la Home
              return const MyHomePage();
            },
          );
        }

        // 3. Si no hay sesión, al Login
        return const WelcomeScreen();
      },
    );
  }
}
