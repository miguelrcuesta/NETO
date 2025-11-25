import 'package:flutter/material.dart';

// Un widget de SnackBar personalizado para mensajes de éxito, alerta y error.
// Puedes llamarlo CustomSnackBar o AppSnackBar.

class AppSnackbars {
  // Constructor privado para evitar instanciación, ya que son métodos estáticos.
  AppSnackbars._(); 

  // ===========================================================================
  // 1. ✅ SnackBar de ÉXITO
  // ===========================================================================
  static SnackBar success({
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    return SnackBar(
      content: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 24.0),
          SizedBox(width: 16.0),
          Expanded( // Usar Expanded para que el texto ocupe el espacio restante
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
              overflow: TextOverflow.ellipsis, // Para manejar textos largos
              maxLines: 2, // Limitar a 2 líneas si el texto es muy largo
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green.shade600, // Un verde sólido para éxito
      duration: duration,
      behavior: SnackBarBehavior.floating, // Flotante para esquinas redondeadas
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Esquinas redondeadas
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // Margen para que flote
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // Padding interno
    );
  }

  // ===========================================================================
  // 2. ⚠️ SnackBar de ALERTA (Advertencia)
  // ===========================================================================
  static SnackBar warning({
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    return SnackBar(
      content: Row(
        children: [
          Icon(Icons.warning_rounded, color: Colors.yellow.shade200, size: 24.0), // Icono de advertencia
          SizedBox(width: 16.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.orange.shade700, // Color naranja para advertencia
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
    );
  }

  // ===========================================================================
  // 3. ❌ SnackBar de ERROR
  // ===========================================================================
  static SnackBar error({
    required String message,
    Duration duration = const Duration(seconds: 5), // Un poco más de duración para errores
  }) {
    return SnackBar(
      content: Row(
        children: [
          Icon(Icons.error_rounded, color: Colors.white, size: 24.0), // Icono de error
          SizedBox(width: 16.0),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 16.0),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red.shade700, // Color rojo para error
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
    );
  }
}