import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/controllers/user_contoller.dart';
import 'package:neto_app/models/user_model.dart';
//import 'package:purchases_flutter/purchases_flutter.dart'; // Descoméntalo cuando instales RevenueCat

class UserProvider with ChangeNotifier {
  final UserController _controller = UserController();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // --------------------------------------------------------------------------
  // Cargar datos cuando el AuthWrapper detecta sesión activa
  // --------------------------------------------------------------------------
  Future<void> loadUserDataLocally(String uid) async {
    try {
      // Evitamos llamadas duplicadas si ya se está cargando
      if (_isLoading) return;

      final userData = await _controller.getUserDataOnly(uid);
      if (userData != null) {
        _user = userData;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error crítico cargando usuario: $e");
    }
  }

  // --------------------------------------------------------------------------
  // REGISTRO
  // --------------------------------------------------------------------------
  Future<void> register(
    BuildContext context,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    _user = await _controller.registerUser(
      context: context,
      email: email,
      password: password,
    );

    if (_user != null) {
      // await Purchases.logIn(_user!.uid!);
    }

    _isLoading = false;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // LOGIN
  // --------------------------------------------------------------------------
  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    _user = await _controller.login(context, email, password);

    if (_user != null) {
      // await Purchases.logIn(_user!.uid!);
    }

    _isLoading = false;
    notifyListeners();
  }

  // --------------------------------------------------------------------------
  // ELIMINAR CUENTA
  // --------------------------------------------------------------------------
  Future<void> deleteAccount(BuildContext context) async {
    if (_user == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _controller.fullDeleteAccount(context, _user!.uid!);
      // await Purchases.logOut();
      _user = null;
    } catch (e) {
      debugPrint("Error al eliminar: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------------------
  // LOGOUT
  // --------------------------------------------------------------------------
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    // await Purchases.logOut();
    _user = null;
    notifyListeners();
  }
}
