class ReportModel {
  // 1. Identificadores y Metadatos
  final String reportId;          
  final String userId;            
  final String name;              
  final String? description;      
  final DateTime dateCreated;     
  final List<String> listIdIncomes; 
  final List<String> listIdExpenses;

  // Constructor
  ReportModel({
    required this.reportId,
    required this.userId,
    required this.name,
    this.description,
    required this.dateCreated,
    required this.listIdIncomes,
    required this.listIdExpenses,
  });

  // Método para guardar en la base de datos (Firebase/Firestore)
  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'userId': userId,
      'name': name,
      'description': description,
      'dateCreated': dateCreated.toIso8601String(), // Formato ISO 8601 para DateTime
      'listIdIncomes': listIdIncomes,
      'listIdExpenses': listIdExpenses,
    };
  }

  // Método de fábrica para cargar desde la base de datos
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      reportId: json['reportId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      // Asegurar que las listas se carguen como List<String>
      listIdIncomes: List<String>.from(json['listIdIncomes'] as List), 
      listIdExpenses: List<String>.from(json['listIdExpenses'] as List),
    );
  }
}