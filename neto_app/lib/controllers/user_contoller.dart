import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/models/user_model.dart';

import 'package:neto_app/services/user_services.dart';
import 'package:neto_app/widgets/app_snackbars.dart';

class UserController {
  final UserService _service = UserService();

  Future<UserModel?> getUserDataOnly(String uid) async {
    try {
      // Llamamos al service que ya creamos antes
      final doc = await _service.getUser(uid);

      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint("Error en UserController.getUserDataOnly: $e");
      // No rethroneamos aquí para evitar que el AuthWrapper falle,
      // simplemente devolvemos null si no hay datos.
      return null;
    }
  }

  Future<UserModel?> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      UserCredential res = await _service.signIn(email, password);
      final doc = await _service.getUser(res.user!.uid);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(AppSnackbars.success(message: '¡Bienvenido!'));
      }
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(AppSnackbars.error(message: _handleAuthError(e)));
      }
      return null;
    }
  }

  Future<UserModel?> registerUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Crear usuario en Auth
      UserCredential res = await _service.signUp(email, password);

      if (res.user != null) {
        // 2. Crear el objeto UserModel inicial
        UserModel newUser = UserModel(
          uid: res.user!.uid,
          currency: 'EUR',
          subscriptionType: SubscriptionType.free,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        // 3. Guardar en Firestore
        await _service.saveUser(newUser);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            AppSnackbars.success(message: '¡Cuenta creada con éxito!'),
          );
        }
        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(AppSnackbars.error(message: _handleAuthError(e)));
      }
      return null;
    }
  }

  Future<void> fullDeleteAccount(BuildContext context, String uid) async {
    try {
      // 1. Datos en DB
      await _service.deleteUserData(uid);
      // 2. Auth (requiere login reciente)
      await FirebaseAuth.instance.currentUser?.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppSnackbars.success(message: 'Cuenta eliminada para siempre.'),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login' && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppSnackbars.error(
            message: 'Reautenticación necesaria para borrar la cuenta.',
          ),
        );
      }
      rethrow;
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario no encontrado.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'El email ya está registrado.';
      default:
        return 'Error: ${e.code}';
    }
  }
}
