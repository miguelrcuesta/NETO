import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neto_app/controllers/networth_controller.dart';
import 'package:neto_app/models/networth_model.dart';
import 'package:neto_app/provider/user_provider.dart';
import 'package:provider/provider.dart';

// Clase de resultado para la paginación
class PaginatedAssetResult {
  final List<AssetModel> data;
  final DocumentSnapshot? lastDocument;
  PaginatedAssetResult({required this.data, this.lastDocument});
}

class NetWorthAssetProvider extends ChangeNotifier {
  final NetWorthAssetController _controller;

  NetWorthAssetProvider() : _controller = NetWorthAssetController();

  // =========================================================
  // ESTADO CENTRAL
  // =========================================================
  DocumentSnapshot? _lastDocument;
  List<AssetModel> _assets = [];
  bool _hasMore = true;
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  final Set<String> _assetsSelected = {};

  // Getters
  List<AssetModel> get assets => _assets;
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  Set<String> get assetsSelected => _assetsSelected;
  bool get isMultiselectActive => _assetsSelected.isNotEmpty;

  double get totalNetWorth =>
      _assets.fold(0.0, (double sum, asset) => sum + asset.currentBalance);

  //====================================================================
  // FIREBASE / PAGINACIÓN
  //====================================================================

  Future<void> loadInitialAssets() async {
    await Future.delayed(Duration.zero);

    _isLoadingInitial = true;
    _assets = [];
    _lastDocument = null;
    _hasMore = true;
    notifyListeners();

    try {
      await _fetchAndAppendAssets(
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        startAfterDocument: null,
      );
    } catch (e) {
      debugPrint("Error cargando assets iniciales: $e");
    } finally {
      _isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreAssets({required String userId}) async {
    if (!_hasMore || _isLoadingMore || _lastDocument == null) return;

    _isLoadingMore = true;
    notifyListeners();

    await _fetchAndAppendAssets(
      userId: userId,
      startAfterDocument: _lastDocument,
    );

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> _fetchAndAppendAssets({
    required String userId,
    DocumentSnapshot? startAfterDocument,
  }) async {
    try {
      final result = await _controller.getAssetsPaginated(
        userId: userId,
        lastDocument: startAfterDocument,
      );

      if (result.data.isNotEmpty) {
        //_assets.addAll(result.data);
        _assets = result.data;
        _sortAssets();
      }

      _lastDocument = result.lastDocument;
      _hasMore = result.lastDocument != null;
    } catch (e) {
      debugPrint("Error en _fetchAndAppendAssets: $e");
    }
  }

  void _sortAssets() {
    _assets.sort((a, b) {
      final typeComparison = a.type.compareTo(b.type);
      if (typeComparison != 0) return typeComparison;
      return (b.dateCreated ?? DateTime.now()).compareTo(
        a.dateCreated ?? DateTime.now(),
      );
    });
  }

  //====================================================================
  // OPERACIONES CRUD
  //====================================================================

  Future<void> createAssetAndRefresh({
    required BuildContext context,
    required AssetModel newAsset,
    required String userId,
  }) async {
    try {
      final newId = await _controller.createAsset(
        context: context,
        newAsset: newAsset,
        currentUserId: userId,
      );
      if (newId != null) await loadInitialAssets();
    } catch (e) {
      debugPrint("Error al crear activo: $e");
    }
  }

  Future<void> updateAssetAndRefresh({
    required BuildContext context,
    required AssetModel assetmodel,
  }) async {
    try {
      await _controller.updateAsset(context: context, updatedAsset: assetmodel);
      int index = _assets.indexWhere((a) => a.assetId == assetmodel.assetId);
      if (index != -1) {
        _assets[index] = assetmodel;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error al actualizar activo: $e");
    }
  }

  Future<void> deleteAssetAndUpdate({
    required BuildContext context,
    required String assetId,
  }) async {
    try {
      await _controller.deleteAsset(context: context, assetId: assetId);
      _assets.removeWhere((r) => r.assetId == assetId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error al eliminar activo: $e");
    }
  }

  //====================================================================
  // HISTORIAL (Añadir y Eliminar entradas)
  //====================================================================

  Future<void> addHistoryEntry({
    required BuildContext context,
    required AssetModel currentAsset,
    required BalanceHistory newEntry,
  }) async {
    int index = _assets.indexWhere((a) => a.assetId == currentAsset.assetId);
    if (index == -1) return;

    final AssetModel freshAsset = _assets[index];
    final updatedHistory = [...?freshAsset.history, newEntry];
    updatedHistory.sort((a, b) => b.date.compareTo(a.date));

    bool isNewest = updatedHistory.first == newEntry;

    final updatedAsset = (freshAsset as NetWorthAsset).copyWith(
      history: updatedHistory,
      currentBalance: isNewest ? newEntry.balance : freshAsset.currentBalance,
      lastUpdated: isNewest ? newEntry.date : freshAsset.lastUpdated,
    );

    try {
      await _controller.updateAsset(
        context: context,
        updatedAsset: updatedAsset,
      );
      _assets[index] = updatedAsset;
      notifyListeners();
    } catch (e) {
      debugPrint("Error al añadir entrada de historial: $e");
    }
  }

  Future<void> deleteHistoryEntryAndUpdate({
    required BuildContext context,
    required AssetModel currentAsset,
    required BalanceHistory historyEntryToDelete,
  }) async {
    if (currentAsset.assetId == null) return;

    // 1. Filtrar el historial
    final newHistoryList = currentAsset.history!
        .where(
          (h) =>
              h.date.millisecondsSinceEpoch !=
              historyEntryToDelete.date.millisecondsSinceEpoch,
        )
        .toList();

    double newCurrentBalance = currentAsset.currentBalance;
    DateTime newLastUpdated = currentAsset.lastUpdated ?? DateTime.now();

    // 2. Recalcular balance si borramos el más reciente
    final isMostRecent =
        currentAsset.history!.isNotEmpty &&
        historyEntryToDelete.date.isAtSameMomentAs(
          currentAsset.history!.first.date,
        );

    if (isMostRecent && newHistoryList.isNotEmpty) {
      newCurrentBalance = newHistoryList.first.balance;
      newLastUpdated = newHistoryList.first.date;
    } else if (isMostRecent && newHistoryList.isEmpty) {
      newCurrentBalance = 0.0;
      newLastUpdated = currentAsset.dateCreated ?? DateTime.now();
    }

    final updatedAssetModel = (currentAsset as NetWorthAsset).copyWith(
      currentBalance: newCurrentBalance,
      lastUpdated: newLastUpdated,
      history: newHistoryList,
    );

    try {
      await _controller.updateAsset(
        context: context,
        updatedAsset: updatedAssetModel,
      );
      int index = _assets.indexWhere((a) => a.assetId == currentAsset.assetId);
      if (index != -1) {
        _assets[index] = updatedAssetModel;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error al eliminar entrada del historial: $e");
    }
  }

  //====================================================================
  // SELECCIÓN MULTIPLE
  //====================================================================

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

  void clearSelection() {
    _assetsSelected.clear();
    notifyListeners();
  }
}
