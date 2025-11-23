import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/view/transactions/read/transaction_read_page.dart';
import 'package:neto_app/widgets/widgets.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/l10n/app_localizations.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  //#####################################################################################
  //VARIABLES
  //#####################################################################################
  String transactionType = TransactionType.expense.id;
  List<TransactionModel> transactions=[
    //🏠 Gasto de Alquiler (Recurrente/Mensual)
    TransactionModel.empty(
      userId: "currentUserId",
      type: 'EXPENSE',
      currency: "USD",
      amount: 850.00,
      category: Expenses.getCategoryById('VIVIENDA')?.nombre ?? 'VIVIENDA',
      categoryid: 'VIVIENDA',
      subcategory: 'Alquiler',
      date: DateTime(2025, 11, 1),
      year: 2025,
      month: 11,
      frequency: 'monthly',
      description: 'Pago de alquiler Noviembre 2025',
    ),


    //💼 Ingreso Salario (Frecuencia mensual)
    TransactionModel.empty(
      userId: "currentUserId",
      type: 'INCOME',
      currency: "USD",
      amount: 2500.00,
      categoryid: 'SALARIO',
      category: Incomes.getCategoryById('SALARIO')?.nombre ?? 'SALARIO',
      subcategory: 'Nómina Principal',
      date: DateTime(2025, 11, 30),
      year: 2025,
      month: 11,
      frequency: 'monthly',
      description: 'Transferencia nómina (Empresa XYZ)',
    ),
  ];

  //#####################################################################################
  //FUNCIONES
  //#####################################################################################

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Map<String, Widget> myTabs = <String, Widget>{
      TransactionType.expense.id: Text(appLocalizations.typeExpense),
      TransactionType.income.id: Text(appLocalizations.typeIncome),
    };

    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          title: Text("dsdds", style: textTheme.titleMedium),
          centerTitle: true,

          leading: Container(
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(left: 24.0),
            child: ClipRRect(
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(CupertinoIcons.chevron_back, size: 20),
                ),
              ),
            )
          ),
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 50),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: "Gastos"),
                Tab(text: "Ingresos"),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: TabBarView(children: [Gasto(transactionModel: transactions[0]), Ingreso(transactionModel:transactions[1])]),
        ),

        floatingActionButton: FloatingActionButton(onPressed:(){
          // Acción al presionar el botón
          debugPrint('Botón de agregar movimiento presionado');

        },child: Icon(Icons.add),),
        
      ),
    );
  }
}

class Gasto extends StatelessWidget {
  final TransactionModel transactionModel;
  const Gasto({super.key, required this.transactionModel});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return TransactionReadPage(transactionModel: transactionModel);
              },
            );
          },
          child: TransactionCard(
            id: transactionModel.categoryid,
            type: "EXPENSE",
            title: transactionModel.category,
            subtitle: "1 Nov. 2025",
          ),
        ),
        
      ],
    );
  }
}

class Ingreso extends StatelessWidget {
  final TransactionModel transactionModel;
  const Ingreso({super.key, required this.transactionModel});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        GestureDetector(
          onTap: () {
            showModalBottomSheet(context: context, builder:(context) {
              return TransactionReadPage(transactionModel: transactionModel);
            },);
          },
          child: TransactionCard(id: transactionModel.categoryid, type: "INCOME", title: transactionModel.category, subtitle: "16 Oct. 2025",),),
       
      ],
    );
  }
}
