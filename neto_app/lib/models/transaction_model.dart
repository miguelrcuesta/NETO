import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String userId;
  final String type;
  final String currency;
  final double amount;
  final String categoryid;
  final String category;
  final String subcategory;
  final DateTime? date;
  final int year;
  final int month;
  final String frequency; // 'single', 'monthly', o 'annual'

  // --- CAMPOS OPCIONALES ---
  final String? description;
  final String? transactionId;
  final List<String> reportIds;

  // 1. Constructor Completo
  TransactionModel({
    this.transactionId,
    required this.userId,
    required this.type,
    required this.currency,
    required this.amount,
    required this.categoryid,
    required this.category,
    required this.subcategory,
    this.date,
    required this.year,
    required this.month,
    required this.frequency,
    this.description,
    required this.reportIds,
  });

  // 2. Constructor Vacío (Fácil inicialización en el UI)
  final DateTime datess = DateTime.now();

  TransactionModel.empty({
    this.userId = '',
    this.type = '',
    this.currency = '',
    this.amount = 0.0,
    this.categoryid = '',
    this.category = '',
    this.subcategory = '',
    this.date,
    this.year = 1970,
    this.month = 1,
    this.frequency = 'single',
    this.description,
    this.transactionId,
    this.reportIds = const [],
  });

  // 3. Método copyWith (Para actualizar datos de forma inmutable)
  TransactionModel copyWith({
    String? transactionId,
    String? userId,
    String? type,
    String? currency,
    double? amount,
    String? categoryid,
    String? category,
    String? subcategory,
    DateTime? date,
    int? year,
    int? month,
    String? frequency,
    String? description,
    List<String>? reportIds,
  }) {
    return TransactionModel(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      categoryid: categoryid ?? this.categoryid,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      date: date ?? this.date,
      year: year ?? this.year,
      month: month ?? this.month,
      frequency: frequency ?? this.frequency,
      description: description ?? this.description,
      transactionId: transactionId ?? this.transactionId,
      reportIds: reportIds ?? this.reportIds,
    );
  }

  // 4. Serialización: Desde Firestore (Map) a Objeto Transaction
  factory TransactionModel.fromMap(Map<String, dynamic> map, {String? transactionId}) {
    // Convierte el Timestamp de Firestore (dynamic) a DateTime de Dart
    DateTime date = (map['date'] as Timestamp).toDate();

    return TransactionModel(
      transactionId: transactionId ?? '',
      userId: map['userId'] as String? ?? 'UNKNOWN_USER',
      type: map['type'] as String? ?? 'UNKNOWN_TYPE',
      currency: map['currency'] as String? ?? 'UNKNOWN_CURRENCY',
      amount: (map['amount'] as num? ?? 0.0).toDouble(),
      categoryid: map['categoryid'] as String? ?? 'UNKNOWN_CATEGORYID',
      category: map['category'] as String? ?? 'UNKNOWN_CATEGORY',
      subcategory: map['subcategory'] as String? ?? 'UNKNOWN_SUBCATEGORY',
      date: date,
      year: map['year'] as int,
      month: map['month'] as int,
      frequency: map['frequency'] as String? ?? 'UNKNOWN_FRECUENCY',
      description: map['description'] as String? ?? 'UNKNOWN_DESCRIPTION',
      reportIds: (map['reportIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  // 5. Serialización: Desde Objeto Transaction a Firestore (Map)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'currency': currency,
      'amount': amount,
      'categoryid': categoryid,
      'category': category,
      'subcategory': subcategory,
      'date': date!,
      'year': year,
      'month': month,
      'frequency': frequency,
      'description': description,
      'reportIds': reportIds,
    };
  }
}
