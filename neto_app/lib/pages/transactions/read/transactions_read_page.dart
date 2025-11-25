// Archivo: pages/transactions/transactions_page.dart

import 'package:flutter/material.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/controllers/transaction_controller.dart'; 

import 'package:neto_app/pages/transactions/create/transaction_create_amount_page.dart';
import 'package:neto_app/pages/transactions/read/transaction_read_page.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/services/transactions_services.dart';
import 'package:neto_app/widgets/app_fields.dart'; 

// Dependencias de UI (Asegúrate de que existan en tu proyecto)
import 'package:neto_app/widgets/widgets.dart'; 
import 'package:neto_app/l10n/app_localizations.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> with TickerProviderStateMixin {
  
  // ⭐️ CONTROLADORES DE ESTADO Y DATOS ⭐️
  late final TransactionController _transactionController;
  late final TabController _tabController;
  
  // Estado para saber qué datos cargar y para forzar la reconstrucción
  String _currentTransactionType = TransactionType.expense.id.toUpperCase();
  late Future<List<TransactionModel>> _transactionsFuture;

  //#####################################################################################
  // INICIALIZACIÓN
  //#####################################################################################

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange); // Escuchar cambios de pestaña

    _transactionController = TransactionController(service: TransactionService());
    
    // ⭐️ Carga Inicial: Llama al nuevo Future para EXPENSE ⭐️
    _transactionsFuture = _transactionController.getTransactions(type: _currentTransactionType);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  //#####################################################################################
  // FUNCIONES DE CONTROL
  //#####################################################################################

  /// Maneja el cambio de pestaña y fuerza la recarga del Future (base de datos)
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final newType = _tabController.index == 0 
          ? TransactionType.expense.id.toUpperCase() 
          : TransactionType.income.id.toUpperCase();
      
      // Actualiza el estado y el Future, forzando al FutureBuilder a recargar
      if (_currentTransactionType != newType) {
        setState(() {
          _currentTransactionType = newType;
          // Asigna un nuevo Future, que es lo que desencadena la nueva llamada a la DB
          _transactionsFuture = _transactionController.getTransactions(type: _currentTransactionType);
        });
      }
    }
  }

  //#####################################################################################
  // BUILD
  //#####################################################################################

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text("Movimientos", style: textTheme.titleMedium),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 50),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: appLocalizations.typeExpense),
              Tab(text: appLocalizations.typeIncome),
            ],
          ),
        ),
      ),
      
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: decorationContainer(
              context: context,
              colorFilled: colorScheme.primaryContainer,
              radius: 10,
            ),
            
            // ⭐️ FutureBuilder: Maneja los 3 estados (Cargando, Error, Datos) ⭐️
            child: FutureBuilder<List<TransactionModel>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                
                // 1. Estado de Carga
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(),
                    ));
                }

                // 2. Estado de Error
                if (snapshot.hasError) {
                  return Center(child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Error al cargar: ${snapshot.error}'),
                    ));
                }

                final transactions = snapshot.data ?? [];

                // 3. Estado Vacío (La lista completa de la pestaña está vacía)
                if (transactions.isEmpty) {
                  return Center(child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      // Puedes usar una lógica más inteligente si tienes acceso a los nombres
                      child: Text('No hay movimientos de ${_currentTransactionType.toLowerCase()}'), 
                    ));
                }

                // 4. Mostrar la Lista
                return _buildTransactionList(transactions);
              },
            ),
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const TransactionAmountCreatePage(),
            ),
          );
        },
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }

  //#####################################################################################
  // WIDGETS DE LISTA
  //#####################################################################################

  /// Construye la lista de transacciones.
  Widget _buildTransactionList(List<TransactionModel> transactions) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Scroll lo maneja SingleChildScrollView
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.transparent),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return TransactionReadPage(transactionModel: transaction);
              },
            );
          },
          child: TransactionCard(
            id: transaction.categoryid,
            type: transaction.type,
            title: transaction.category,
            subtitle: transaction.date != null 
                      ? "${transaction.date!.day}/${transaction.date!.month}/${transaction.date!.year}" // Formato mejorado
                      : "Fecha desconocida",
            amount: transaction.amount.toStringAsFixed(2),
          ),
        );
      },
    );
  }
}