class Transaction {
  final String userId;
  final String type; // 'income' (ingreso) o 'expense' (gasto)
  final double amount;
  final String category;
  final DateTime? date;
  final int year;
  final int month;
  final String frequency; // 'single', 'monthly', o 'annual'

  // --- CAMPOS OPCIONALES ---
  final String? description;
  final String? transactionId;
  final List<String> reportIds;

  // 1. Constructor Completo
  Transaction({
    this.transactionId,
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    this.date,
    required this.year,
    required this.month,
    required this.frequency,
    this.description,
    required this.reportIds,
  });

  // 2. Constructor Vacío (Fácil inicialización en el UI)
  final DateTime datess = DateTime.now();

  Transaction.empty({
    this.userId = '',
    this.type = '',
    this.amount = 0.0,
    this.category = '',
    this.date,
    this.year = 1970,
    this.month = 1,
    this.frequency = 'single',
    this.description,
    this.transactionId,
    this.reportIds = const [],
  });

  // 3. Método copyWith (Para actualizar datos de forma inmutable)
  Transaction copyWith({
    String? transactionId,
    String? userId,
    String? type,
    double? amount,
    String? category,
    DateTime? date,
    int? year,
    int? month,
    String? frequency,
    String? description,
    List<String>? reportIds,
  }) {
    return Transaction(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
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
  factory Transaction.fromMap(Map<String, dynamic> map, {String? transactionId}) {
    // Convierte el Timestamp de Firestore (dynamic) a DateTime de Dart
    DateTime date = (map['date'] as dynamic).toDate();

    return Transaction(
      transactionId: transactionId ?? '',
      userId: map['userId'] as String? ?? 'UNKNOWN_USER',
      type: map['type'] as String? ?? 'UNKNOWN_TYPE',
      amount: (map['amount'] as num? ?? 0.0).toDouble(),
      category: map['category'] as String? ?? 'UNKNOWN_CATEGORY',
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
      'amount': amount,
      'category': category,
      // El SDK de Firebase convierte automáticamente DateTime a Timestamp
      'date': date,
      'year': year,
      'month': month,
      'frequency': frequency,
      'description': description,
      'reportIds': reportIds,
    };
  }
}
