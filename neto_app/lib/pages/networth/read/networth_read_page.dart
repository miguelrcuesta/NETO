// lib/pages/networth/networth_read_page.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Asume que estos existen en tu proyecto:
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/pages/networth/create/networth_type_create_page.dart';
import 'package:neto_app/pages/networth/read/networth_asset_read_page.dart';
import 'package:neto_app/provider/networth_provider.dart';
import 'package:neto_app/services/api.dart';
import 'package:neto_app/widgets/app_charts.dart'; // Contiene AssetPieChart
import 'package:neto_app/widgets/app_fields.dart'; // Contiene decorationContainer
import 'package:neto_app/widgets/widgets.dart'; // Contiene NetworthTypeCardResume
import 'package:provider/provider.dart';

import 'package:neto_app/models/networth_model.dart'; // Contiene AssetModel y NetWorthAssetTypeDetails

class NetworthReadPage extends StatefulWidget {
  const NetworthReadPage({super.key});

  @override
  State<NetworthReadPage> createState() => _NetworthReadPageState();
}

class _NetworthReadPageState extends State<NetworthReadPage> {
  late final List<Color> _chartColors;

  void _showCreationModal(BuildContext context, ColorScheme colorScheme) async {
    await showCupertinoModalPopup(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CupertinoPageScaffold(
          backgroundColor: colorScheme.primaryContainer,
          navigationBar: CupertinoNavigationBar(
            leading: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Atrás",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: CupertinoColors.systemBlue,
                ),
              ),
            ),
          ),
          child: const NetworthAssetCreatePage(),
        );
      },
    );
    // Recargar los activos al volver del modal
    if (context.mounted) {
      context.read<NetWorthAssetProvider>().loadInitialAssets();
    }
  }

  Future<void> fetchNewIACategory(
    String dataAssets,
    String userQuestion,
  ) async {
    final service = ApiService();
    Map<String, String>? classificationResult;

    // El setState que inicia la carga ya debe estar en obtenerSugerenciaDeCategoria

    try {
      debugPrint('Intentando clasificar: $dataAssets');
      // Usamos await en la llamada de servicio
      classificationResult = await service.getNetWorthAnalysis(
        assetDataJson: dataAssets,
        userQuestion: userQuestion,
      );

      debugPrint('Intentando clasificar: $classificationResult');
    } catch (e) {
      debugPrint('⚠️ Error al contactar al servicio de IA: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    final provider = context.read<NetWorthAssetProvider>();
    if (provider.assets.isEmpty && !provider.isLoadingInitial) {
      provider.loadInitialAssets();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _chartColors = chartColorsStatic;
  }

  // Helper para agrupar activos por tipo
  Map<String, List<AssetModel>> _groupAssetsByType(List<AssetModel> assets) {
    Map<String, List<AssetModel>> grouped = {};
    for (var asset in assets) {
      grouped.putIfAbsent(asset.type, () => []).add(asset);
    }
    return grouped;
  }

  // Helper para calcular el total por tipo y el total general
  Map<String, double> _calculateTypeTotals(List<AssetModel> assets) {
    Map<String, double> totals = {};
    for (var asset in assets) {
      totals.update(
        asset.type,
        (value) => value + asset.currentBalance,
        ifAbsent: () => asset.currentBalance,
      );
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Consumer<NetWorthAssetProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: colorScheme.surface,

          // 1. AppBar Estándar (Fijo)
          appBar: AppBar(
            title: const Text('Activos'),
            backgroundColor: colorScheme.surface,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => _showCreationModal(context, colorScheme),
                icon: Icon(CupertinoIcons.add, color: colorScheme.primary),
              ),
              IconButton(
                onPressed: () =>
                    fetchNewIACategory(provider.getAssetsJson().toString(), ''),
                icon: Icon(CupertinoIcons.sparkles, color: colorScheme.primary),
              ),
            ],
          ),

          // 2. Cuerpo: SingleChildScrollView para el desplazamiento
          body: RefreshIndicator(
            onRefresh: provider.loadInitialAssets,
            child: provider.isLoadingInitial
                ? const Center(child: CircularProgressIndicator())
                : provider.assets.isEmpty
                ? _buildEmptyState(
                    context,
                    colorScheme,
                    Theme.of(context).textTheme,
                  )
                //USAMOS SingleChildScrollView
                : SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Permite el pull-to-refresh
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //1. Tarjeta del Gráfico (en la parte superior)
                        _buildChartContainer(context, provider, colorScheme),

                        ..._buildAssetGroupsWidgets(
                          provider.assets,
                          context,
                          colorScheme,
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  // --- NUEVO: Contenedor del Gráfico (para SingleChildScrollView) ---
  Widget _buildChartContainer(
    BuildContext context,
    NetWorthAssetProvider provider,
    ColorScheme colorScheme,
  ) {
    final Map<String, double> typeTotals = _calculateTypeTotals(
      provider.assets,
    );
    final double totalNetWorth = provider.totalNetWorth;
    final List<String> groupKeys = typeTotals.keys.toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: decorationContainer(
          context: context,
          colorFilled: colorScheme.primaryContainer,
          radius: 20,
        ),
        child: _buildChartCardContent(
          context,
          totalNetWorth,
          typeTotals,
          groupKeys,
          colorScheme,
        ),
      ),
    );
  }

  // --- WIDGET DE LA TARJETA CON EL GRÁFICO (contenido reutilizado) ---
  Widget _buildChartCardContent(
    BuildContext context,
    double totalNetWorth,
    Map<String, double> typeTotals,
    List<String> groupKeys,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Gráfico Circular
        AssetPieChart(
          typeTotals: typeTotals,
          totalNetWorth: totalNetWorth,
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 20),

        // 2. Leyenda
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Balance',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),

              // Muestra las leyendas
              ...groupKeys.take(4).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final typeId = entry.value;
                final amount = typeTotals[typeId]!;

                Color legendColor = _chartColors[index % _chartColors.length];

                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: legendColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          spacing: 5,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              NetWorthAssetTypeDetails.fromId(typeId).title,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              AppFormatters.getFormatedNumber(
                                amount.toString(),
                                amount,
                              ),
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // --- Construye las Cards de Grupo como Widgets List<Widget> ---
  List<Widget> _buildAssetGroupsWidgets(
    List<AssetModel> assets,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final groupedAssets = _groupAssetsByType(assets);
    final List<String> groupKeys = groupedAssets.keys.toList();

    return groupKeys.map((typeId) {
      final List<AssetModel> group = groupedAssets[typeId]!;
      final String title = NetWorthAssetTypeDetails.fromId(typeId).title;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(20.0),
        decoration: decorationContainer(
          context: context,
          colorBorder: colorScheme.primaryContainer,
          radius: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del Grupo
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            // Lista de Assets del Grupo
            ...group.map((asset) {
              return GestureDetector(
                onTap: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          NetworthAssetRead(networthAsset: asset),
                    ),
                  );
                },
                child: NetworthTypeCardResume(
                  titleCard: asset.name,
                  assetType: NetWorthAssetTypeDetails.fromId(asset.type),
                  balance: asset.currentBalance,
                ),
              );
            }),
          ],
        ),
      );
    }).toList();
  }

  // Widget para estado vacío
  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings,
            size: 80,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes activos registrados',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
