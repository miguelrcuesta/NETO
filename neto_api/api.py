from flask import Flask, jsonify,request

import category_prompt as promt

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
API_KEY = "AIzaSyBha_Lty0xq1Fxkc72POAwKTzNghJ7_0Ck"
#API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_FLASH = 'gemini-2.5-flash' 

#================================================================
#FUNCIONES
#================================================================

# --- FUNCIÓN DE GENERACIÓN DE UNA CATEGORIA CON IA ---
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
            "idcategoria": FALLBACK_CATEGORY, 
            "categoria": FALLBACK_CATEGORY, 
            "subcategoria": FALLBACK_SUBCATEGORY,
            "ia_status": "OFFLINE" # Indica al cliente que la IA no estaba disponible
        }

    try:
        # 1. Inicializar el cliente
        client = genai.Client(api_key=API_KEY)
        
        # 2. Generar el prompt con la descripción
        prompt =promt.get_category_gemini_prompt(description,locale)

        # 3. Llamar a la API con configuración JSON estricta
        response = client.models.generate_content(
            model=GEMINI_FLASH,
            contents=prompt,
            config={
                "response_mime_type": "application/json",
                "response_schema": {
                    "type": "object",
                    "properties": {
                        "idcategoria": {"type": "string"},
                        "categoria": {"type": "string"},
                        "subcategoria": {"type": "string"}
                    },
                    "required": ["idcategoria","categoria", "subcategoria"]
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
            "idcategoria": FALLBACK_CATEGORY, 
            "categoria": FALLBACK_CATEGORY, 
            "subcategoria": FALLBACK_SUBCATEGORY,
            "ia_status": "FAILED" # Falló la llamada a Google
        }
    except Exception as e:
        app.logger.error(f"Error inesperado al procesar la respuesta: {e.args}")
        return {
            "idcategoria": FALLBACK_CATEGORY, 
            "categoria": FALLBACK_CATEGORY, 
            "subcategoria": FALLBACK_SUBCATEGORY,
            "ia_status": "FAILED_UNKNOWN" # Falló el código Python
        }
    
def networth_resume_gemini(asset_data_json: str, user_question: str ,locale: str) -> Dict[str, str]:
    """
    Llama a la API de Gemini para clasificar una transacción y devuelve el resultado.
    Si la API_KEY no está configurada, devuelve un resultado de ERROR/FALLBACK.
    """
    # Define la categoría de fallback para estos casos
    FALLBACK_RESUME = "ERROR"
    

    if not API_KEY:
        # CORRECCIÓN: Eliminamos 'e' y solo registramos el error de configuración.
        app.logger.error("FATAL: La clave GEMINI_API_KEY no está configurada. Devolviendo FALLBACK.")
        
        # Devolvemos un resultado de negocio 200 con un estado OFFLINE
        return {
            "resume": FALLBACK_RESUME, 
            "ia_status": "OFFLINE" 
        }

    try:
        # 1. Inicializar el cliente
        client = genai.Client(api_key=API_KEY)
        
        # 2. Generar el prompt con la descripción
        prompt = promt.get_networth_resume_gemini_prompt(asset_data_json,user_question,locale)

        # 3. Llamar a la API con configuración JSON estricta
        response = client.models.generate_content(
            model=GEMINI_FLASH,
            contents=prompt,
            config={
                "response_mime_type": "application/json",
                "response_schema": {
                    "type": "object",
                    "properties": {
                        "resume": {"type": "string"},
                        
                        
                    },
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
            "resume": FALLBACK_RESUME, 
            "ia_status": "FAILED" # Falló la llamada a Google
        }
    except Exception as e:
        app.logger.error(f"Error inesperado al procesar la respuesta: {e.args}")
        return {
            "resume": FALLBACK_RESUME, 
            "ia_status": "FAILED_UNKNOWN" # Falló el código Python
        }





#================================================================
#LLAMADAS API
#================================================================
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

@app.route('/networthResume', methods=['POST'])
def networth_resume_api():
    print("API RESUME")
    """
    Endpoint que recibe un promt de usuario y devuelve un texto con el resumen de su patrimonio.
    Espera un JSON: {"asset_data_json":<str>,"user_question":<str>  "Analiza la evolución de mi patrimonio en el ultimos años"}
    """
    # 1. Validar la solicitud
    data = request.get_json()
    if not data or 'asset_data_json' not in data:
        return jsonify({"error": "Falta la clave 'asset_data_json' en el cuerpo del JSON."}), 400

    # 2. Obtener el valor del json
    asset_data_json = data.get('asset_data_json', '')
    user_question = data.get('user_question', '')
    locale = data.get('locale', '')

    result = networth_resume_gemini(asset_data_json=asset_data_json,user_question=user_question,locale=locale)

    # 3. Devolver la respuesta al cliente
    
    if result.get("resume") == "ERROR":
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

    print(f"Servidor Flask iniciado. Usa 'http://127.0.0.1:5000' (POST)")
    app.run(debug=True, port=5000)

if __name__ == '__main__':  
   app.run(debug=True,port=5000)