// Archivo: services/networth_asset_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//Importamos las clases necesarias (AssetModel, NetWorthAsset)
import 'package:neto_app/models/networth_model.dart';

// --- Definición del resultado paginado (Debería estar en un archivo compartido) ---
// La definimos aquí para que el Service pueda devolverla.
class PaginatedAssetResult {
  final List<AssetModel> data;
  final DocumentSnapshot? lastDocument;

  PaginatedAssetResult({required this.data, this.lastDocument});
}
// ---------------------------------------------------------------------------------

class NetWorthAssetService {
  //Referencia a la colección principal
  final CollectionReference _assetsRef = FirebaseFirestore.instance.collection(
    'networth_assets',
  );

  // =========================================================
  // CARGA DE ACTIVOS (Load Assets for a User)
  // =========================================================

  /// Carga todos los activos de patrimonio neto asociados a un usuario. (Se mantiene para posibles usos)
  Future<List<AssetModel>> loadAssetsByUser(String userId) async {
    // Implementación sin cambios (carga total)
    // ... (Tu código anterior aquí)
    if (userId.isEmpty) return [];

    try {
      final QuerySnapshot snapshot = await _assetsRef
          .where('userId', isEqualTo: userId)
          .get();

      List<AssetModel> assets = [];

      for (var doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // ... (Tu lógica de parsing de AssetModel)
        try {
          assets.add(NetWorthAsset.fromJson(data));
        } catch (e) {
          debugPrint('Error al parsear activo: $e');
        }
      }
      return assets;
    } catch (e) {
      debugPrint('Error al cargar activos: $e');
      throw Exception('Fallo al cargar activos desde la base de datos.');
    }
  }

  // ---------------------------------------------------------
  //NUEVO: Carga paginada de activos
  // ---------------------------------------------------------

  /// Carga activos de forma paginada para un usuario.
  Future<PaginatedAssetResult> fetchAssetsPaginated({
    required String userId,
    DocumentSnapshot? lastDocument,
    int pageSize = 10,
  }) async {
    if (userId.isEmpty) {
      return PaginatedAssetResult(data: [], lastDocument: null);
    }

    try {
      // 1. Crear la consulta base: filtrar por usuario y ordenar
      Query query = _assetsRef
          .where('userId', isEqualTo: userId)
          .orderBy(
            'dateCreated',
            descending: true,
          ) // O el campo que uses para ordenar
          .limit(pageSize);

      // 2. Aplicar la paginación si se proporciona el puntero
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      // 3. Ejecutar la consulta
      final QuerySnapshot snapshot = await query.get();

      List<AssetModel> assets = [];

      for (var doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Asumiendo que NetWorthAsset.fromJson maneja el parsing
        try {
          assets.add(NetWorthAsset.fromJson(data));
        } catch (e) {
          debugPrint('Error al parsear activo paginado: $e');
        }
      }

      // 4. Determinar el último documento para la siguiente página
      final DocumentSnapshot? newLastDocument = snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : null;

      return PaginatedAssetResult(data: assets, lastDocument: newLastDocument);
    } on FirebaseException catch (e) {
      debugPrint(
        'Firebase Error al cargar activos paginados: ${e.code} - ${e.message}',
      );
      throw Exception('Fallo al cargar activos paginados.');
    } catch (e) {
      debugPrint('Error desconocido al cargar activos paginados: $e');
      throw Exception(
        'Error desconocido al procesar la solicitud de paginación.',
      );
    }
  }

  // =========================================================
  // SUBIR/CREAR ACTIVOS (Create New Asset)
  // =========================================================

  /// Sube un nuevo activo a Firestore.
  Future<String?> createAsset(AssetModel newAsset, String userId) async {
    // Implementación sin cambios (CRUD)
    // ... (Tu código anterior aquí)
    try {
      final newDocRef = _assetsRef.doc();
      final newAssetId = newDocRef.id;

      final assetMap = newAsset.toJson();

      assetMap['assetId'] = newAssetId;
      assetMap['userId'] = userId;
      assetMap['dateCreated'] = FieldValue.serverTimestamp();
      assetMap['lastUpdated'] = FieldValue.serverTimestamp();

      await newDocRef.set(assetMap);

      return newAssetId;
    } catch (e) {
      debugPrint('Error al crear activo: $e');
      throw Exception('Fallo al guardar el nuevo activo.');
    }
  }

  // =========================================================
  // ACTUALIZACIÓN DE ACTIVOS (Update Asset)
  // =========================================================

  /// Actualiza un activo existente en Firestore.
  Future<void> updateAsset(AssetModel updatedAsset) async {
    // Implementación sin cambios (CRUD)
    // ... (Tu código anterior aquí)
    if (updatedAsset.assetId == null) {
      throw Exception('El Asset debe tener un assetId para ser actualizado.');
    }

    try {
      final docRef = _assetsRef.doc(updatedAsset.assetId);

      final updateMap = updatedAsset.toJson();

      updateMap['lastUpdated'] = FieldValue.serverTimestamp();

      await docRef.update(updateMap);
    } catch (e) {
      debugPrint('Error al actualizar activo: $e');
      throw Exception('Fallo al actualizar el activo.');
    }
  }

  // =========================================================
  // ELIMINAR DATOS (Delete Asset)
  // =========================================================

  Future<void> deleteAsset(String assetId) async {
    // Implementación sin cambios (CRUD)
    // ... (Tu código anterior aquí)
    try {
      final docRef = _assetsRef.doc(assetId);
      await docRef.delete();
    } catch (e) {
      debugPrint('Error al eliminar activo: $e');
      throw Exception('Fallo al eliminar el activo.');
    }
  }
}
