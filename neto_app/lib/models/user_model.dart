import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para controlar los niveles de acceso de forma segura
enum SubscriptionType { free, premium, pro }

class UserModel {
  final String? uid;
  final String? email;
  final String currency;
  final SubscriptionType subscriptionType;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    this.uid,
    this.email,
    this.currency = 'EUR',
    this.subscriptionType = SubscriptionType.free,
    this.createdAt,
    this.lastLogin,
  });

  // Para actualizar el estado sin mutar el objeto original
  UserModel copyWith({
    String? uid,
    String? email,
    String? currency,
    SubscriptionType? subscriptionType,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // De Firestore a objeto Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      currency: json['currency'] ?? 'EUR',
      subscriptionType: SubscriptionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['subscriptionType'],
        orElse: () => SubscriptionType.free,
      ),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      lastLogin: json['lastLogin'] != null
          ? (json['lastLogin'] as Timestamp).toDate()
          : null,
    );
  }

  // De objeto Dart a JSON para guardar en Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email, // ⭐️
      'currency': currency,
      'subscriptionType': subscriptionType.toString().split('.').last,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'lastLogin': lastLogin != null
          ? Timestamp.fromDate(lastLogin!)
          : FieldValue.serverTimestamp(),
    };
  }
}
