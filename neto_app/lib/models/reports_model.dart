import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  // 1. Identificadores y Metadatos
  final String reportId;
  final String userId;
  final String name;
  final String? description;
  final DateTime dateCreated;
  final List<String> listIdTransactions;

  // Constructor
  ReportModel({
    required this.reportId,
    required this.userId,
    required this.name,
    this.description,
    required this.dateCreated,
    required this.listIdTransactions,
  });

  ReportModel copyWith({
    String? reportId,
    String? userId,
    String? name,
    String? description,
    DateTime? dateCreated,
    List<String>? listIdTransactions,
  }) {
    return ReportModel(
      reportId: reportId ?? this.reportId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      // Manejo de nulos para String?: Si el nuevo valor es nulo, usamos el valor original (this.description)
      // Si quieres la opción de establecerlo *explícitamente* a nulo, se requeriría un envoltorio como Value<T>.
      description: description ?? this.description,
      dateCreated: dateCreated ?? this.dateCreated,
      listIdTransactions: listIdTransactions ?? this.listIdTransactions,
    );
  }

  // Método para guardar en la base de datos (Firebase/Firestore)
  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'userId': userId,
      'name': name,
      'description': description,
      'dateCreated': dateCreated, // Formato ISO 8601 para DateTime
      'listIdTransactions': listIdTransactions,
    };
  }

  // Método de fábrica para cargar desde la base de datos
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    DateTime dateCreated = (json['dateCreated'] as Timestamp).toDate();
    return ReportModel(
      reportId: json['reportId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      dateCreated: dateCreated,
      // Asegurar que las listas se carguen como List<String>
      listIdTransactions: List<String>.from(json['listIdTransactions'] as List),
    );
  }

  factory ReportModel.empty() {
    return ReportModel(
      reportId: '',
      name: '',
      userId: '',
      dateCreated: DateTime.now(), // Fecha de creación actual por defecto
      listIdTransactions: [], // Lista de IDs de transacciones vacía
    );
  }
}
