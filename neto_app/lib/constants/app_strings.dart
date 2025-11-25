import 'package:neto_app/constants/app_enums.dart';

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

  // -----------------------------------------------------
  // 6. PROMT
  // -----------------------------------------------------
  static String palabrasClave = """
  REGLAS DE ASOCIACIÓN DE MARCAS (ALTA PRIORIDAD):
    Si la 'Descripción de la Transacción' contiene alguna de estas palabras clave, DEBES usar la clasificación asignada.

    // TRANSPORTE: Combustible/Gasolina
    - REPSOL, CEPSA O MOEVE, SHELL, BP, WAYLET -> categoria: transporte, subcategoria: Combustible/Gasolina

    // TRANSPORTE: Taxi/VTC
    - UBER, CABIFY -> categoria: transporte, subcategoria: Taxi/VTC

    // ALIMENTACIÓN: Supermercado (Compras)
    - MERCADONA, CARREFOUR, LIDL, DIA, ALDI -> categoria: alimentacion, subcategoria: Supermercado (Compras)

    // ALIMENTACIÓN: Restaurantes (comer fuera)
    - GLOVO, JUST EAT, MCDONALDS, BURGER KING, SAONA,  -> categoria: alimentacion, subcategoria: Restaurantes (comer fuera)

    // SUSCRIPCIONES: Plataforma Streaming
    - NETFLIX, SPOTIFY, DISNEY+, HBO, MOVISTAR+ -> categoria: suscripciones, subcategoria: Plataforma Streaming

    // VIVIENDA: Servicios
    - IBERDROLA, ENDESA, NATURGY, AGUA, LUZ, GAS -> categoria: vivienda, subcategoria: Servicios (Luz, Agua, Gas)

    // OTROS: Retiro de efectivo
    - CAJERO, ATM, DISPOSICION, RETIRO -> categoria: otrosGastos, subcategoria: Retiro de efectivo

    DESCRIPCIÓN DE LA TRANSACCIÓN: "{Descripción de la Transacción}"

    OUTPUT FORMATO ESTRICTO:
    La respuesta DEBE ser ÚNICAMENTE el objeto JSON que contiene la categoría y la subcategoría.

    Ejemplo de Salida:
    {"categoria": "alimentacion", "subcategoria": "Supermercado (Compras)"}

  """;

  static getPromtCategory(String description) {
    List gastos = Expenses.values
        .map((choice) => {"idcategoria": choice.id, "categoria": choice.nombre, "subcategoria": choice.subcategorias})
        .toList();
    List ingresos = Incomes.values
        .map((choice) => {"idcategoria": choice.id, "categoria": choice.nombre, "subcategoria": choice.subcategorias})
        .toList();

    List categories = gastos + ingresos;

    return """
                Eres un motor de categorización de movimientos financieros de alta precisión.
        Tu ÚNICA tarea es asignar la categoría principal y subcategoría más apropiada a la descripción de una transacción, siguiendo las reglas y el formato estricto.

        CATEGORÍAS Y SUBCATEGORÍAS VÁLIDAS:
        Debes elegir las claves 'idcategoria', 'categoria' y 'subcategoria' de la siguiente lista de ENUMs.
        ${categories.toString()}

        REGLAS DE ASOCIACIÓN DE MARCAS (ALTA PRIORIDAD):
        Si la 'Descripción del movimiento' contiene alguna de estas palabras clave, DEBES usar la clasificación asignada en las reglas a continuación:
        $palabrasClave

        DESCRIPCIÓN DEL MOVIMIENTO: $description.

        ---
        INSTRUCCIÓN DE SALIDA ESTRICTA FINAL:
        Debes responder ÚNICAMENTE con una estructura de datos JSON válida y completa.
        NO INCLUYAS NINGÚN TEXTO INTRODUCTORIO, EXPLICACIÓN, SALUDO, CÓDIGO NI NADA ADICIONAL (incluidos los backticks ```json o ```).
        La respuesta debe ser UNICAMENTE el objeto JSON.

        FORMATO EXACTO REQUERIDO:
        {"idcategoria": "<categoría id asignada>","categoria": "<categoría asignada>", "subcategoria": "<subcategoría asignada>"}
        ---

        SALIDA: {"idcategoria": "<categoría id>", "categoria": "<categoría asignada>", "subcategoria": "<subcategoría asignada>"}
      """;
    
  }
}
