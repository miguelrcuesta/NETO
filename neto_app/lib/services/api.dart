import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Para debugPrint

/// Clase para manejar la comunicación con el servidor de clasificación de gastos (Python/Flask).
class TransactionService {
  // ⚠️ DIRECCIÓN IMPORTANTE:
  // - Para EMULADOR de Android: 'http://10.0.2.2:5000'
  // - Para SIMULADOR de iOS: 'http://localhost:5000'
  // - Para MÁQUINA física en la misma red: 'http://[IP_DE_TU_PC]:5000'
  static const String _baseUrl = 'http://10.0.2.2:5000';
  static const String _endpoint = '/classify';

  /// Llama a la API de Flask para obtener la categoría y subcategoría de una transacción.
  /// Devuelve un mapa con las claves 'categoria', 'subcategoria' y 'ia_status'.
  Future<Map<String, String>> classifyGeminiTransaction(String description, String locale) async {
    final url = Uri.parse('$_baseUrl$_endpoint');

    // Cuerpo de la petición: el formato JSON que espera Flask
    final body = jsonEncode({'description': description, 'locale': locale});

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Indicamos que el cuerpo es JSON
        },
        body: body,
      );

      // Tu API de Flask SIEMPRE devuelve 200 OK, incluso si el IA falló (modo fallback).
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // El servidor Python garantiza estas 3 claves:
        return {
          'categoria': jsonResponse['categoria'] as String,
          'subcategoria': jsonResponse['subcategoria'] as String,
          'ia_status': jsonResponse['ia_status'] as String, // SUCCESS, OFFLINE, o FAILED
        };
      } else {
        // Manejo de errores de HTTP inusuales (ej. un 404 si la ruta no existe)
        debugPrint('Error HTTP inesperado: Código ${response.statusCode}');
        return {
          'categoria': 'ERROR_SERVER',
          'subcategoria': 'Error HTTP: ${response.statusCode}',
          'ia_status': 'FAILED',
        };
      }
    } catch (e) {
      // Manejo de errores de conexión (ej. el servidor está apagado o no hay red)
      debugPrint('Error de conexión con el backend: $e');
      return {'categoria': 'ERROR_NETWORK', 'subcategoria': e.toString(), 'ia_status': 'OFFLINE'};
    }
  }
}
