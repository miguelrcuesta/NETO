import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/pages/transactions/create/transaction_create_details_page.dart';
import 'package:neto_app/provider/shared_preferences_provider.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:neto_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class TransactionAmountCreatePage extends StatefulWidget {
  final bool isEditable;
  final bool isForReport;
  final TransactionModel? transactionModel;
  final ReportModel? reportModel;

  const TransactionAmountCreatePage({
    super.key,
    this.transactionModel,
    this.reportModel,
    required this.isEditable,
    required this.isForReport,
  });

  @override
  State<TransactionAmountCreatePage> createState() =>
      _TransactionAmountCreatePageState();
}

class _TransactionAmountCreatePageState
    extends State<TransactionAmountCreatePage> {
  // ########################################################################
  // CONTROLLERS & FOCUS
  // ########################################################################
  final _formKey = GlobalKey<FormState>();
  final FocusNode _amountFocusNode = FocusNode();

  // ########################################################################
  // VARIABLES DE ESTADO
  // ########################################################################
  String amountString = '0';
  double amount = 0;
  late String currency;
  late TransactionModel transactionModel;

  // ########################################################################
  // LÓGICA UX DE MONTO
  // ########################################################################

  void _updateAmount(AmountUpdate update) {
    // 1. Limpiamos el string: el teclado usa '.', nos aseguramos de que sea consistente
    String newAmountString = update.newAmount;
    final UpdateDirection direction = update.direction;
    const int maxLength = 12;

    // 2. Manejo de BORRADO
    if (direction == UpdateDirection.delete) {
      setState(() {
        amountString = newAmountString.isEmpty ? '0' : newAmountString;
        amount = double.tryParse(amountString) ?? 0.0;
      });
      return;
    }

    // 3. Manejo de AÑADIR
    if (direction == UpdateDirection.add) {
      // Si lo último es un punto, actualizamos el string pero el double se mantiene igual
      // Esto permite que el teclado mantenga su estado de "acabo de poner un punto"
      if (newAmountString.endsWith('.')) {
        setState(() {
          amountString = newAmountString;
          // El amount no cambia significativamente al añadir un punto al final (50.0 == 50)
          amount = double.tryParse("${amountString}0") ?? amount;
        });
        return;
      }

      // Validación de longitud y actualización normal
      if (newAmountString.length <= maxLength) {
        setState(() {
          amountString = newAmountString;
          amount = double.tryParse(amountString) ?? 0.0;
        });
      }
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   transactionModel = widget.transactionModel ?? TransactionModel.empty();

  //   if (widget.transactionModel != null && widget.isEditable) {
  //     amount = widget.transactionModel!.amount;
  //     amountString = amount.toString();
  //     currency = widget.transactionModel!.currency;
  //   } else {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       currency = Provider.of<SettingsProvider>(context).currentCurrency;
  //     });
  //   }

  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     FocusScope.of(context).requestFocus(_amountFocusNode);
  //     currency = Provider.of<SettingsProvider>(context).currentCurrency;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    // 1. Inicialización del modelo
    transactionModel = widget.transactionModel ?? TransactionModel.empty();

    // 2. Si es edición, pre-cargamos los valores
    if (widget.transactionModel != null && widget.isEditable) {
      amount = widget.transactionModel!.amount;

      // Limpiamos el double para que no muestre .0 si es un entero (UX mejorada)
      // Ejemplo: 10.0 -> "10", 10.5 -> "10.5"
      amountString = amount % 1 == 0
          ? amount.toInt().toString()
          : amount.toString();

      currency = widget.transactionModel!.currency;
    } else {
      setState(() {
        currency = Provider.of<SettingsProvider>(
          context,
          listen: false,
        ).currentCurrency;
      });
    }

    // 3. Un solo PostFrameCallback para lógica que requiere el Context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Solicitar foco
      if (_amountFocusNode.canRequestFocus) {
        FocusScope.of(context).requestFocus(_amountFocusNode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    //final settingsProvider = Provider.of<SettingsProvider>(context);
    // currency = settingsProvider.currentCurrency;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(width: 200, child: _widgetAmount(textTheme)),
                          PopupMenuButton<String>(
                            menuPadding: EdgeInsets.only(right: 30),
                            popUpAnimationStyle: AnimationStyle(),
                            shape: RoundedRectangleBorder(
                              // Define el radio de las esquinas
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            color: colorScheme.surface,

                            child: Text(currency, style: textTheme.titleLarge),

                            // 2. EL CONTENIDO DEL MENÚ (Los items que aparecen)
                            itemBuilder: (BuildContext context) {
                              return Currency.availableCurrencies.map((
                                Currency cur,
                              ) {
                                return PopupMenuItem<String>(
                                  // onTap: () {
                                  //   currency = cur.code;
                                  // },
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  value: cur.code,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0,
                                    ),
                                    child: Text(cur.code),
                                  ),
                                );
                              }).toList();
                            },

                            onSelected: (String selectedCode) {
                              setState(() {
                                currency = selectedCode;
                                debugPrint(currency);
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      TransactionKeyBoardWidget(
                        initialAmount: amountString,
                        onAmountChange: _updateAmount,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButton(colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  // ########################################################################
  // WIDGETS
  // ########################################################################

  Widget _widgetAmount(TextTheme textTheme) {
    String displayValue;

    // Si el usuario está escribiendo decimales, mostramos el string tal cual
    // para no perder el punto visual que el teclado está gestionando.
    if (amountString.contains('.')) {
      // Si termina en punto, le añadimos visualmente los ceros sin alterar el estado
      if (amountString.endsWith('.')) {
        displayValue =
            "${AppFormatters.getFormatedNumber(amountString.replaceAll('.', ''), amount)},00";
      } else {
        // Si ya tiene números (50.1), dejamos que el formateador intente hacerlo o usamos el string
        displayValue = amountString.replaceAll('.', ',');
      }
    } else {
      displayValue = AppFormatters.getFormatedNumber(amountString, amount);
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        overflow: TextOverflow.ellipsis,
        displayValue,
        style: textTheme.titleLarge!.copyWith(
          fontSize: 70,
          fontWeight: FontWeight.w600,
          letterSpacing: -1,
        ),
      ),
    );
  }

  Widget _buildBottomButton(ColorScheme colorScheme, TextTheme textTheme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 30),
        child: StandarButton(
          radius: 200,
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              transactionModel = transactionModel.copyWith(
                amount: amount,
                currency: currency,
              );

              debugPrint(transactionModel.currency);

              await showCupertinoModalPopup<void>(
                context: context,
                builder: (context) {
                  return CupertinoPageScaffold(
                    backgroundColor: colorScheme.surface,
                    navigationBar: CupertinoNavigationBar(
                      backgroundColor: colorScheme.surface,
                      leading: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Atrás",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    child: TransactionDetailsCreatePage(
                      isEditable: widget.isEditable,
                      isForReport: widget.isForReport,
                      reportModel: widget.reportModel,
                      transactionModel: transactionModel,
                    ),
                  );
                },
              );
            }
          },
          text: "Siguiente",
        ),
      ),
    );
  }
}
