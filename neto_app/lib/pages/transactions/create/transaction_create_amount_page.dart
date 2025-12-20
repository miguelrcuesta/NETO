import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/models/reports_model.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/pages/transactions/create/transaction_create_details_page.dart';
import 'package:neto_app/provider/transaction_provider.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

// Si no tienes estos métodos, DEBES implementarlos o el código fallará.

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
  //#####################################################################################
  //CONTROLLERS
  //#####################################################################################
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _amountFocusNode = FocusNode();

  //#####################################################################################
  //VARIABLES
  //#####################################################################################
  DateTime selectedDate = DateTime.now();

  //GEMINI
  Map<String, String>? sugerenciaGemini;

  bool isLoading = false;
  bool hasError = false;
  bool hasSuccess = false;
  final Locale currentLocale = AppFormatters.getPlatformLocale();

  //BBDD
  String amountString = '';

  double amount = 0.0;
  String? descripcion;

  String? selectedCategoryChoice;
  String? selectedSubcategoryChoice;
  TransactionType? transactionType = TransactionType.expense;
  late TransactionModel transactionModel;

  //#####################################################################################
  //FUNCIONES
  //#####################################################################################

  void _updateAmount(AmountUpdate update) {
    final String newAmountString = update.newAmount;
    final UpdateDirection direction = update.direction;

    // Define el límite máximo de caracteres para el monto.
    const int maxLength = 10;

    // 1. Manejo de la acción de BORRADO (DELETE)
    // Siempre se permite la actualización si se borra un dígito.
    if (direction == UpdateDirection.delete) {
      setState(() {
        amountString = newAmountString;
        amount = double.tryParse(amountString) ?? 0.0;
      });
      return;
    }

    // 2. Manejo de la acción de AÑADIR (ADD)
    // Se aplica la restricción de longitud.
    if (direction == UpdateDirection.add) {
      // 🔑 Solo actualizamos si la nueva cadena NO excede el límite.
      if (newAmountString.length <= maxLength) {
        setState(() {
          amountString = newAmountString;
          amount = double.tryParse(amountString) ?? 0.0;
        });
      }
      // Si la longitud es > 10, simplemente se ignora la pulsación (no se llama a setState).
    }
  }

  @override
  void initState() {
    transactionModel = widget.transactionModel ?? TransactionModel.empty();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Usamos el FocusScope del contexto actual para solicitar el foco
      FocusScope.of(context).requestFocus(_amountFocusNode);
    });

    //SI ES EDITABLE, ES DECIR YA TIENE DATOS LOS RE
    if (widget.transactionModel != null && widget.isEditable) {
      final model = widget.transactionModel!;
      // amount
      amount = model.amount;
      amountString = model.amount.toStringAsFixed(2);
      // _updateAmount(amountString);
      amountController.text = amountString;
      // description
      descriptionController.text = model.description ?? '';
      descripcion = model.description;
      //category / subcategory

      selectedCategoryChoice = model.category;
      selectedSubcategoryChoice = model.subcategory;
      // tipo
      transactionType = TransactionType.getById(model.type);

      //Fecha
      selectedDate = widget.transactionModel!.date!;
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TransactionsProvider provider = context.read<TransactionsProvider>();

    ColorScheme colorScheme = Theme.of(context).colorScheme;
    //TextTheme textTheme = Theme.of(context).textTheme;
    //AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      //appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppDimensions.spacingLarge),

                  _widgetAmount(),

                  TransactionKeyBoardWidget(
                    initialAmount: amountString,
                    onAmountChange: _updateAmount,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            15.0,
            0.0,
            15.0,
            MediaQuery.of(context).viewInsets.bottom + 30.0,
          ),
          child: StandarButton(
            radius: 200,
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                debugPrint(
                  'StandarButton pressed on TransactionAmountCreatePage',
                );

                transactionModel = transactionModel.copyWith(amount: amount);

                //Editar
                await showCupertinoModalPopup<void>(
                  context: context,
                  builder: (context) {
                    TextTheme textTheme = Theme.of(context).textTheme;
                    return CupertinoPageScaffold(
                      backgroundColor: colorScheme.surface,
                      navigationBar: CupertinoNavigationBar(
                        backgroundColor: colorScheme.surface,
                        leading: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Atrás",
                            style: textTheme.bodySmall!.copyWith(
                              color: Colors.blue,
                            ),
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

                // if (!context.mounted) return;
                // // Cerramos todos los modales y volvemos a la primera ruta (TransactionsReadPage)
                // Navigator.of(
                //   context,
                //   rootNavigator: true,
                // ).popUntil((route) => route.isFirst);
              }
            },
            text: "Siguiente",
          ),
        ),
      ),
    );
  }

  //#####################################################################################
  // WIDGETS
  //#####################################################################################

  //=========================================================================
  //AMOUNT
  //=========================================================================
  Widget _widgetAmount() {
    return AmountDisplayWidget(fullAmount: amountString, phantomDecimal: '');
  }
}
