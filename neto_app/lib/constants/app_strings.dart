class AppStrings {
  // -----------------------------------------------------
  // 1. NOMBRES DE LA APP Y PANTALLAS
  // -----------------------------------------------------

  static const String appName = 'NETO';
  static const String homeTitle = 'Resumen';
  static const String reportsTitle = 'Informes';
  static const String profileTitle = 'Perfil';
  static const String settingsTitle = 'Configuración';

  // -----------------------------------------------------
  // 2. TÍTULOS DE SECCIONES Y ETIQUETAS
  // -----------------------------------------------------

  static const String sectionRecents = 'Movimientos Recientes';
  static const String sectionFixedExpenses = 'Gastos Fijos';
  static const String totalIncome = 'Ingreso Total';
  static const String totalExpense = 'Gasto Total';
  static const String netBalance = 'Balance Neto';
  static const String fixedPayments = 'Pagos Fijos';

  // -----------------------------------------------------
  // 3. ETIQUETAS DE FORMULARIO DE TRANSACCIÓN
  // -----------------------------------------------------

  static const String newTransactionTitle = 'Añadir Movimiento';
  static const String amountLabel = 'Monto';
  static const String descriptionLabel = 'Descripción (Opcional)';
  static const String dateLabel = 'Fecha';
  static const String categoryLabel = 'Categoría';
  static const String typeLabel = 'Tipo';
  static const String frequencyLabel = 'Frecuencia';
  static const String reportAssociationLabel = 'Asociar a Informe';
  static const String buttonSave = 'Guardar';
  static const String buttonCancel = 'Cancelar';

  // -----------------------------------------------------
  // 4. VALORES DE ENUMS (para mostrar en la UI)
  // -----------------------------------------------------
  // NOTA: Es mejor usar un archivo de internacionalización, pero para
  // un proyecto simple, centralizar aquí es suficiente.

  // Tipo de Movimiento
  static const String typeIncome = 'Ingreso';
  static const String typeExpense = 'Gasto';

  // Frecuencia
  static const String freqSingle = 'Único';
  static const String freqMonthly = 'Mensual';
  static const String freqAnnual = 'Anual';

  // -----------------------------------------------------
  // 5. MENSAJES DE VALIDACIÓN Y ERROR
  // -----------------------------------------------------

  static const String validationRequired = 'Este campo es obligatorio.';
  static const String validationAmountInvalid = 'Monto debe ser mayor a 0.';
  static const String errorGeneric = 'Ocurrió un error. Inténtalo de nuevo.';
  static const String successSaved = 'Movimiento guardado exitosamente.';
}
