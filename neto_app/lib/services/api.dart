import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Para debugPrint

/// Clase para manejar la comunicación con el servidor de clasificación de gastos (Python/Flask).
class ApiService {
  // ⚠️ DIRECCIÓN IMPORTANTE:
  // - Para EMULADOR de Android: 'http://10.0.2.2:5000'
  // - Para SIMULADOR de iOS: 'http://localhost:5000'
  // - Para MÁQUINA física en la misma red: 'http://[IP_DE_TU_PC]:5000'
  static const String _baseUrl = 'http://localhost:5000';
  static const String _endpointCategory = '/classify';
  final String _endpointAnalysis = '/networthResume';

  final Duration _timeoutDuration = const Duration(seconds: 25);

  /// Llama a la API de Flask para obtener la categoría y subcategoría de una transacción.
  /// Devuelve un mapa con las claves 'categoria', 'subcategoria' y 'ia_status'.

  Future<Map<String, String>> classifyGeminiTransaction(
    String description,
    String locale,
  ) async {
    final url = Uri.parse('$_baseUrl$_endpointCategory');

    // Cuerpo de la petición: el formato JSON que espera Flask
    final body = jsonEncode({'description': description, 'locale': locale});

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type':
                  'application/json', // Indicamos que el cuerpo es JSON
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              // Si el servidor tarda más de 2 segundos, lanza una excepción
              throw const SocketException(
                'El servidor no respondió a tiempo (Timeout de 2 segundos).',
              );
            },
          );

      // Tu API de Flask SIEMPRE devuelve 200 OK, incluso si el IA falló (modo fallback).
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // El servidor Python garantiza estas 3 claves:
        return {
          'idcategoria': jsonResponse['idcategoria'] as String,
          'categoria': jsonResponse['categoria'] as String,
          'subcategoria': jsonResponse['subcategoria'] as String,
          'ia_status':
              jsonResponse['ia_status'] as String, // SUCCESS, OFFLINE, o FAILED
        };
      } else {
        // Manejo de errores de HTTP inusuales (ej. un 404 si la ruta no existe)
        debugPrint('Error HTTP inesperado: Código ${response.statusCode}');
        return {
          'idcategoria': '',
          'categoria': '',
          'subcategoria': '',
          'ia_status': 'FAILED/OFFLINE',
        };
      }
    } catch (e) {
      // Manejo de errores de conexión (incluyendo el nuevo error de timeout)
      debugPrint('Error de conexión con el backend: $e');

      // Comprobamos si el error es el de timeout específico
      if (e.toString().contains('SocketException') &&
          e.toString().contains('Timeout')) {
        return {
          'idcategoria': '',
          'categoria': 'ERROR_TIMEOUT',
          'subcategoria': 'Tiempo de espera agotado (2s).',
          'ia_status': 'OFFLINE',
        };
      }

      // Para otros errores de red/conexión
      return {
        'idcategoria': '',
        'categoria': 'ERROR_NETWORK',
        'subcategoria': e.toString(),
        'ia_status': 'OFFLINE',
      };
    }
  }

  Future<Map<String, String>> getNetWorthAnalysis({
    required String assetDataJson,
    required String userQuestion,
  }) async {
    final url = Uri.parse('$_baseUrl$_endpointAnalysis');

    // Cuerpo de la petición: El formato JSON que espera Flask/Python
    final body = jsonEncode({
      'asset_data_json': assetDataJson, // Datos JSON de los activos
      'user_question': userQuestion, // La pregunta/solicitud del usuario
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Tu API de Flask/Python DEBE devolver 200 OK
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        // El servidor Python debe garantizar estas claves:
        return {
          'resume':
              jsonResponse['resume']
                  as String, // El texto largo y estructurado de la IA
          'ia_status':
              jsonResponse['ia_status'] as String, // SUCCESS, OFFLINE, o FAILED
        };
      } else {
        // Manejo de errores de HTTP inusuales
        debugPrint('Error HTTP inesperado: Código ${response.statusCode}');
        return {
          'resume': 'Error HTTP ${response.statusCode}',
          'ia_status': 'FAILED/OFFLINE',
        };
      }
    } catch (e) {
      // Manejo de errores de conexión y timeout
      debugPrint('Error de conexión con el backend: $e');

      String errorMessage = 'Error de conexión con la red.';
      String status = 'OFFLINE';

      if (e is TimeoutException ||
          (e is SocketException && e.toString().contains('Timeout'))) {
        errorMessage =
            'Tiempo de espera agotado (${_timeoutDuration.inSeconds}s). El análisis es demasiado complejo o los datos son muy grandes.';
        status = 'OFFLINE';
      }

      return {'resume': errorMessage, 'ia_status': status};
    }
  }
}
