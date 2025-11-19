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
  static String categoriesPromt = """
  GASTOS:
    1. CASA: [Alquiler, Reparación, Muebles/Electrodomésticos, Triturador de basura, Otros]
    2. SALUD: [Gasto en médicos, Medicamentos, Dentista, Otros]
    3. TRANSPORTE: [Combustible, Transporte urbano/taxis, Reparación, Servicio fluidos/neumáticos, Lavado de coches, Otros]
    4. ROPA Y CALZADO: [Ropa de adultos, Ropa de niños, Accesorios, Calzado, Otros]
    5. SEGUROS: [Seguro de vida, Seguro de salud, Seguro de coche, Otros]
    6. HIGIENE: [Cosmética/accesorios, Peluquería, Salón de belleza, Productos de limpieza, Otros]
    7. DIVERSIÓN: [Cine/teatro, Gimnasio/piscina, Cursos/formación, Pasatiempo, Equipos electrónicos, Prensa/revistas, Libros, Otros]
    8. OTROS GASTOS: [Regalos, Gato/perro, Vacaciones, Veterinario, Caridad, Otros.

    INGRESOS:
    9. SALARIO: [Nómina Principal, Horas Extra, Bonificaciones, Ingresos Freelance]
    10. INVERSIONES: [Dividendos, Intereses Bancarios, Alquiler de Propiedades, Venta de Activos]
    11. VENTAS/NEGOCIO: [Venta de Artículos Personales, Ingresos de Negocio Propio, Comisiones, Devoluciones]
    12. OTROS INGRESOS: [Regalos Recibidos, Devolución de Impuestos, Reembolsos, Ingresos Varios/Extraordinarios]

  """;

  static getPromtCategory(String description) {
    List gastos = CategoriaGasto.values
        .map((choice) => {"categoria": choice.nombre, "subcategoria": choice.subcategorias})
        .toList();
    List ingresos = CategoriaGasto.values
        .map((choice) => {"categoria": choice.nombre, "subcategoria": choice.subcategorias})
        .toList();

    List categories = gastos + ingresos;

    return """
          Eres un motor de categorización de movimientos financieros.
          Asigna la categoría principal y subcategoría más apropiada.


          Categorías Válidas gastos: ${categories.toString()}

          Descripción del movimiento que se esta creando: $description. 
          No sean tan estricto con el texto, muchas veces el usuario escribe rápido y se confunde por ejemplo en vez de escribir "gasolina" escribe "gasoli", se inteligente e intuye lo que quiere decir.

          ---
          INSTRUCCIÓN DE SALIDA ESTRICTA:
            Debes responder ÚNICAMENTE con una estructura de datos JSON válida y completa.
            NO INCLUYAS NINGÚN TEXTO INTRODUCTORIO, EXPLICACIÓN, CÓDIGO NI NADA ADICIONAL.
            El formato debe ser EXACTAMENTE el siguiente, sin saltos de línea y con las claves entre comillas dobles:
            {"categoria": "<categoría asignada>", "subcategoria": "<subcategoría asignada>"}
          ---

          SALIDA: quiero un diccionario que sea: {categoria: <categoria>, subcategoría: <subcategoría} y 
          pueda procesarlo en dart/flutter y sin backticks.
      """;
  }
}
