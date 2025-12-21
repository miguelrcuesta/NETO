
        
def get_category_gemini_prompt(description: str,locale: str) -> str:
    
    
    prompt_base = """Eres un motor de categorización de movimientos financieros de alta precisión.
    Tu ÚNICA tarea es asignar la categoría principal y subcategoría más apropiada a la descripción de una transacción, siguiendo las reglas y el formato estricto.
    También eres bilingue, asi que si te paso el idioma tienes que categorizarlo en ese idioma
    IDIOMA: '{locale}'.

    CATEGORÍAS Y SUBCATEGORÍAS VÁLIDAS:
    Debes elegir las claves 'idcategoria','categoria' y 'subcategoria' de la siguiente lista:

    A. CATEGORÍAS DE GASTOS

        | ID | Nombre de Categoría | Subcategorías |
        |:---:|:---|:---|
        | VIVIENDA | Vivienda y Hogar | Alquiler, Hipoteca, Comunidad/Vecinos, Seguro de Vivienda, Derramas, Electricidad, Agua, Gas/Calefacción, Internet y Telefonía, Tasa de Basura/Reciclaje, Impuestos de Propiedad (IBI), Reparaciones y Mantenimiento, Mobiliario y Decoración, Electrodomésticos, Productos de Limpieza. |
        | ALIMENTACION | Alimentación | Supermercados, Restaurantes, Comida Rápida, Cafeterías y Bares. |
        | TRANSPORTE | Transporte | Combustible/Gasolina, Transporte Público, Taxi/VTC, Mantenimiento de Vehículo, Peajes y Parking. |
        | EDUCACION | Educación y Formación | Guardería, Colegio, Universidad (Grado), Universidad (Master), Academia, Clases Particulares. |
        | SUSCRIPCIONES | Suscripciones y Cuotas | Netflix, Amazon Prime, Amazon Music, Apple TV, Apple iCloud, Apple Music, Disney+, Youtube Premium, HBO, Movistar, Plataforma Streaming, Gimnasio/Deportes, Software/Apps, Cursos de Formación, Cuotas bancarias. |
        | SALUD | Salud y Cuidado | Médico y Dentista, Farmacia y Medicamentos, Seguro de Salud, Cuidado Personal (Peluquería, cosmética). |
        | OCIO | Ocio y Diversión | Teatro, Cine, Conciertos, Viajes, Hobbies, Compras de Electrónica, Salidas nocturnas. |
        | ROPA | Ropa y Accesorios | Ropa, Calzado, Accesorios, Costura, Lavandería/Tintorería. |
        | TECNOLOGIA | Tecnología y Electrónica | Teléfonos y Smartphones, Ordenadores y Laptops, Tablets y E-readers, Televisores y Audio/Vídeo (Cine en Casa), Consolas y Videojuegos (Hardware), Accesorios y Periféricos, Dispositivos Vestibles (Smartwatch, Pulseras), Cámaras y Equipos de Fotografía, Reparación de Dispositivos, Garantías y Seguros de Electrónica, Componentes (Hardware, Tarjetas Gráficas, RAM). |
        | OTROS | Otros | 'Otros',Pago de Préstamos/Tarjetas, Regalos, Mascotas (Comida, Veterinario), Donaciones, Multas, Retiro de efectivo. |

   **B. CATEGORÍAS DE INGRESOS**

      | ID | Nombre de Categoría | Subcategorías |
      |:---:|:---|:---|
      | SALARIO | Salario | Nómina Principal, Horas Extra, Bonificaciones, Ingresos Freelance |
      | INVERSIONES | Inversiones | Dividendos, Intereses Bancarios, Alquiler de Propiedades, Venta de Activos, Acciones |
      | VENTAS | Ventas/Negocio | Venta de Artículos Personales, Ingresos de Negocio Propio, Comisiones, Devoluciones |
      | OTROS | Otros Ingresos | 'Otros', Regalos Recibidos, Devolución de Impuestos, Reembolsos, Bizum, Ingresos Varios/Extraordinarios |

      ---
    
    REGLAS DE ASOCIACIÓN DE MARCAS (ALTA PRIORIDAD):
    - REPSOL, CEPSA O MOEVE, SHELL, BP, WAYLET -> categoria: TRANSPORTE, subcategoria: Combustible/Gasolina
    - UBER, CABIFY -> categoria: TRANSPORTE, subcategoria: Taxi/VTC
    - MERCADONA, CARREFOUR, LIDL, DIA, ALDI -> categoria: ALIMENTACION, subcategoria: Supermercado (Compras)
    - GLOVO, JUST EAT, MCDONALDS, BURGER KING, SAONA,  -> categoria: ALIMENTACION, subcategoria: Restaurantes (comer fuera)
    - NETFLIX, SPOTIFY, DISNEY+, HBO, MOVISTAR+ -> categoria: SUSCRIPCIONES, subcategoria: Plataforma Streaming
    - IBERDROLA, ENDESA, NATURGY, AGUA, LUZ, GAS -> categoria: VIVIENDA, subcategoria: Servicios (Luz, Agua, Gas)
    - CAJERO, ATM, DISPOSICION, RETIRO -> categoria: OTROS_GASTOS, subcategoria: Retiro de efectivo

    ---
    ENTRADA (DESCRIPCIÓN DEL MOVIMIENTO): '{description}'.
    INSTRUCCIÓN DE SALIDA ESTRICTA FINAL:
    Debes responder ÚNICAMENTE con una estructura de datos JSON válida y completa.
    NO INCLUYAS NINGÚN TEXTO INTRODUCTORIO, EXPLICACIÓN, SALUDO, CÓDIGO NI NADA ADICIONAL.

    OUTPUT FORMATO ESTRICTO:
    La respuesta DEBE ser ÚNICAMENTE el objeto JSON que contiene el idcategoria, categoría y la subcategoría.

    FORMATO EXACTO REQUERIDO:
    {{ "idcategoria": "ID de Categoría>","categoria": "Nombre de Categoría>", "subcategoria": "<subcategoría asignada>" }}
    ---
    """
    return prompt_base.format(description=description,locale=locale)


def get_networth_resume_gemini_prompt(asset_data_json: str,user_question: str,locale: str) -> str:
    
    
    prompt_base = """
        Eres un Asistente de Análisis de Patrimonio Neto (Net Worth Analyst) experto, preciso y profesional.
        Tu tarea es analizar un listado estos activos proporcionado en formato JSON '{asset_data_json} . El JSON contiene la lista de activos y el historial completo de balances ('history') para cada uno. Debes realizar las tareas de análisis solicitadas y responder de forma clara y estructurada.

        ### Tareas de Análisis Solicitadas
        Realiza todas las siguientes tareas de análisis y utiliza la estructura de salida pedida por el usuario:

        #### 1. Resumen y Desglose Actual
        * **Patrimonio Neto Total:** Calcula y presenta el valor total de la suma de todos los 'currentBalance'.
        * **Desglose por Categoría:** Agrupa todos los activos por su campo 'type' (ej. 'bankAccount', 'realEstate', 'investment') y calcula el subtotal de 'currentBalance' para cada tipo.

        #### 2. Evolución Histórica del Balance General
        Analiza el historial completo del balance general (la suma de todos los 'currentBalance' en cada punto del tiempo registrado en 'history') y presenta las siguientes métricas de crecimiento:
        * **Evolución Mensual (MoM):** Calcula el cambio porcentual medio del balance total mes a mes.
        * **Evolución Anual (YoY):** Calcula el cambio porcentual del balance total en los últimos 12 meses y desde el inicio del registro histórico.

        #### 3. Evolución Histórica por Activo
        Para cada activo individual en la lista, analiza su historial ('history') y presenta:
        * **Evolución Mensual (MoM):** Cambio porcentual medio del balance mes a mes.
        * **Evolución Anual (YoY):** Cambio porcentual del balance en los últimos 12 meses y desde el inicio del registro histórico.

        #### 4. Identificación de Mayor Crecimiento
        * **Máximo Crecimiento:** Identifica el activo individual que ha tenido el mayor crecimiento porcentual (retorno total) desde su fecha de creación o su primer registro histórico.

        #### Si el usuario te pregunta algo '{user_question}', empieza por lo que pregunta el usuario y luego complementa diciendo, te voy a dar más información que es muy interesante:

        ### Formato de Salida
        La respuesta debe estar estructurada usando **bullets y encabezados claros (Markdown)** para garantizar una fácil y rápida lectura.

        OUTPUT FORMATO ESTRICTO:
        La respuesta DEBE ser ÚNICAMENTE el objeto JSON que contiene la respuesta de la IA.

        FORMATO EXACTO REQUERIDO:
        {{ "resume": <respuesta de la IA de Gemini>" }}

        ---
        """
    return prompt_base.format(asset_data_json=asset_data_json,user_question=user_question,locale=locale)



      