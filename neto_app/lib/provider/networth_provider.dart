// Archivo: providers/networth_asset_provider.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para DocumentSnapshot

import 'package:neto_app/controllers/networth_controller.dart';
import 'package:neto_app/models/networth_model.dart'; // Importa AssetModel, NetWorthAsset, etc.
// Importaciones de utilidades/snackbars según necesites

// ⭐️ Definición de la clase de resultado paginado (Añadir al archivo donde esté ReportsProvider o Controllers)
// (Asumo que esta estructura es la que devuelve tu Controller para paginación)
class PaginatedAssetResult {
  final List<AssetModel> data;
  final DocumentSnapshot? lastDocument;

  PaginatedAssetResult({required this.data, this.lastDocument});
}

class NetWorthAssetProvider extends ChangeNotifier {
  // 1. Inyección de dependencia (Tu Controller)
  final NetWorthAssetController _controller;
  // Asumiendo que el constructor recibe o inicializa el Controller
  NetWorthAssetProvider() : _controller = NetWorthAssetController() {
    // Si queremos que cargue al inicio, llamamos a la carga inicial.
    // Esto es opcional si prefieres que la UI (initState) la dispare.
    loadInitialAssets();
  }

  // =========================================================
  // ESTADO CENTRAL
  // =========================================================

  // Lista principal de activos
  List<AssetModel> _assets = [];

  // Paginación
  DocumentSnapshot? _lastDocument; // Puntero para la siguiente página
  bool _hasMore = true; // Flag para saber si hay más datos en Firestore

  // Estados de Carga
  bool _isLoadingInitial = false; // Carga de la página 1
  bool _isLoadingMore = false; // Carga de la página N+1

  // Multiselección
  final Set<String> _assetsSelected = {}; // Guarda los assetId seleccionados

  //ID del usuario (Si no lo gestiona el Controller)
  final String _currentUserId = 'MIGUEL_USER_ID';

  // =========================================================
  // Getters (Exposición del Estado a la UI)
  // =========================================================

  List<AssetModel> get assets => _assets;
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  Set<String> get assetsSelected => _assetsSelected;
  bool get isMultiselectActive => _assetsSelected.isNotEmpty;

  // Calculamos el patrimonio neto total a partir de la lista expuesta
  double get totalNetWorth =>
      _assets.fold(0.0, (sum, asset) => sum + asset.currentBalance);

  //====================================================================
  //LÓGICA DE SELECCIÓN
  //====================================================================

  /// Añade o elimina el ID de un activo de la lista de seleccionados.
  void toggleAssetSelection(AssetModel asset) {
    final id = asset.assetId;
    if (id == null) return;

    if (_assetsSelected.contains(id)) {
      _assetsSelected.remove(id);
    } else {
      _assetsSelected.add(id);
    }
    notifyListeners();
  }

  /// Limpia la lista de seleccionados.
  void clearSelection() {
    _assetsSelected.clear();
    notifyListeners();
  }

  List<String> getAssetsJson() {
    return _assets
        // Mapea cada objeto Asset a un Map<String, dynamic>
        .map((asset) => asset.toJson())
        // Convierte cada Map<String, dynamic> a un String JSON
        .map((jsonMap) => jsonMap.toString())
        // Convierte el Iterable<String> resultante a una List<String>
        .toList();
  }

  //====================================================================
  // FIREBASE/PAGINACIÓN (Adaptado de ReportsProvider)
  //====================================================================

  /// Carga el primer lote de activos (Página 1).
  Future<void> loadInitialAssets() async {
    if (_isLoadingInitial) return;

    _isLoadingInitial = true;
    _assets = []; // Limpiar lista para refresco
    _lastDocument = null;
    _hasMore = true;
    notifyListeners();

    await _fetchAndAppendAssets(startAfterDocument: null);

    _isLoadingInitial = false;
    notifyListeners();
  }

  /// Carga la siguiente página de activos.
  Future<void> loadMoreAssets() async {
    if (!_hasMore || _isLoadingMore || _lastDocument == null) return;

    _isLoadingMore = true;
    notifyListeners();

    await _fetchAndAppendAssets(startAfterDocument: _lastDocument);

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Función privada genérica para manejar la consulta y la actualización.
  Future<void> _fetchAndAppendAssets({
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      final result = await _controller.getAssetsPaginated(
        userId: _currentUserId,
        lastDocument: startAfterDocument,
      );

      if (result.data.isNotEmpty) {
        _assets.addAll(result.data);

        // APLICAR ORDENACIÓN PERSONALIZADA AQUÍ
        _assets.sort((a, b) {
          // 1. Ordenar por Tipo de Activo (Alfabético A-Z)
          final typeComparison = a.type.compareTo(b.type);

          if (typeComparison != 0) {
            return typeComparison; // Si los tipos son diferentes, devuelve la comparación de tipo
          }

          // 2. Si los Tipos son iguales, ordenar por Fecha de Creación (Más reciente primero: Descendente)
          // Asumo que 'dateCreated' es el campo a usar y es de tipo comparable (DateTime o Timestamp)
          // Para descendente (más nuevo primero), es b.compareTo(a).
          return b.dateCreated!.compareTo(a.dateCreated!);
        });
      }

      // Actualiza el puntero de paginación
      _lastDocument = result.lastDocument;
      _hasMore = result.lastDocument != null;
    } catch (e) {
      debugPrint("Error al obtener activos paginados: $e");
      // Manejo de error
    }
  }

  //====================================================================
  // CRUD ACCIONES (Adaptado de ReportsProvider)
  //====================================================================

  /// Crea un activo y refresca la lista inicial.
  Future<void> createAssetAndRefresh({
    required BuildContext context,
    required NetWorthAsset newAsset, // Usamos la clase concreta para crear
  }) async {
    try {
      // 1. Crear el activo en la base de datos a través del Controller
      final newId = await _controller.createAsset(
        context: context,
        newAsset: newAsset,
        currentUserId: _currentUserId,
      );

      // Si tienes un nuevo ID, podemos simplemente recargar la primera página,
      // o añadirlo manualmente si la paginación no está activa
      if (newId != null) {
        // Opción Limpia: Recargar la lista inicial para incluir el nuevo activo.
        await loadInitialAssets();
      }
    } catch (e) {
      debugPrint("Error al crear y actualizar el activo: $e");
      // Mostrar SnackBar de error si es necesario
    }
  }

  Future<void> updateAssetAndRefresh({
    required BuildContext context,
    required AssetModel assetmodel, // Necesitas el ID para saber qué actualizar
    required Map<String, dynamic> updatedData, // Los campos a modificar
  }) async {
    try {
      // 1. Actualizar el activo en la base de datos a través del Controller
      await _controller.updateAsset(context: context, updatedAsset: assetmodel);

      // 2. Recargar la lista inicial para reflejar el cambio en la UI.
      // Opción A (Limpia y segura): Recargar la primera página completa.
      //await loadInitialAssets();

      // Actualizar en memoria (Ahorro de llamada)
      int index = _assets.indexWhere((a) => a.assetId == assetmodel.assetId);

      if (index != -1) {
        // Reemplazar la instancia antigua por la nueva instancia actualizada
        _assets[index] = assetmodel;

        //Notificar a los widgets que la lista ha cambiado
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error al actualizar el activo: $e");
    }
  }

  /// Elimina un activo y actualiza la lista.
  Future<void> deleteAssetAndUpdate({
    required BuildContext context,
    required String assetId,
  }) async {
    try {
      // 1. Eliminar del backend
      await _controller.deleteAsset(context: context, assetId: assetId);

      // 2. Eliminar de la lista en memoria
      _assets.removeWhere((r) => r.assetId == assetId);

      notifyListeners();
    } catch (e) {
      debugPrint("Error al eliminar el activo: $e");
    }
  }
}
