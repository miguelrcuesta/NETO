import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/widgets/widgets.dart';
import 'package:neto_app/widgets/app_bars.dart';
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
          title: Text("Movimientos", style: textTheme.titleMedium),
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
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 50),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,

              tabs: [
                Tab(text: "Gasto"),
                Tab(text: "Ingresos"),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: TabBarView(children: [B(), A()]),
        ),

        // appBar: TitleAppbarBack(
        //   title: "Movimientos",
        //   bottom: PreferredSize(
        //     preferredSize: Size(double.infinity, 120),
        //     child: DefaultTabController(
        //       length: myTabs.length,
        //       child: TabBar(
        //         tabs: [
        //           // SizedBox(
        //           //   width: double.infinity,
        //           //   child: CupertinoSlidingSegmentedControl<String>(
        //           //     proportionalWidth: true,
        //           //     groupValue: transactionType,
        //           //     thumbColor: colorScheme.primaryContainer,
        //           //     backgroundColor: Colors.grey.shade200,
        //           //     children: myTabs,
        //           //     onValueChanged: (String? newValue) {
        //           //       if (newValue != null) {
        //           //         setState(() {
        //           //           transactionType = newValue;
        //           //         });

        //           //         if (transactionType == TransactionType.expense.id) {}
        //           //       }
        //           //     },
        //           //   ),
        //           // ),
        //           Tab(text: "Gasto"),
        //           Tab(text: "Ingresos"),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        // body: Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
        //   child: Center(
        //     child: Column(
        //       children: [

        //         const SizedBox(height: 20),
        //         A(),
        //         B(),
        //         // Expanded(
        //         //   child: ListView(
        //         //     children: [
        //         //       TransactionCard(id: "TRANSPORTE", subtitle: "Alquiler piso"),
        //         //       const SizedBox(height: 10),
        //         //       TransactionCard(id: "OCIO", subtitle: "Netflix agosto"),
        //         //       const SizedBox(height: 10),
        //         //       ReportCard(
        //         //         upText: "Evolución cuenta ahorros",
        //         //         dateText: "Creado el 16 de may. 1996",
        //         //       ),
        //         //     ],
        //         //   ),
        //         // ),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }
}

class B extends StatelessWidget {
  const B({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TransactionCard(
          id: "VIVIENDA",
          type: "EXPENSE",
          title: "Nómina agosto",
          subtitle: "16 Oct. 2025",
        ),
        const SizedBox(height: 10),
        TransactionCard(
          id: "SUSCRIPCIONES",
          type: "EXPENSE",
          title: "Netflix",
          subtitle: "23 Oct. 2025",
        ),
      ],
    );
  }
}

class A extends StatelessWidget {
  const A({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TransactionCard(id: "SALARIO", type: "INCOME", title: "Nómina", subtitle: "16 Oct. 2025"),
        const SizedBox(height: 10),
        TransactionCard(
          id: "INVERSIONES",
          type: "INCOME",
          title: "Inversiones",
          subtitle: "23 Oct. 2025",
        ),
      ],
    );
  }
}
