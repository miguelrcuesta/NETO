// Archivo: controllers/networth_asset_controller.dart

import 'package:flutter/material.dart';
import 'package:neto_app/models/networth_model.dart'; // Importa AssetModel y NetWorthAsset

import 'package:neto_app/services/networth_services.dart';
import 'package:neto_app/widgets/app_snackbars.dart'; // Asume que tienes este helper de UI
import 'package:cloud_firestore/cloud_firestore.dart';

// Definición de la clase de resultado paginado (Debe estar disponible para el Controller)
class PaginatedAssetResult {
  final List<AssetModel> data;
  final DocumentSnapshot? lastDocument;

  PaginatedAssetResult({required this.data, this.lastDocument});
}

/// Controlador (Middleware de Lógica) que interactúa con el Service.
/// Ya NO gestiona el estado ni notifica a la UI.
class NetWorthAssetController {
  final NetWorthAssetService _assetService;

  NetWorthAssetController() : _assetService = NetWorthAssetService();

  // =========================================================
  // PAGINACIÓN (Nuevo método requerido por el Provider)
  // =========================================================

  /// Carga activos de forma paginada y devuelve el resultado.
  /// La lógica de paginación está principalmente en el Service (Firestore).
  Future<PaginatedAssetResult> getAssetsPaginated({
    required String userId,
    DocumentSnapshot? lastDocument,
    int pageSize = 10,
  }) async {
    //Llamada al Service, que ahora debe implementar la lógica de paginación
    final result = await _assetService.fetchAssetsPaginated(
      userId: userId,
      lastDocument: lastDocument,
      pageSize: pageSize,
    );

    // El Service devuelve una tupla (o un objeto custom) con la lista y el puntero.
    return PaginatedAssetResult(
      data: result.data,
      lastDocument: result.lastDocument,
    );
  }

  // =========================================================
  // LLAMADAS AL SERVICE (CRUD)
  // =========================================================

  /// Carga todos los activos del usuario desde Firestore (Mantenido para compatibilidad o para la carga total, aunque el Provider usará la paginada).
  Future<List<AssetModel>> loadAllAssets(String userId) async {
    try {
      return await _assetService.loadAssetsByUser(userId);
    } catch (e) {
      debugPrint('Error al cargar todos los activos: $e');
      return []; // Devuelve una lista vacía en caso de error
    }
  }

  /// Crea un nuevo activo.
  /// Devuelve el ID generado por Firestore.
  Future<String?> createAsset({
    required BuildContext context,
    required AssetModel newAsset,
    required String currentUserId,
  }) async {
    try {
      // 1. Crear el activo y obtener el nuevo ID
      final newId = await _assetService.createAsset(newAsset, currentUserId);

      return newId; //Devolvemos el ID al Provider para que lo gestione
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppSnackbars.error(message: "Error al crear el activo."),
        );
      }
      debugPrint('🚨 Error en createAsset: $e');
      return null;
    }
  }

  /// Actualiza un activo existente.
  Future<bool> updateAsset({
    required BuildContext context,
    required AssetModel updatedAsset,
  }) async {
    if (updatedAsset.assetId == null) return false;

    try {
      await _assetService.updateAsset(updatedAsset);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(AppSnackbars.success(message: 'Activo actualizado.'));
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppSnackbars.error(message: "Error al actualizar el activo."),
        );
      }
      debugPrint('🚨 Error en updateAsset: $e');
      return false;
    }
  }

  /// Elimina un activo por su ID.
  Future<bool> deleteAsset({
    required BuildContext context,
    required String assetId,
  }) async {
    try {
      await _assetService.deleteAsset(assetId);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(AppSnackbars.success(message: 'Activo eliminado.'));
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          AppSnackbars.error(message: "Error al eliminar el activo."),
        );
      }
      debugPrint('🚨 Error en deleteAsset: $e');
      return false;
    }
  }
}
