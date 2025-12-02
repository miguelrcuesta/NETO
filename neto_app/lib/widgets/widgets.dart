//##########################################################################
//PIN CODE
//##########################################################################
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/widgets/app_fields.dart';

//======================================================================
//======================================================================
//CUSTOM KEYBOARDS
//======================================================================
//======================================================================
class PinCodeWidget extends StatefulWidget {
  const PinCodeWidget({super.key});

  @override
  State<PinCodeWidget> createState() => _PinCodeWidgetState();
}

class _PinCodeWidgetState extends State<PinCodeWidget> {
  String enteredPin = '';
  bool isPinVisible = false;

  /// this widget will be use for each digit
  Widget numButton(int number) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextButton(
        onPressed: () {
          setState(() {
            if (enteredPin.length < 4) {
              enteredPin += number.toString();
            }
          });
        },
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget comaButton(String coma) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextButton(
        onPressed: () {
          setState(() {
            if (enteredPin.length < 4) {
              enteredPin += coma.toString();
            }
          });
        },
        child: Text(
          coma.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const BouncingScrollPhysics(),
          children: [
            /// pin code area
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.all(6.0),
                  width: isPinVisible ? 50 : 16,
                  height: isPinVisible ? 50 : 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: index < enteredPin.length
                        ? isPinVisible
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant
                        : colorScheme.onSurfaceVariant,
                  ),
                  child: isPinVisible && index < enteredPin.length
                      ? Center(
                          child: Text(
                            enteredPin[index],
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : null,
                );
              }),
            ),

            /// visiblity toggle button
            IconButton(
              onPressed: () {
                setState(() {
                  isPinVisible = !isPinVisible;
                });
              },
              icon: Icon(
                isPinVisible ? Icons.visibility_off : Icons.visibility,
              ),
            ),

            SizedBox(height: isPinVisible ? 50.0 : 8.0),

            /// digits
            for (var i = 0; i < 3; i++)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    3,
                    (index) => numButton(1 + 3 * i + index),
                  ).toList(),
                ),
              ),

            /// 0 digit with back remove
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TextButton(onPressed: null, child: SizedBox()),
                  //comaButton(","),
                  numButton(0),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (enteredPin.isNotEmpty) {
                          enteredPin = enteredPin.substring(
                            0,
                            enteredPin.length - 1,
                          );
                        }
                      });
                    },
                    child: Icon(
                      Icons.backspace,
                      color: colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            /// reset button
            TextButton(
              onPressed: () {
                setState(() {
                  enteredPin = '';
                });
              },
              child: Text(
                'Reset',
                style: TextStyle(fontSize: 20, color: colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionKeyBoardWidget extends StatefulWidget {
  final String initialAmount;
  final ValueChanged<String> onAmountChange; // Callback para notificar al padre

  const TransactionKeyBoardWidget({
    super.key,
    required this.initialAmount,
    required this.onAmountChange,
  });

  @override
  State<TransactionKeyBoardWidget> createState() =>
      _TransactionKeyBoardWidgetState();
}

class _TransactionKeyBoardWidgetState extends State<TransactionKeyBoardWidget> {
  late String amount; // Estado local, siempre como String.

  @override
  void initState() {
    super.initState();
    amount = widget.initialAmount;
  }

  @override
  void didUpdateWidget(covariant TransactionKeyBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAmount != oldWidget.initialAmount) {
      amount = widget.initialAmount;
    }
  }

  /// Actualiza el estado local y notifica al widget padre.
  void _updateAndNotify(String newAmount) {
    setState(() {
      amount = newAmount;
    });
    widget.onAmountChange(newAmount);
  }

  /// Constructor de la tecla numérica o de acción
  Widget _buildKey({required Widget child, required VoidCallback onPressed}) {
    // Usamos GestureDetector para una respuesta táctil inmediata (sin el retraso del 'ripple effect')
    return GestureDetector(
      onTap: onPressed,
      // Usamos un container de tamaño fijo para asegurar el área de toque
      child: Container(
        width: 60, // Ancho suficiente para toque
        height: 60, // Alto suficiente para toque
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.transparent, // Fondo transparente
          borderRadius: BorderRadius.circular(30),
        ),
        child: child,
      ),
    );
  }

  /// Widget para cada dígito
  Widget _buildNumberKey(int number) {
    return _buildKey(
      onPressed: () {
        // Lógica: Simplemente añade el número a la cadena.
        _updateAndNotify(amount + number.toString());
      },
      child: Text(
        number.toString(),
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
    );
  }

  /// Widget para la coma (separador decimal)
  Widget _buildCommaKey(String coma) {
    coma = ".";
    return _buildKey(
      onPressed: () {
        // Lógica: Solo permitir una coma.
        if (!amount.contains('.')) {
          if (amount.isEmpty) {
            // Si la cadena está vacía, añade "0,"
            _updateAndNotify('0$coma');
          } else {
            // Si hay números, añade la coma.
            _updateAndNotify(amount + coma);
          }
        }
      },
      child: Text(
        coma,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ocupar solo el espacio necesario
        children: [
          /// Digits (1 a 9)
          for (var i = 0; i < 3; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  3,
                  (index) => _buildNumberKey(1 + 3 * i + index),
                ).toList(),
              ),
            ),

          /// Fila: Coma, 0, Borrar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón de Coma
                _buildCommaKey('.,'),

                // Botón de 0
                _buildNumberKey(0),

                // Botón de Borrar (Backspace)
                _buildKey(
                  onPressed: () {
                    if (amount.isNotEmpty) {
                      _updateAndNotify(amount.substring(0, amount.length - 1));
                    } else {
                      _updateAndNotify('');
                    }
                  },
                  child: Icon(
                    Icons.backspace,
                    color: colorScheme.onSurface,
                    size: 24,
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

//======================================================================
//======================================================================
//CARDS
//======================================================================
//======================================================================
class TransactionCard extends StatefulWidget {
  const TransactionCard({
    super.key,
    required this.isSelected,
    required this.idCategory,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final bool isSelected;
  final String idCategory;
  final String type;
  final String title;
  final String subtitle;
  final String amount;

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  dynamic getCategory(String id) {
    if (widget.type == TransactionType.expense.id) {
      return Expenses.getCategoryById(id);
    } else {
      return Incomes.getCategoryById(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    dynamic category = getCategory(widget.idCategory);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Cambiamos a start
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Icono (Se mantiene igual)
          widget.isSelected == false
              ? ClipRRect(
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: decorationContainer(
                      context: context,
                      colorFilled:
                          category.color.withAlpha(30) ??
                          colorScheme.primary.withAlpha(30),
                      radius: 100,
                    ),
                    child: Icon(
                      category.iconData,
                      size: 25,
                      color: category.color ?? colorScheme.primary,
                    ),
                  ),
                )
              : ClipRRect(
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: decorationContainer(
                      context: context,
                      colorFilled: colorScheme.primary.withAlpha(30),
                      radius: 100,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 25,
                      color: colorScheme.primary,
                    ),
                  ),
                ),

          const SizedBox(width: AppDimensions.spacingMedium),

          // 2. Título y subtítulo (Usamos Expanded para ocupar el espacio restante)
          Expanded(
            child: ListTile(
              // Eliminamos el padding que ListTile aplica por defecto
              visualDensity: VisualDensity.compact,
              titleAlignment: ListTileTitleAlignment.top,
              contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
              minVerticalPadding: 15.0,
              title: Text(
                widget.title,
                style: textTheme.bodyMedium,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                widget.subtitle,
                style: textTheme.bodySmall!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),

              // 3. Monto (Alineación derecha gestionada por ListTile/Expanded)
              trailing: Text(widget.amount, style: textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionCardSmall extends StatefulWidget {
  const TransactionCardSmall({
    super.key,
    required this.isSelected,
    required this.idCategory,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final bool isSelected;
  final String idCategory;
  final String type;
  final String? title;
  final String? subtitle;
  final String amount;

  @override
  State<TransactionCardSmall> createState() => _TransactionCardSmallState();
}

class _TransactionCardSmallState extends State<TransactionCardSmall> {
  dynamic getCategory(String id) {
    if (widget.type == TransactionType.expense.id) {
      return Expenses.getCategoryById(id);
    } else {
      return Incomes.getCategoryById(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    dynamic category = getCategory(widget.idCategory);
    String? subtitle =
        widget.subtitle ?? category.getCategoryById(widget.idCategory)?.nombre;

    return Container(
      decoration: decorationContainer(
        context: context,
        radius: 10,
        colorBorder: widget.isSelected
            ? colorScheme.primary
            : Colors.transparent,
        colorFilled: widget.isSelected
            ? colorScheme.primary.withAlpha(10)
            : Colors.transparent,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: CupertinoListTile(
        padding: EdgeInsets.only(left: 10, right: 15),
        leading: widget.isSelected == false
            ? ClipRRect(
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: decorationContainer(
                    context: context,
                    colorFilled:
                        category.color.withAlpha(30) ??
                        colorScheme.primary.withAlpha(30),
                    radius: 100,
                  ),
                  child: Icon(
                    category.iconData,
                    size: 15,
                    color: category.color ?? colorScheme.primary,
                  ),
                ),
              )
            : ClipRRect(
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: decorationContainer(
                    context: context,
                    colorFilled: colorScheme.primary.withAlpha(90),
                    radius: 100,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 25,
                    color: colorScheme.primary,
                  ),
                ),
              ),

        title: Text(
          widget.title ?? category.name,
          style: textTheme.bodySmall!.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          subtitle ?? "Sin descripción",
          style: textTheme.bodySmall!.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(widget.amount, style: textTheme.bodyMedium),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.upText,
    required this.dateText,
    this.isSelected = false,
  });

  final String upText;
  final String dateText;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    // List<BoxShadow> softGrayShadows = [
    //   BoxShadow(
    //     color: Colors.grey.withOpacity(0.2),
    //     blurRadius: 10.0,
    //     offset: const Offset(0, 4),
    //     spreadRadius: 1.0,
    //   ),
    // ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 80,
      width: double.infinity,
      decoration: decorationContainer(
        context: context,
        colorFilled: colorScheme.primaryContainer,
        // colorBorder: colorScheme.outlineVariant,
        //boxShadow: softGrayShadows,
        radius: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.folder, size: 35, color: Colors.amberAccent),
              const SizedBox(width: AppDimensions.spacingMedium),
              SizedBox(
                width: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upText,
                      style: textTheme.titleSmall,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      dateText,
                      style: textTheme.bodySmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
