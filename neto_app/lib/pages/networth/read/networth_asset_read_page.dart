import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/models/networth_model.dart';
import 'package:neto_app/provider/networth_provider.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:neto_app/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Importación necesaria

class NetworthAssetRead extends StatefulWidget {
  final AssetModel networthAsset;
  const NetworthAssetRead({super.key, required this.networthAsset});

  @override
  State<NetworthAssetRead> createState() => _NetworthAssetReadState();
}

class _NetworthAssetReadState extends State<NetworthAssetRead> {
  //#####################################################################################
  //CONTROLLERS
  //#####################################################################################
  final formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  //#####################################################################################
  //VARIABLES
  //#####################################################################################
  DateTime selectedDate = DateTime.now();

  //#####################################################################################
  // LÓGICA DE GUARDADO (ACTUALIZAR BALANCE)
  //#####################################################################################
  Future<void> _saveAssetHistoryUpdate() async {
    if (formKey.currentState?.validate() ?? false) {
      final newItem = BalanceHistory(
        date: selectedDate,
        balance:
            double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0,
      );

      // La vista manda 'widget.networthAsset', y el Provider ya se encarga
      // de buscar la versión real si esa está vieja.
      await context.read<NetWorthAssetProvider>().addHistoryEntry(
        context: context,
        currentAsset: widget.networthAsset,
        newEntry: newItem,
      );

      amountController.clear();
      // Navigator.pop(context); // Opcional: cerrar tras añadir
    }
  }

  //#####################################################################################
  // ACCIONES
  //#####################################################################################
  void _showActionSheet(
    BuildContext context,
    AssetModel asset,
    NetWorthAssetProvider provider,
  ) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(asset.name),
        message: Text(
          'Última actualización: ${AppFormatters.customDateFormatShort(asset.lastUpdated!)}',
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              _openCreationModal(context, widget.networthAsset, provider);
            },
            child: const Text('Editar'),
          ),
          CupertinoActionSheetAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as delete or exit and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () async {
              await provider.deleteAssetAndUpdate(
                context: context,
                assetId: widget.networthAsset.assetId!,
              );
              if (!context.mounted) return;
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _openCreationModal(
    BuildContext context,
    AssetModel asset,
    NetWorthAssetProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController newNameController = TextEditingController(
          text: asset.name,
        );
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 40.0,
              horizontal: 15.0,
            ),
            child: Column(
              children: [
                StandarTextField(
                  controller: newNameController,
                  colorFocusBorder: Colors.transparent,
                  textInputType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  enable: true,
                  hintText: 'Título',
                  filled: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Introduce un título para el activo.';
                    }
                    return null;
                  },
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    15.0,
                    0.0,
                    15.0,
                    MediaQuery.of(context).viewInsets.bottom + 30.0,
                  ),
                  child: StandarButton(
                    onPressed: () async {
                      //-------------------------UPDATE--------------------------
                      final updatedAssetModel = asset.copyWith(
                        name: newNameController.text,
                      );

                      await provider.updateAssetAndRefresh(
                        context: context,
                        assetmodel: updatedAssetModel,
                      );
                      if (!context.mounted) return;
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    text: 'Editar',
                    radius: 100,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> _showNewBalance(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, myState) {
            return Form(
              key: formKey,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                height: 600,
                decoration: decorationContainer(
                  context: context,
                  colorFilled: colorScheme.surface,
                  radius: 20,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CupertinoNavigationBar(
                        padding: EdgeInsetsDirectional.zero,
                        leading: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Atrás',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        backgroundColor: colorScheme.surface,
                      ),
                      const SizedBox(height: 30),
                      // Campo Fecha
                      GestureDetector(
                        onTap: () async {
                          DateTime tempDate = selectedDate;
                          await showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext pickerContext) {
                              return Container(
                                height: 310,
                                color: Theme.of(context).colorScheme.surface,
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
                                        myState(() {
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
                          padding: const EdgeInsets.all(10.0),
                          decoration: decorationContainer(
                            context: context,
                            colorFilled: colorScheme.primaryContainer,
                            radius: 10,
                          ),
                          child: Text(
                            AppFormatters.customDateFormatShort(selectedDate),
                            style: textTheme.bodyMedium!.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Campo Importe
                      StandarTextField(
                        filledColor: colorScheme.primaryContainer,
                        controller: amountController,
                        colorFocusBorder: Colors.transparent,
                        enable: true,
                        hintText: 'Importe actual',
                        filled: true,
                        textInputType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Introduce el importe actual.';
                          }
                          if (double.tryParse(value.replaceAll(',', '.')) ==
                              null) {
                            return 'El valor debe ser un número.';
                          }
                          return null;
                        },
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        child: StandarButton(
                          radius: 200,
                          onPressed: () {
                            _saveAssetHistoryUpdate();
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          },
                          text: "Actualizar Balance",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext slidableContext,
    AssetModel currentAsset,
    BalanceHistory historyEntry,
    bool isMostRecent,
  ) {
    // Usamos el contexto del State para mostrar el diálogo (más estable)
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            isMostRecent
                ? 'Esta es la entrada más reciente. Eliminarla actualizará el Balance Actual al valor anterior. ¿Continuar?'
                : '¿Estás seguro de que quieres eliminar esta entrada del historial?',
          ),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDestructiveAction: false,
              onPressed: () {
                Navigator.pop(context);
                Slidable.of(context)?.close();
              },
              child: const Text('Cancelar'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.pop(context); // Cierra el diálogo
                Slidable.of(context)?.close(); // Cierra el slidable

                // Llamar a la lógica de eliminación del PROVIDER
                await context
                    .read<NetWorthAssetProvider>()
                    .deleteHistoryEntryAndUpdate(
                      context: context, // Contexto seguro del State
                      currentAsset: currentAsset,
                      historyEntryToDelete: historyEntry,
                    );
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
  //#####################################################################################
  // BUILD
  //#####################################################################################

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Consumer<NetWorthAssetProvider>(
      builder: (context, provider, child) {
        final currentAsset = provider.assets.firstWhere(
          (a) => a.assetId == widget.networthAsset.assetId,
          orElse: () => widget.networthAsset,
        );

        final assetType = NetWorthAssetTypeDetails.fromId(currentAsset.type);

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: CustomScrollView(
              slivers: <Widget>[
                // 1. SLIVERAPPBAR
                SliverAppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Container(
                          color: assetType.backgroundColor,
                          width: 40,
                          height: 40,
                          child: Icon(
                            assetType.iconData,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currentAsset.name, style: textTheme.titleSmall),
                          Text(
                            'Ult. act: ${AppFormatters.customDateFormatShort(currentAsset.lastUpdated!)}',
                            style: textTheme.bodySmall!.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      onPressed: () async {
                        _showActionSheet(context, currentAsset, provider);
                      },
                      icon: Icon(Icons.more_vert),
                    ),
                  ],
                  centerTitle: true,
                  pinned: true,
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: colorScheme.surface,
                      padding: const EdgeInsets.only(top: 108.0),
                      child: NetworthTypeCardResumeSliver(
                        titleCard: currentAsset.name,
                        subtitleCard:
                            'Ultima actualización: ${AppFormatters.customDateFormatShort(currentAsset.lastUpdated!)}',
                        assetType: NetWorthAssetTypeDetails.fromId(
                          currentAsset.type,
                        ),
                        titleBalance: 'Balance',

                        balance: AppFormatters.getFormatedNumber(
                          currentAsset.currentBalance.toString(),
                          currentAsset.currentBalance,
                        ),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Historial de Balances',
                      style: textTheme.titleMedium,
                    ),
                  ),
                ),

                // 2. SLIVERLIST CON SLIDABLE
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: currentAsset.history!.length,
                    (context, index) {
                      final historyEntry = currentAsset.history![index];
                      // el índice 0 es el más reciente (por el sort en el Provider/guardado)
                      final isMostRecent = index == 0;

                      return Slidable(
                        key: ValueKey(historyEntry.date),

                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (slidableContext) {
                                _showDeleteConfirmationDialog(
                                  slidableContext,
                                  currentAsset,
                                  historyEntry,
                                  isMostRecent,
                                );
                              },
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              foregroundColor: Colors.white,
                              icon: CupertinoIcons.delete,
                              label: 'Eliminar',
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ),

                        child: Container(
                          padding: const EdgeInsets.all(13.0),
                          decoration: decorationContainer(
                            context: context,
                            colorFilled: isMostRecent
                                ? colorScheme.primaryContainer
                                : Colors.transparent,
                            radius: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppFormatters.customDateFormatShort(
                                          historyEntry.date,
                                        ),
                                        style: textTheme.bodyMedium!.copyWith(
                                          fontWeight: isMostRecent
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      if (isMostRecent)
                                        Text(
                                          'Balance Actual',
                                          style: textTheme.bodySmall!.copyWith(
                                            fontSize: 10,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                AppFormatters.getFormatedNumber(
                                  historyEntry.balance.toString(),
                                  historyEntry.balance,
                                ),
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // El bottomNavigationBar (Modal para actualizar)
          bottomNavigationBar: SafeArea(
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 30.0),
              child: StandarButton(
                radius: 200,
                onPressed: () async {
                  amountController.text = currentAsset.currentBalance
                      .toString();
                  selectedDate = DateTime.now();

                  await _showNewBalance(context, colorScheme, textTheme);
                },
                text: "Actualizar Balance",
              ),
            ),
          ),
        );
      },
    );
  }
}
