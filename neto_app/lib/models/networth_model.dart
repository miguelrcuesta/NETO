import 'package:cloud_firestore/cloud_firestore.dart';

// =========================================================
// 1. CLASE AUXILIAR: Historial de Balance
// =========================================================

/// Clase para el historial de valor/saldo de cualquier activo.
class BalanceHistory {
  final DateTime date;
  final double balance;

  BalanceHistory({required this.date, required this.balance});

  factory BalanceHistory.fromJson(Map<String, dynamic> json) {
    // Manejo de fecha como Timestamp (Firestore) o String (JSON estándar)
    dynamic dateValue = json['date'];
    DateTime date;

    if (dateValue is Timestamp) {
      date = dateValue.toDate();
    } else {
      date = DateTime.tryParse(dateValue as String? ?? '') ?? DateTime.now();
    }

    return BalanceHistory(
      date: date,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    // Para serialización a Firestore, se recomienda usar DateTime/Timestamp
    return {'date': date, 'balance': balance};
  }
}

// =========================================================
// 2. CLASE ABSTRACTA BASE (Tu definición)
// =========================================================

/// Clase abstracta base para todos los activos de patrimonio neto.
abstract class AssetModel {
  final String? assetId;
  final String name;
  final String type;

  final double currentBalance;
  final List<BalanceHistory> history;
  final DateTime? dateCreated;
  final DateTime? lastUpdated;

  AssetModel({
    this.assetId,
    required this.name,
    required this.type,
    required this.currentBalance,
    required this.history,
    this.dateCreated,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson();

  /// 🔑 FIRMA AÑADIDA: Define el método copyWith en la clase abstracta.
  /// Esto asegura que cualquier clase que extienda AssetModel deba implementarlo.
  AssetModel copyWith({
    String? assetId,
    String? name,
    String? type,
    double? currentBalance,
    List<BalanceHistory>? history,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  });
}

// =========================================================
// 3. CLASE CONCRETA: NetWorthAsset (Implementación directa)
// =========================================================

/// Clase concreta que implementa AssetModel para ser usada en la base de datos.
class NetWorthAsset extends AssetModel {
  NetWorthAsset({
    super.assetId,
    required super.name,
    required super.type,
    required super.currentBalance,
    required super.history,
    super.dateCreated,
    super.lastUpdated,
  });

  // ----------------------------------------------------
  // FROM JSON/MAP (Deserialización)
  // ----------------------------------------------------
  factory NetWorthAsset.fromJson(Map<String, dynamic> json) {
    final List<dynamic> historyList = json['history'] ?? [];

    final dateCreated = (json['dateCreated'] as Timestamp?)?.toDate();
    final lastUpdated = (json['lastUpdated'] as Timestamp?)?.toDate();

    return NetWorthAsset(
      assetId: json['assetId'] as String?,
      name: json['name'] as String? ?? 'Unnamed Asset',
      type: json['type'] as String? ?? 'general',

      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      history: historyList
          .map((item) => BalanceHistory.fromJson(item as Map<String, dynamic>))
          .toList(),
      dateCreated: dateCreated,
      lastUpdated: lastUpdated,
    );
  }

  // ----------------------------------------------------
  // TO JSON/MAP (Serialización)
  // ----------------------------------------------------
  @override
  Map<String, dynamic> toJson() {
    return {
      'assetId': assetId,
      'name': name,
      'type': type,
      'currentBalance': currentBalance,
      'history': history.map((h) => h.toJson()).toList(),
      if (dateCreated != null) 'dateCreated': dateCreated,
      if (lastUpdated != null) 'lastUpdated': lastUpdated,
    };
  }

  // ----------------------------------------------------
  // COPY WITH (Implementación OBLIGATORIA)
  // ----------------------------------------------------

  /// Crea una copia del objeto NetWorthAsset, reemplazando los campos opcionales proporcionados.
  @override // Se añade el override porque está en la clase abstracta
  NetWorthAsset copyWith({
    String? assetId,
    String? name,
    String? type,
    double? currentBalance,
    List<BalanceHistory>? history,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  }) {
    return NetWorthAsset(
      assetId: assetId ?? this.assetId,
      name: name ?? this.name,
      type: type ?? this.type,
      currentBalance: currentBalance ?? this.currentBalance,
      history: history ?? this.history,
      dateCreated: dateCreated ?? this.dateCreated,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
