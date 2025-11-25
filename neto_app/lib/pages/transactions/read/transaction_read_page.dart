import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/models/transaction_model.dart';
import 'package:neto_app/widgets/app_fields.dart';

class TransactionReadPage extends StatefulWidget {
  final TransactionModel transactionModel;
  const TransactionReadPage({super.key, required this.transactionModel});

  @override
  State<TransactionReadPage> createState() => _TransactionReadPageState();
}

class _TransactionReadPageState extends State<TransactionReadPage> {
  dynamic category;

  dynamic getCategory(String id) {
    if (widget.transactionModel.type == TransactionType.expense.id) {
      return Expenses.getCategoryById(id);
    } else {
      return Incomes.getCategoryById(id);
    }
  }

  @override
  void initState() {
    category = getCategory(widget.transactionModel.categoryid);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
     

     ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return  SizedBox(
      child: Column(
        children: [
          
          Container(
                padding: AppDimensions.paddingHorizontalMedium,
                decoration: decorationContainer(
                  context: context,
                  colorFilled: colorScheme.primaryContainer,
                  radius: 10,
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                      minVerticalPadding: 0.0,
                      visualDensity: VisualDensity.comfortable,
                      //title: Text("Categoría", style: textTheme.titleSmall),
                      title: Text(
                        "Importe",
                        style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        widget.transactionModel.amount.toStringAsFixed(2),
                        style: textTheme.titleMedium!.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    Divider(height: 1, color: colorScheme.outline),
                    
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                      minVerticalPadding: 0.0,
                      visualDensity: VisualDensity.comfortable,
                      //title: Text("Categoría", style: textTheme.titleSmall),
                      title: Text(
                        "Descripción",
                        style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        "Esta es la descripción",
                        style: textTheme.titleSmall!.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    Divider(height: 1, color: colorScheme.outline),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                      minVerticalPadding: 0.0,
                      visualDensity: VisualDensity.comfortable,
                      //title: Text("Categoría", style: textTheme.titleSmall),
                      leading: ClipRRect(
                        child: Container(
                          decoration: decorationContainer(
                            context: context,
                            colorFilled:
                                category.color.withAlpha(30) ??
                                colorScheme.primary.withAlpha(30),
                            radius: 8,
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              category.iconData,
                              size: 20,
                              color: category.color ?? colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        "Categoría",
                        style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        widget.transactionModel.category.isEmpty
                            ? "-"
                            : '${widget.transactionModel.category} | ${widget.transactionModel.subcategory}',
                        style: textTheme.titleSmall!.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    
                  ],
                ),
              ),
        ],
      ),
    );
  }
}