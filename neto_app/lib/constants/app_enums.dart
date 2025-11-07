enum TransactionType {
  income, // Ingreso
  expense; // Gasto

  // Extensión para obtener el string para Firestore
  String toFirestoreString() {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
    }
  }
}

enum TransactionFrequency {
  single, // Única
  monthly, // Mensual
  annual; // Anual

  // Extensión para obtener el string para Firestore
  String toFirestoreString() {
    switch (this) {
      case TransactionFrequency.single:
        return 'single';
      case TransactionFrequency.monthly:
        return 'monthly';
      case TransactionFrequency.annual:
        return 'annual';
    }
  }
}

//STRING TO ENUM
extension StringToEnum on String {
  TransactionType toTransactionType() {
    switch (this) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        // Manejar un error o devolver un valor por defecto si el string es desconocido
        throw ArgumentError('Unknown transaction type: $this');
    }
  }

  TransactionFrequency toTransactionFrequency() {
    switch (this) {
      case 'single':
        return TransactionFrequency.single;
      case 'monthly':
        return TransactionFrequency.monthly;
      case 'annual':
        return TransactionFrequency.annual;
      default:
        throw ArgumentError('Unknown transaction frequency: $this');
    }
  }
}
