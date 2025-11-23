from flask import Flask, jsonify,request
app = Flask(__name__)


###########################################
# GET GEMINI CATEGORY
###########################################

import os
import json
from google import genai
from google.genai.errors import APIError
from typing import Dict, Any

from flask import Flask, jsonify, request

# --- CONFIGURACIÓN DE SEGURIDAD Y APLICACIÓN ---

# 1. Configuración de Flask
app = Flask(__name__)

# 2. Obtener la Clave API de la variable de entorno
API_KEY = os.getenv("GEMINI_API_KEY")
MODEL_NAME = 'gemini-2.5-flash' 

# --- FUNCIÓN DE GENERACIÓN DE PROMPT ---

def get_category_gemini_prompt(description: str,locale: str) -> str:
    
    
    prompt_base = """Eres un motor de categorización de movimientos financieros de alta precisión.
    Tu ÚNICA tarea es asignar la categoría principal y subcategoría más apropiada a la descripción de una transacción, siguiendo las reglas y el formato estricto.
    También eres bilingue, asi que si te paso el idioma tienes que categorizarlo en ese idioma
    IDIOMA: '{locale}'.

    CATEGORÍAS Y SUBCATEGORÍAS VÁLIDAS:
    Debes elegir las claves 'categoria' y 'subcategoria' de la siguiente lista:

    **A. CATEGORÍAS DE GASTOS**

      | ID | Nombre de Categoría | Subcategorías |
      |:---:|:---|:---|
      | VIVIENDA | Vivienda y Hogar | Alquiler, Hipoteca, Servicios (Luz, Agua, Gas), Internet y Telefonía, Reparaciones y Mantenimiento, Muebles y Decoración |
      | ALIMENTACION | Alimentación | Supermercado (Compras), Restaurantes (comer fuera), Comida Rápida, Cafeterías y Bares |
      | TRANSPORTE | Transporte | Combustible/Gasolina, Transporte Público, Taxi/VTC, Mantenimiento de Vehículo, Peajes y Parking |
      | SUSCRIPCIONES | Suscripciones y Cuotas | Netflix, Amazon Prime, Amazon Music, Apple TV, Apple iCloud, Apple Music, Disney+, Youtube Premium, HBO, Movistar, Plataforma Streaming, Gimnasio/Deportes, Software/Apps, Cursos de Formación, Cuotas bancarias |
      | SALUD | Salud y Cuidado | Médico y Dentista, Farmacia y Medicamentos, Seguro de Salud, Cuidado Personal (Peluquería, cosmética) |
      | OCIO | Ocio y Diversión | Cine/Teatro/Conciertos, Viajes y Vacaciones, Hobbies, Compras de Electrónica, Salidas nocturnas |
      | ROPA | Ropa y Accesorios | Ropa, Calzado, Accesorios, Lavandería/Tintorería |
      | OTROS | Otros | Pago de Préstamos/Tarjetas, Regalos, Mascotas (Comida, Veterinario), Donaciones, Multas, Retiro de efectivo |

   **B. CATEGORÍAS DE INGRESOS**

      | ID | Nombre de Categoría | Subcategorías |
      |:---:|:---|:---|
      | SALARIO | Salario | Nómina Principal, Horas Extra, Bonificaciones, Ingresos Freelance |
      | INVERSIONES | Inversiones | Dividendos, Intereses Bancarios, Alquiler de Propiedades, Venta de Activos, Acciones |
      | VENTAS | Ventas/Negocio | Venta de Artículos Personales, Ingresos de Negocio Propio, Comisiones, Devoluciones |
      | OTROS | Otros Ingresos | Regalos Recibidos, Devolución de Impuestos, Reembolsos, Bizum, Ingresos Varios/Extraordinarios |

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
    La respuesta DEBE ser ÚNICAMENTE el objeto JSON que contiene la categoría y la subcategoría.

    FORMATO EXACTO REQUERIDO:
    {{ "categoria": "Nombre de Categoría>", "subcategoria": "<subcategoría asignada>" }}
    ---
    """
    return prompt_base.format(description=description,locale=locale)



def classify_transaction_gemini(description: str,locale: str) -> Dict[str, str]:
    """
    Llama a la API de Gemini para clasificar una transacción y devuelve el resultado.
    Si la API_KEY no está configurada, devuelve un resultado de ERROR/FALLBACK.
    """
    # Define la categoría de fallback para estos casos
    FALLBACK_CATEGORY = "OTROS_GASTOS"
    FALLBACK_SUBCATEGORY = "Otros Gastos Varios" 

    if not API_KEY:
        # CORRECCIÓN: Eliminamos 'e' y solo registramos el error de configuración.
        app.logger.error("FATAL: La clave GEMINI_API_KEY no está configurada. Devolviendo FALLBACK.")
        
        # Devolvemos un resultado de negocio 200 con un estado OFFLINE
        return {
            "categoria": FALLBACK_CATEGORY, 
            "subcategoria": FALLBACK_SUBCATEGORY,
            "ia_status": "OFFLINE" # Indica al cliente que la IA no estaba disponible
        }

    try:
        # 1. Inicializar el cliente
        client = genai.Client(api_key=API_KEY)
        
        # 2. Generar el prompt con la descripción
        prompt = get_category_gemini_prompt(description,locale)

        # 3. Llamar a la API con configuración JSON estricta
        response = client.models.generate_content(
            model=MODEL_NAME,
            contents=prompt,
            config={
                "response_mime_type": "application/json",
                "response_schema": {
                    "type": "object",
                    "properties": {
                        "categoria": {"type": "string"},
                        "subcategoria": {"type": "string"}
                    },
                    "required": ["categoria", "subcategoria"]
                }
            }
        )

        # 4. Devolver el JSON (como diccionario de Python)
        result = json.loads(response.text)
        result["ia_status"] = "SUCCESS"
        return result

    except APIError as e:
        app.logger.error(f"Error de API (Gemini) al clasificar: {e}")
        return {
            "categoria": FALLBACK_CATEGORY, 
            "subcategoria": FALLBACK_SUBCATEGORY,
            "ia_status": "FAILED" # Falló la llamada a Google
        }
    except Exception as e:
        app.logger.error(f"Error inesperado al procesar la respuesta: {e.args}")
        return {
            "categoria": FALLBACK_CATEGORY, 
            "subcategoria": FALLBACK_SUBCATEGORY,
            "ia_status": "FAILED_UNKNOWN" # Falló el código Python
        }

# --- ENDPOINT DE LA API (FLASK) ---

@app.route('/classify', methods=['POST'])
def classify_transaction_api():
    """
    Endpoint que recibe una descripción de transacción y devuelve la clasificación.
    Espera un JSON: {"description": "Pago en Mercadona"}
    """
    # 1. Validar la solicitud
    data = request.get_json()
    if not data or 'description' not in data:
        return jsonify({"error": "Falta la clave 'description' en el cuerpo del JSON."}), 400

    # 2. Obtener el valor del json
    description = data.get('description', '')
    locale = data.get('locale', '')

    result = classify_transaction_gemini(description,locale)

    # 3. Devolver la respuesta al cliente
    
    if result.get("categoria") == "ERROR":
         return jsonify(result), 500 

    return jsonify(result), 200

# --- INICIO DEL SERVIDOR ---

if __name__ == '__main__':
    # Verifica la clave API antes de iniciar
    if not API_KEY:
        print("************************************************************************")
        print("ADVERTENCIA: La clave GEMINI_API_KEY no está configurada.")
        print("Para configurar: export GEMINI_API_KEY='TU_CLAVE'")
        print("************************************************************************")

    print(f"Servidor Flask iniciado. Usa 'http://127.0.0.1:5000/classify' (POST)")
    app.run(debug=True, port=5000)


if __name__ == '__main__':  
   app.run(debug=True,port=5000)