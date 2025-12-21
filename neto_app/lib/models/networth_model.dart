import 'package:cloud_firestore/cloud_firestore.dart';

// =========================================================
// 1. CLASE AUXILIAR: Historial de Balance
// =========================================================

class BalanceHistory {
  final DateTime date;
  final double balance;
  final String currency; // <--- Añadido

  BalanceHistory({
    required this.date,
    required this.balance,
    required this.currency, // <--- Añadido
  });

  factory BalanceHistory.fromJson(Map<String, dynamic> json) {
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
      currency: json['currency'] as String? ?? 'USD', // <--- Añadido
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'balance': balance,
      'currency': currency, // <--- Añadido
    };
  }
}

// =========================================================
// 2. CLASE ABSTRACTA BASE
// =========================================================

abstract class AssetModel {
  final String? assetId;
  final String name;
  final String type;
  final String currency; // <--- Añadido

  final double currentBalance;
  final List<BalanceHistory>? history;
  final DateTime? dateCreated;
  final DateTime? lastUpdated;

  AssetModel({
    this.assetId,
    required this.name,
    required this.type,
    required this.currency, // <--- Añadido
    required this.currentBalance,
    this.history,
    this.dateCreated,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson();

  AssetModel copyWith({
    String? assetId,
    String? name,
    String? type,
    String? currency, // <--- Añadido
    double? currentBalance,
    List<BalanceHistory>? history,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  });
}

// =========================================================
// 3. CLASE CONCRETA: NetWorthAsset
// =========================================================

class NetWorthAsset extends AssetModel {
  NetWorthAsset({
    super.assetId,
    required super.name,
    required super.type,
    required super.currency, // <--- Añadido
    required super.currentBalance,
    super.history,
    super.dateCreated,
    super.lastUpdated,
  });

  factory NetWorthAsset.fromJson(Map<String, dynamic> json) {
    final List<dynamic> historyList = json['history'] ?? [];

    final dateCreated = (json['dateCreated'] as Timestamp?)?.toDate();
    final lastUpdated = (json['lastUpdated'] as Timestamp?)?.toDate();

    return NetWorthAsset(
      assetId: json['assetId'] as String?,
      name: json['name'] as String? ?? 'Unnamed Asset',
      type: json['type'] as String? ?? 'general',
      currency: json['currency'] as String? ?? 'USD', // <--- Añadido
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      history: historyList
          .map((item) => BalanceHistory.fromJson(item as Map<String, dynamic>))
          .toList(),
      dateCreated: dateCreated,
      lastUpdated: lastUpdated,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'assetId': assetId,
      'name': name,
      'type': type,
      'currency': currency, // <--- Añadido
      'currentBalance': currentBalance,
      'history': history != null
          ? history!.map((h) => h.toJson()).toList()
          : [],
      if (dateCreated != null) 'dateCreated': dateCreated,
      if (lastUpdated != null) 'lastUpdated': lastUpdated,
    };
  }

  @override
  NetWorthAsset copyWith({
    String? assetId,
    String? name,
    String? type,
    String? currency, // <--- Añadido
    double? currentBalance,
    List<BalanceHistory>? history,
    DateTime? dateCreated,
    DateTime? lastUpdated,
  }) {
    return NetWorthAsset(
      assetId: assetId ?? this.assetId,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency, // <--- Añadido
      currentBalance: currentBalance ?? this.currentBalance,
      history: history ?? this.history,
      dateCreated: dateCreated ?? this.dateCreated,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
