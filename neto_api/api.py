import os
import json
from flask import Flask, jsonify, request
from google import genai
from google.genai.errors import APIError
from typing import Dict, Any

# --- CONFIGURACIÓN DE FIREBASE ---
import firebase_admin
from firebase_admin import credentials, firestore

if not firebase_admin._apps:
    # 1. Obtener el string de la variable de entorno
    json_string = os.getenv("FIREBASE_CONFIG")
    
    if json_string:
        # 2. IMPORTANTE: Convertir el string a un Diccionario de Python
        config_dict = json.loads(json_string)
        
        # 3. Pasar el diccionario al Certificado
        cred = credentials.Certificate(config_dict)
        firebase_admin.initialize_app(cred)
    else:
        print("Error: Variable FIREBASE_CONFIG vacía")

db = firestore.client()

# --- CONFIGURACIÓN DE GEMINI ---
import category_prompt as promt
API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_FLASH = 'gemini-2.0-flash' # O la versión que prefieras

app = Flask(__name__)

# ================================================================
# CAPA 1: SERVICIOS DE FIREBASE (Llamadas a la DB)
# ================================================================

def fetch_user_networth_data(uid: str) -> str:
    """
    Consulta la colección 'networth_assets' filtrando por el UID del usuario.
    Devuelve un string JSON con los datos encontrados.
    """
    try:
        # Buscamos en la colección 'networth_assets' donde el campo userId coincida con el uid
        assets_ref = db.collection('networth_assets')
        query = assets_ref.where('userId', '==', uid).stream()

        assets_list = []
        for doc in query:
            data = doc.to_dict()
            # Opcional: convertir timestamps de Firebase a string para JSON
            assets_list.append(data)

        if not assets_list:
            return "[]"
            
        return json.dumps(assets_list, default=str)
    except Exception as e:
        app.logger.error(f"Error en Firebase Service: {e}")
        raise e

# ================================================================
# CAPA 2: SERVICIOS DE GEMINI (Llamadas a la IA)
# ================================================================

def classify_transaction_gemini(description: str, locale: str) -> Dict[str, str]:
    FALLBACK_CATEGORY = "OTROS_GASTOS"
    FALLBACK_SUBCATEGORY = "Otros Gastos Varios"

    if not API_KEY:
        return {"idcategoria": FALLBACK_CATEGORY, "categoria": FALLBACK_CATEGORY, 
                "subcategoria": FALLBACK_SUBCATEGORY, "ia_status": "OFFLINE"}

    try:
        client = genai.Client(api_key=API_KEY)
        prompt = promt.get_category_gemini_prompt(description, locale)
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
                    "required": ["idcategoria", "categoria", "subcategoria"]
                }
            }
        )
        result = json.loads(response.text)
        result["ia_status"] = "SUCCESS"
        return result
    except Exception as e:
        app.logger.error(f"Error Gemini Classify: {e}")
        return {"idcategoria": FALLBACK_CATEGORY, "categoria": "ERROR", "ia_status": "FAILED"}

def networth_resume_gemini(asset_data_json: str, user_question: str, locale: str) -> Dict[str, str]:
    if not API_KEY:
        return {"resume": "ERROR", "ia_status": "OFFLINE"}

    try:
        client = genai.Client(api_key=API_KEY)
        prompt = promt.get_networth_resume_gemini_prompt(asset_data_json, user_question, locale)
        response = client.models.generate_content(
            model=GEMINI_FLASH,
            contents=prompt,
            config={
                "response_mime_type": "application/json",
                "response_schema": {
                    "type": "object",
                    "properties": {"resume": {"type": "string"}},
                    "required": ["resume"]
                }
            }
        )
        result = json.loads(response.text)
        result["ia_status"] = "SUCCESS"
        return result
    except Exception as e:
        app.logger.error(f"Error Gemini Resume: {e}")
        return {"resume": "ERROR", "ia_status": "FAILED"}

# ================================================================
# CAPA 3: LLAMADAS API (Flask Routes)
# ================================================================

@app.route('/classify', methods=['POST'])
def classify_transaction_api():
    data = request.get_json()
    if not data or 'description' not in data:
        return jsonify({"error": "Falta 'description'"}), 400

    result = classify_transaction_gemini(data.get('description'), data.get('locale', 'es'))
    return jsonify(result), 200

@app.route('/networthResume', methods=['POST'])
def networth_resume_api():
    """
    NUEVA LÓGICA: Solo recibe el UID. La API busca los datos en Firebase.
    Payload esperado: {"uid": "12345", "user_question": "...", "locale": "es"}
    """
    data = request.get_json()
    uid = data.get('uid')
    
    if not uid:
        return jsonify({"error": "Falta el 'uid' del usuario."}), 400

    try:
        # 1. Llamada al servicio de Firebase
        asset_data_json = fetch_user_networth_data(uid)
        
        # 2. Llamada al servicio de Gemini con los datos obtenidos de DB
        result = networth_resume_gemini(
            asset_data_json=asset_data_json,
            user_question=data.get('user_question', ''),
            locale=data.get('locale', 'es')
        )

        if result.get("resume") == "ERROR":
            return jsonify(result), 500

        return jsonify(result), 200

    except Exception as e:
        return jsonify({"error": "Error procesando la solicitud en el servidor"}), 500

# --- INICIO DEL SERVIDOR ---
if __name__ == '__main__':
    app.run(debug=True, port=5000)