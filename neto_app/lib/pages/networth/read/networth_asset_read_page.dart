import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/models/networth_model.dart';
import 'package:neto_app/provider/networth_provider.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:neto_app/widgets/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class NetworthAssetRead extends StatefulWidget {
  final AssetModel networthAsset;
  const NetworthAssetRead({super.key, required this.networthAsset});

  @override
  State<NetworthAssetRead> createState() => _NetworthAssetReadState();
}

class _NetworthAssetReadState extends State<NetworthAssetRead> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  Future<void> _exportToExcel(AssetModel asset) async {
    try {
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];

      sheet.getRangeByIndex(1, 1).setText('Fecha');
      sheet.getRangeByIndex(1, 2).setText('Balance');
      sheet.getRangeByIndex(1, 3).setText('Activo: ${asset.name}');

      if (asset.history != null) {
        for (int i = 0; i < asset.history!.length; i++) {
          final entry = asset.history![i];
          sheet.getRangeByIndex(i + 2, 1).setDateTime(entry.date);
          sheet.getRangeByIndex(i + 2, 2).setNumber(entry.balance);
        }
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final String path = (await getTemporaryDirectory()).path;
      final String fileName = '$path/Historial_${asset.name}.xlsx';
      final File file = File(fileName);
      await file.writeAsBytes(bytes, flush: true);

      if (await file.exists()) {
        await Share.shareXFiles([
          XFile(fileName),
        ], subject: 'Historial de ${asset.name}');
      }
    } catch (e) {
      debugPrint('Error al exportar Excel: $e');
    }
  }

  Future<void> _saveAssetHistoryUpdate() async {
    if (formKey.currentState?.validate() ?? false) {
      final newItem = BalanceHistory(
        date: selectedDate,
        balance:
            double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0,
        currency: widget.networthAsset.currency,
      );

      await context.read<NetWorthAssetProvider>().addHistoryEntry(
        context: context,
        currentAsset: widget.networthAsset,
        newEntry: newItem,
      );
      amountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<NetWorthAssetProvider>(
      builder: (context, provider, child) {
        final currentAsset = provider.assets.firstWhere(
          (a) => a.assetId == widget.networthAsset.assetId,
          orElse: () => widget.networthAsset,
        );
        final assetType = NetWorthAssetTypeDetails.fromId(currentAsset.type);

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: CustomScrollView(
            slivers: [
              // 1. APPBAR LIMPIO
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: colorScheme.surface,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    onPressed: () =>
                        _showActionSheet(context, currentAsset, provider),
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
                toolbarHeight: 200,

                title: NetworthTypeCardResumeSliver(
                  titleCard: currentAsset.name,
                  subtitleCard:
                      'Actualizado: ${AppFormatters.customDateFormatShort(currentAsset.lastUpdated!)}',
                  assetType: assetType,
                  titleBalance: 'Balance actual',
                  balance: AppFormatters.getFormatedNumber(
                    currentAsset.currentBalance.toString(),
                    currentAsset.currentBalance,
                  ),
                ),
              ),

              if (currentAsset.history!.length > 2)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: SizedBox(
                      height: 100,
                      child: _AssetEvolutionBackgroundChart(
                        history: currentAsset.history ?? [],
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 40)),

              // 3. TÍTULO HISTORIAL + EXCEL
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Historial de Balances',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _exportToExcel(currentAsset),
                        visualDensity: VisualDensity.compact,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.file_download_outlined,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. LISTA DE HISTORIAL
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: currentAsset.history?.length ?? 0,
                    (context, index) {
                      final entry = currentAsset.history![index];
                      final isFirst = index == 0;
                      double? difference;
                      if (index < currentAsset.history!.length - 1) {
                        final previousEntry = currentAsset.history![index + 1];
                        difference = entry.balance - previousEntry.balance;
                      }

                      return _HistoryItemTile(
                        entry: entry,
                        isMostRecent: isFirst,
                        difference: difference,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        onDelete: () => _showDeleteHistoryDialog(
                          currentAsset,
                          entry,
                          isFirst,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          bottomNavigationBar: _buildBottomAction(
            context,
            currentAsset,
            colorScheme,
            textTheme,
          ),
        );
      },
    );
  }

  // [Resto de métodos: _buildBottomAction, _showUpdateBalanceModal, _showActionSheet, _showDeleteHistoryDialog permanecen iguales]

  Widget _buildBottomAction(
    BuildContext context,
    AssetModel asset,
    ColorScheme color,
    TextTheme text,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        child: StandarButton(
          text: "Actualizar Balance",
          radius: 100,
          onPressed: () {
            amountController.text = asset.currentBalance.toString();
            selectedDate = DateTime.now();
            _showUpdateBalanceModal(context, color, text);
          },
        ),
      ),
    );
  }

  void _showUpdateBalanceModal(
    BuildContext context,
    ColorScheme color,
    TextTheme text,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: color.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text("Nuevo Registro", style: text.titleMedium),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () async {
                    DateTime tempDate = selectedDate;
                    await showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext pickerContext) {
                        return Container(
                          height: 310,
                          color: color.surface,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 250,
                                child: CupertinoDatePicker(
                                  mode: CupertinoDatePickerMode.date,
                                  initialDateTime: selectedDate,
                                  maximumDate: DateTime.now(),
                                  onDateTimeChanged: (DateTime newDate) {
                                    tempDate = newDate;
                                  },
                                ),
                              ),
                              CupertinoButton(
                                child: const Text('Aceptar'),
                                onPressed: () {
                                  setModalState(() {
                                    selectedDate = tempDate;
                                  });
                                  Navigator.pop(pickerContext);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: decorationContainer(
                      context: context,
                      colorFilled: color.primaryContainer.withOpacity(0.4),
                      radius: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month),
                        const SizedBox(width: 12),
                        Text(AppFormatters.customDateFormatShort(selectedDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                StandarTextField(
                  enable: true,
                  textInputAction: TextInputAction.done,
                  controller: amountController,
                  hintText: 'Importe actual',
                  textInputType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  filled: true,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Introduce un importe' : null,
                ),
                const SizedBox(height: 25),
                StandarButton(
                  onPressed: () {
                    _saveAssetHistoryUpdate();
                    Navigator.pop(context);
                  },
                  text: "Guardar",
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActionSheet(
    BuildContext context,
    AssetModel asset,
    NetWorthAssetProvider provider,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(asset.name),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              await provider.deleteAssetAndUpdate(
                context: context,
                assetId: asset.assetId!,
              );
              if (mounted) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            child: const Text('Eliminar Activo'),
          ),
        ],
      ),
    );
  }

  void _showDeleteHistoryDialog(
    AssetModel asset,
    BalanceHistory entry,
    bool isMostRecent,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('¿Eliminar registro?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('No'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<NetWorthAssetProvider>()
                  .deleteHistoryEntryAndUpdate(
                    context: context,
                    currentAsset: asset,
                    historyEntryToDelete: entry,
                  );
            },
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );
  }
}

// --- CLASES DE APOYO (IGUALES) ---
class _AssetEvolutionBackgroundChart extends StatelessWidget {
  final List<BalanceHistory> history;
  final Color color;
  const _AssetEvolutionBackgroundChart({
    required this.history,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (history.length < 2) {
      return const Center(
        child: Text("No hay datos suficientes para el gráfico"),
      );
    }
    final sorted = history.reversed.toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: sorted
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.balance))
                .toList(),
            isCurved: true,
            color: color,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.3), color.withOpacity(0)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItemTile extends StatelessWidget {
  final BalanceHistory entry;
  final bool isMostRecent;
  final double? difference;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onDelete;

  const _HistoryItemTile({
    required this.entry,
    required this.isMostRecent,
    this.difference,
    required this.colorScheme,
    required this.textTheme,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color diffColor = Colors.grey;
    IconData diffIcon = Icons.horizontal_rule;
    if (difference != null) {
      if (difference! > 0) {
        diffColor = Colors.green;
        diffIcon = Icons.arrow_upward;
      } else if (difference! < 0) {
        diffColor = Colors.redAccent;
        diffIcon = Icons.arrow_downward;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: colorScheme.error,
              icon: Icons.delete,
              borderRadius: BorderRadius.circular(15),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: decorationContainer(
            context: context,
            colorFilled: isMostRecent
                ? colorScheme.primaryContainer.withOpacity(0.3)
                : colorScheme.surfaceVariant.withOpacity(0.1),
            radius: 15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppFormatters.customDateFormatShort(entry.date),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: isMostRecent
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (isMostRecent)
                    Text(
                      'Balance Actual',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.getFormatedNumber(
                      entry.balance.toString(),
                      entry.balance,
                    ),
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (difference != null && difference != 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: diffColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(diffIcon, size: 10, color: diffColor),
                          const SizedBox(width: 2),
                          Text(
                            AppFormatters.getFormatedNumber(
                              difference!.abs().toString(),
                              difference!.abs(),
                            ),
                            style: textTheme.bodySmall?.copyWith(
                              color: diffColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
