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
import 'package:provider/provider.dart'; // 🚨 Necesario

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
  //#####################################################################################
  //VARIABLES
  //#####################################################################################
  DateTime selectedDate =
      DateTime.now(); // Se mantiene por si se usa para el updatedDate

  //#####################################################################################
  // LÓGICA DE GUARDADO (ACTUALIZAR BALANCE)
  //#####################################################################################
  Future<void> _saveAssetUpdate() async {
    if (formKey.currentState?.validate() ?? false) {
      final netWorthProvider = context.read<NetWorthAssetProvider>();

      // 1. Manejo del formato de número y extracción del balance
      final rawAmount = amountController.text.replaceAll(',', '.');
      final newBalance = double.tryParse(rawAmount) ?? 0.0;
      final assetId = widget.networthAsset.assetId;

      if (assetId == null) {
        // Manejo de error si el ID es nulo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: ID del activo no encontrado.')),
        );
        return;
      }

      // 2. Crear la nueva entrada de historial
      final newItem = BalanceHistory(date: selectedDate, balance: newBalance);

      // 3. CREAR UNA NUEVA LISTA INMUTABLE (Operador Spread)
      // Copiamos el historial existente, añadimos el nuevo ítem.
      final updatedHistory = [...widget.networthAsset.history, newItem];

      // Opcional: Si quieres el historial ordenado por fecha descendente (más nuevo primero)
      updatedHistory.sort((a, b) => b.date.compareTo(a.date));

      // 4. Crear el nuevo AssetModel usando copyWith y la nueva lista de historial
      // Debemos castear a NetWorthAsset para acceder al método copyWith
      final updatedAssetModel = (widget.networthAsset as NetWorthAsset)
          .copyWith(
            currentBalance: newBalance,
            lastUpdated: selectedDate,
            history: updatedHistory, // 🚨 Pasamos la nueva lista inmutable
          );

      // 5. Llamar al Provider para actualizar el activo (DB y Memoria)
      await netWorthProvider.updateAssetAndRefresh(
        context: context,
        assetmodel: updatedAssetModel,
        updatedData: updatedAssetModel.toJson(),
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Balance y historial actualizados.')),
      );
    }
  }

  //#####################################################################################
  // BUILD
  //#####################################################################################

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    // Usamos Consumer para que la vista se refresque cuando el balance cambie en el Provider
    return Consumer<NetWorthAssetProvider>(
      builder: (context, provider, child) {
        // Obtenemos el AssetModel más reciente de la lista del Provider
        // Si no se encuentra, usamos el original (aunque esto debería ser imposible si la lista está cargada)
        final currentAsset = provider.assets.firstWhere(
          (a) => a.assetId == widget.networthAsset.assetId,
          orElse: () => widget.networthAsset,
        );

        final assetType = NetWorthAssetTypeDetails.fromId(currentAsset.type);

        return Scaffold(
          backgroundColor: colorScheme.primaryContainer,
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
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        //borderRadius: BorderRadiusGeometry.all(Radius.circular(100)),
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currentAsset.name, style: textTheme.titleSmall),
                          Text(
                            'Ultima actualización: ${AppFormatters.customDateFormatShort(currentAsset.lastUpdated!)}',
                            style: textTheme.bodySmall!.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  centerTitle: true,
                  pinned: true,
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: colorScheme.primaryContainer,
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

                SliverToBoxAdapter(child: Text('Historico')),

                SliverList(
                  // Usamos la lista de historial del AssetModel actualizado (currentAsset)
                  delegate: SliverChildBuilderDelegate(
                    childCount: currentAsset.history.length,
                    (context, index) {
                      final historyEntry = currentAsset.history[index];
                      return Container(
                        padding: const EdgeInsets.all(13.0),
                        decoration: decorationContainer(
                          context: context,
                          colorFilled: Colors.transparent,
                          radius: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              spacing: 10,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.history,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                Text(
                                  AppFormatters.customDateFormatShort(
                                    historyEntry.date,
                                  ),
                                  style: textTheme.bodyMedium!.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // El bottomNavigationBar se mantiene igual
          bottomNavigationBar: SafeArea(
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 30.0),
              child: StandarButton(
                radius: 200,
                onPressed: () {
                  // Limpiar y configurar valores iniciales del modal
                  amountController.text = currentAsset.currentBalance
                      .toString(); // Sugerir el balance actual
                  selectedDate = DateTime.now();

                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, myState) {
                          return Form(
                            key: formKey,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18.0,
                              ),
                              height: 600,
                              decoration: decorationContainer(
                                context: context,
                                colorFilled: colorScheme.primaryContainer,
                                radius: 20,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: Column(
                                  children: [
                                    // ... (CupertinoNavigationBar)
                                    CupertinoNavigationBar(
                                      padding: EdgeInsetsDirectional.zero,
                                      leading: TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          'Atrás',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                      backgroundColor:
                                          colorScheme.primaryContainer,
                                    ),
                                    const SizedBox(height: 30),
                                    // Campo Fecha (Se mantiene para registrar la fecha de la actualización)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0,
                                        vertical: 10.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Fecha de Actualización",
                                            style: textTheme.bodyMedium!
                                                .copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              DateTime tempDate = selectedDate;
                                              await showCupertinoModalPopup(
                                                context: context,
                                                builder: (BuildContext pickerContext) {
                                                  return Container(
                                                    height: 310,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.surface,
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          height: 250,
                                                          child: CupertinoDatePicker(
                                                            mode:
                                                                CupertinoDatePickerMode
                                                                    .date,
                                                            initialDateTime:
                                                                selectedDate,
                                                            maximumDate:
                                                                DateTime.now(),
                                                            onDateTimeChanged:
                                                                (
                                                                  DateTime
                                                                  newDate,
                                                                ) {
                                                                  tempDate =
                                                                      newDate;
                                                                },
                                                          ),
                                                        ),
                                                        CupertinoButton(
                                                          child: const Text(
                                                            'Aceptar',
                                                          ),
                                                          onPressed: () {
                                                            myState(() {
                                                              selectedDate =
                                                                  tempDate;
                                                            });
                                                            Navigator.pop(
                                                              pickerContext,
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                10.0,
                                              ),
                                              decoration: decorationContainer(
                                                context: context,
                                                colorFilled:
                                                    colorScheme.surface,
                                                radius: 10,
                                              ),
                                              child: Text(
                                                AppFormatters.customDateFormatShort(
                                                  selectedDate,
                                                ),
                                                style: textTheme.bodyMedium!
                                                    .copyWith(
                                                      color:
                                                          colorScheme.onSurface,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    // Campo Importe
                                    StandarTextField(
                                      controller: amountController,
                                      colorFocusBorder: Colors.transparent,
                                      enable: true,
                                      hintText: 'Importe actual',
                                      filled: true,
                                      textInputType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      textInputAction: TextInputAction.done,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[\d.,]'),
                                        ),
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Introduce el importe actual.';
                                        }
                                        if (double.tryParse(
                                              value.replaceAll(',', '.'),
                                            ) ==
                                            null) {
                                          return 'El valor debe ser un número.';
                                        }
                                        return null;
                                      },
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18.0,
                                      ),
                                      child: StandarButton(
                                        radius: 200,

                                        onPressed: _saveAssetUpdate,
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
