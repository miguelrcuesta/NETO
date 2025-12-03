import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neto_app/models/transaction_model.dart';

class ReportModel {
  // 1. Identificadores y Metadatos
  final String reportId;
  final String userId;
  final String name;
  final String? description;
  final DateTime dateCreated;

  final Map<String, ReportTransactionModel> reportTransactions;

  // Constructor
  ReportModel({
    required this.reportId,
    required this.userId,
    required this.name,
    this.description,
    required this.dateCreated,
    required this.reportTransactions,
  });

  // ----------------------------------------------------------------------
  // 1. copyWith
  // ----------------------------------------------------------------------

  ReportModel copyWith({
    String? reportId,
    String? userId,
    String? name,
    String? description,
    DateTime? dateCreated,
    Map<String, ReportTransactionModel>? reportTransactions,
  }) {
    return ReportModel(
      reportId: reportId ?? this.reportId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      dateCreated: dateCreated ?? this.dateCreated,
      reportTransactions: reportTransactions ?? this.reportTransactions,
    );
  }

  // ----------------------------------------------------------------------
  // 2. empty
  // ----------------------------------------------------------------------

  factory ReportModel.empty() {
    return ReportModel(
      reportId: '',
      name: '',
      userId: '',
      dateCreated: DateTime.now(),
      reportTransactions: {},
    );
  }

  // ----------------------------------------------------------------------
  // 3. toJson (Para Firestore)
  // ----------------------------------------------------------------------

  Map<String, dynamic> _reportTransactionsToJson() {
    return reportTransactions.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'userId': userId,
      'name': name,
      'description': description,
      'dateCreated': dateCreated, // Se guarda como Timestamp
      'reportTransactions': _reportTransactionsToJson(),
    };
  }

  // ----------------------------------------------------------------------
  // 4. fromJson (Desde Firestore)
  // ----------------------------------------------------------------------

  // Convierte Map<String, dynamic> de Firestore a objetos ReportTransactionModel
  static Map<String, ReportTransactionModel> _reportTransactionsFromJson(
    Map<String, dynamic> jsonMap,
  ) {
    return jsonMap.map(
      (key, value) => MapEntry(
        key,
        ReportTransactionModel.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    DateTime dateCreated = (json['dateCreated'] as Timestamp).toDate();

    // 🔑 Cargar el mapa de JSONs y convertir a objetos ReportTransactionModel
    final transactionsMap = _reportTransactionsFromJson(
      json['reportTransactions'] as Map<String, dynamic>? ?? {},
    );

    return ReportModel(
      reportId: json['reportId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      dateCreated: dateCreated,
      reportTransactions: transactionsMap,
    );
  }
}

class ReportTransactionModel {
  // Identificadores
  final String reportTransactionId;
  final String reportId; // ID del informe al que pertenece

  // Datos
  final double amount;
  final String typeId; // Ej: 'expense' o 'income'
  final String categoryId; // ID de la categoría (para poder clasificar)
  final String? subcategoryId; // Subcategoría (opcional)
  final DateTime date;
  final String description;

  // Constructor
  ReportTransactionModel({
    required this.reportTransactionId,
    required this.reportId,
    required this.amount,
    required this.typeId,
    required this.categoryId,
    this.subcategoryId,
    required this.date,
    required this.description,
  });

  // ----------------------------------------------------------------------
  // 1. copyWith
  // ----------------------------------------------------------------------

  ReportTransactionModel copyWith({
    String? reportTransactionId,
    String? reportId,
    double? amount,
    String? typeId,
    String? categoryId,
    String? subcategoryId,
    DateTime? date,
    String? description,
  }) {
    return ReportTransactionModel(
      reportTransactionId: reportTransactionId ?? this.reportTransactionId,
      reportId: reportId ?? this.reportId,
      amount: amount ?? this.amount,
      typeId: typeId ?? this.typeId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  // ----------------------------------------------------------------------
  // 2. empty
  // ----------------------------------------------------------------------

  factory ReportTransactionModel.empty({required String reportId}) {
    // Requiere el reportId ya que una ReportTransactionModel siempre debe estar vinculada a un informe.
    return ReportTransactionModel(
      reportTransactionId: '',
      reportId: reportId,
      amount: 0.0,
      typeId: 'expense', // Valor por defecto
      categoryId: '',
      subcategoryId: null,
      date: DateTime.now(),
      description: '',
    );
  }

  // ----------------------------------------------------------------------
  // 3. toJson
  // ----------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'reportTransactionId': reportTransactionId,
      'reportId': reportId,
      'amount': amount,
      'typeId': typeId,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'date': date, // Se guarda como Timestamp en Firestore
      'description': description,
    };
  }

  // ----------------------------------------------------------------------
  // 4. fromJson
  // ----------------------------------------------------------------------

  factory ReportTransactionModel.fromJson(Map<String, dynamic> json) {
    // Convertir el Timestamp de Firestore a DateTime
    DateTime transactionDate;
    if (json['date'] is Timestamp) {
      transactionDate = (json['date'] as Timestamp).toDate();
    } else if (json['date'] is String) {
      transactionDate = DateTime.parse(json['date'] as String);
    } else {
      transactionDate = DateTime.now();
    }

    return ReportTransactionModel(
      reportTransactionId: json['reportTransactionId'] as String,
      reportId: json['reportId'] as String,
      amount: (json['amount'] as num).toDouble(),
      typeId: json['typeId'] as String,
      categoryId: json['categoryId'] as String,
      subcategoryId: json['subcategoryId'] as String?,
      date: transactionDate,
      description: json['description'] as String,
    );
  }

  // ----------------------------------------------------------------------
  // 5. Factory para copiar desde la Transacción Global
  // ----------------------------------------------------------------------

  /// Crea una nueva ReportTransactionModel copiando los datos de una TransactionModel global.
  factory ReportTransactionModel.fromTransactionModel({
    required String reportId,
    required TransactionModel transaction,
    required String newReportTransactionId,
  }) {
    return ReportTransactionModel(
      reportTransactionId: newReportTransactionId,
      reportId: reportId,
      amount: transaction.amount,
      typeId: transaction.type,
      categoryId: transaction.categoryid,
      subcategoryId: transaction.subcategory,
      date: transaction.date!,
      description: transaction.description ?? '',
    );
  }
}
