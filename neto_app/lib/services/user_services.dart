import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neto_app/models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Auth Actions ---
  Future<UserCredential> signUp(String email, String password) async =>
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  Future<UserCredential> signIn(String email, String password) async =>
      await _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() async => await _auth.signOut();

  // --- Firestore Actions ---
  Future<void> saveUser(UserModel user) async =>
      await _db.collection('users').doc(user.uid).set(user.toJson());

  Future<DocumentSnapshot> getUser(String uid) async =>
      await _db.collection('users').doc(uid).get();

  // --- Delete Everything ---
  Future<void> deleteUserData(String uid) async {
    final batch = _db.batch();

    // 1. Borrar todos los assets vinculados al usuario
    final assets = await _db
        .collection('assets')
        .where('userId', isEqualTo: uid)
        .get();
    for (var doc in assets.docs) {
      batch.delete(doc.reference);
    }

    // 2. Borrar el documento del usuario
    batch.delete(_db.collection('users').doc(uid));

    await batch.commit();
  }
}
