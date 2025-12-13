import 'package:neto_app/constants/app_enums.dart';

class AppStrings {
  // -----------------------------------------------------
  // 1. PROMTS
  // -----------------------------------------------------
  static String categoryKeyWoreds = """
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
        .map(
          (choice) => {
            "idcategoria": choice.id,
            "categoria": choice.nombre,
            "subcategoria": choice.subcategorias,
          },
        )
        .toList();
    List ingresos = Incomes.values
        .map(
          (choice) => {
            "idcategoria": choice.id,
            "categoria": choice.nombre,
            "subcategoria": choice.subcategorias,
          },
        )
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
        $categoryKeyWoreds

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
