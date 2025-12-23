import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/models/networth_model.dart';
import 'package:neto_app/services/shared_preferences_services.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';

//======================================================================
//FAV CATEGORIES
//======================================================================
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neto_app/constants/app_enums.dart';
import 'package:neto_app/services/shared_preferences_services.dart';

class FavoriteCategoriesModal extends StatefulWidget {
  const FavoriteCategoriesModal({super.key});

  @override
  State<FavoriteCategoriesModal> createState() =>
      _FavoriteCategoriesModalState();
}

class _FavoriteCategoriesModalState extends State<FavoriteCategoriesModal> {
  int _selectedSegment = 0;
  final PreferencesManager _prefs = PreferencesManager();

  // Función para mostrar alerta de confirmación
  void _showClearAllDialog(BuildContext context, bool isExpense) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Eliminar favoritos"),
        content: Text(
          "¿Estás seguro de que quieres eliminar todos tus favoritos de ${isExpense ? 'gastos' : 'ingresos'}?",
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              await _prefs.clearAllFavorites(isExpense);
              setState(() {}); // Refrescar UI
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Eliminar todo"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isExpense = _selectedSegment == 0;
    final List categories = isExpense ? Expenses.values : Incomes.values;

    return Material(
      child: CupertinoPageScaffold(
        backgroundColor: colorScheme.surface,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: colorScheme.surface,
          middle: const Text("Configurar Favoritos"),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text("Cerrar"),
            onPressed: () => Navigator.pop(context),
          ),
          // BOTÓN CLEAR ALL AÑADIDO AQUÍ
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showClearAllDialog(context, isExpense),
            child: const Text("Limpiar"),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedSegment,
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Gastos'),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Ingresos'),
                  ),
                },
                onValueChanged: (v) => setState(() => _selectedSegment = v!),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            color: colorScheme.primaryContainer.withOpacity(
                              0.1,
                            ),
                            child: Text(
                              "${category.emoji} ${category.nombre}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...category.subcategorias.map<Widget>((subName) {
                            final bool isFav = _prefs.isSubFavorite(
                              category.id,
                              subName,
                              isExpense,
                            );
                            return ListTile(
                              title: Text(
                                subName,
                                style: textTheme.bodyMedium!.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              trailing: Icon(
                                isFav ? Icons.star : Icons.star_border,
                                color: isFav
                                    ? Colors.amber
                                    : colorScheme.onSurfaceVariant,
                              ),
                              onTap: () async {
                                await _prefs.toggleFavoriteSubcategory(
                                  catId: category.id,
                                  catName: category.nombre,
                                  subName: subName,
                                  isExpense: isExpense,
                                );
                                setState(() {});
                              },
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//======================================================================
//CUSTOM KEYBOARDS
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
    ColorScheme colorScheme = Theme.of(context).colorScheme;
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget comaButton(String coma) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
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

  final ValueChanged<AmountUpdate> onAmountChange;

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
  String phantomDecimal = ''; // Estado para los '00' o '0' fantasma

  @override
  void initState() {
    super.initState();
    amount = widget.initialAmount;
    _checkPhantomState(amount); // Llamada inicial
  }

  @override
  void didUpdateWidget(covariant TransactionKeyBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAmount != oldWidget.initialAmount) {
      amount = widget.initialAmount;
      _checkPhantomState(amount);
    }
  }

  //FUNCIÓN FALTANTE: Lógica para el estado del decimal "fantasma"
  void _checkPhantomState(String currentAmount) {
    if (!currentAmount.contains('.')) {
      phantomDecimal = '';
      return;
    }
    final decimalPart = currentAmount.split('.').last;

    if (decimalPart.isEmpty) {
      phantomDecimal = '00';
    } else if (decimalPart.length == 1) {
      phantomDecimal = '0';
    } else {
      phantomDecimal = '';
    }
  }

  ///CORRECCIÓN: ÚNICA FUNCIÓN para actualizar el estado y notificar al padre
  void _updateAndNotify(String newAmount, UpdateDirection direction) {
    setState(() {
      amount = newAmount;
      _checkPhantomState(newAmount);
    });

    //Notificar al padre usando el objeto AmountUpdate
    widget.onAmountChange(AmountUpdate(newAmount, direction));
  }

  /// Constructor de la tecla numérica o de acción
  Widget _buildKey({required Widget child, required VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: child,
      ),
    );
  }

  /// Widget para cada dígito
  Widget _buildNumberKey(int number) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String numberString = number.toString();
    const int maxAmountLength = 10;

    return _buildKey(
      onPressed: () {
        String newAmount = amount;

        // 1. Lógica para evitar el cero a la izquierda (Si es "0", reemplazamos por el número)
        if (amount == '0') {
          newAmount = numberString;
          _updateAndNotify(newAmount, UpdateDirection.add);
          return;
        }

        // 2. Lógica de restricción de decimales
        final realDecimalPart = amount.contains('.')
            ? amount.split('.').last
            : '';

        // Si ya tiene 2 decimales y NO hay espacio fantasma para escribir, bloqueamos
        if (amount.contains('.') &&
            realDecimalPart.length >= 2 &&
            phantomDecimal.isEmpty) {
          return;
        }

        // 3. Generar la nueva cadena (newAmount)
        if (amount.contains('.') && phantomDecimal.isNotEmpty) {
          // Lógica Fantasma: Reemplazamos los "0" o "00" por el número pulsado
          final parts = amount.split('.');
          final realDecimal = parts.length > 1 ? parts[1] : '';

          if (phantomDecimal == '00') {
            // Si era "50." -> pasa a "50.X" (el primer cero desaparece)
            newAmount = '${parts[0]}.$numberString';
          } else if (phantomDecimal == '0') {
            // Si era "50.1" -> pasa a "50.1X"
            newAmount = '${parts[0]}.$realDecimal$numberString';
          }
        } else {
          // Lógica Normal: Añadir el dígito al final
          newAmount = amount + numberString;
        }

        // 4. Validaciones de seguridad de longitud
        if (newAmount.length > maxAmountLength && !newAmount.contains('.')) {
          return;
        }

        // 5. Notificar si hubo cambio
        if (newAmount != amount) {
          _updateAndNotify(newAmount, UpdateDirection.add);
        }
      },
      child: Text(
        numberString,
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  /// Widget para la coma (separador decimal)
  Widget _buildCommaKey(String coma) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    coma = ".";
    final bool hasDot = amount.contains('.');

    return _buildKey(
      onPressed: hasDot
          ? null
          : () {
              String newAmount;
              if (amount.isEmpty) {
                newAmount = '0$coma';
              } else {
                newAmount = amount + coma;
              }
              //Notificación de AÑADIR
              _updateAndNotify(newAmount, UpdateDirection.add);
            },
      child: Text(
        coma,
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.normal,
          color: hasDot ? Colors.grey.shade400 : colorScheme.onSurface,
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
        mainAxisSize: MainAxisSize.min,
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
                _buildCommaKey('.,'),
                _buildNumberKey(0),

                // Botón de Borrar (Backspace)
                _buildKey(
                  onPressed: () {
                    String newAmount = '';
                    UpdateDirection direction = UpdateDirection.none;

                    if (amount.isNotEmpty) {
                      newAmount = amount.substring(0, amount.length - 1);
                      direction =
                          UpdateDirection.delete; //Notificación de BORRADO
                    }

                    _updateAndNotify(newAmount, direction);
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
//TEXT NUMBER AMOUNT (UI)
//======================================================================
class AmountDisplayWidget extends StatelessWidget {
  final String fullAmount;
  final String phantomDecimal;

  const AmountDisplayWidget({
    super.key,
    required this.fullAmount,
    required this.phantomDecimal,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    // TextTheme textTheme = Theme.of(context).textTheme;
    // --- 1. Separación de la cadena ---
    final List<String> parts = fullAmount.split('.');
    final String integerPart = parts[0];
    final String decimalPart = parts.length > 1 ? parts[1] : '';
    final double fontSizeCustom = 65;

    // Obtenemos el texto real sin fantasmas
    final String realDisplayAmount =
        integerPart + (fullAmount.contains('.') ? '.' : '') + decimalPart;

    // Si la cadena está vacía, mostramos "0" o el valor inicial
    if (realDisplayAmount.isEmpty) {
      return Text(
        '0.00',
        style: TextStyle(
          fontSize: fontSizeCustom,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // Aísla el último dígito
    final String lastDigit = realDisplayAmount.substring(
      realDisplayAmount.length - 1,
    );
    final String staticAmount = realDisplayAmount.substring(
      0,
      realDisplayAmount.length - 1,
    );

    //const Duration quickDuration = Duration(milliseconds: 150);

    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Parte Estática (El resto de los números)
          Text(
            staticAmount,
            style: TextStyle(
              fontSize: fontSizeCustom,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),

          // 2. Último Dígito (¡Animado!)
          Text(
            lastDigit,
            style: TextStyle(
              fontSize: fontSizeCustom,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          // .animate(
          //   //DISPARADOR DE LA ANIMACIÓN:
          //   // Usamos la longitud de la cadena para que se dispare solo cuando se añade un dígito.
          //   key: ValueKey(realDisplayAmount.length),
          // )
          // .slide(
          //   begin: const Offset(1.0, 0.0), //
          //   end: const Offset(0.0, 0.0),
          //   duration: quickDuration,
          // )
          // .scale(
          //   alignment: Alignment.center,
          //   begin: const Offset(
          //     1.2,
          //     1.2,
          //   ), // Inicia más grande para enfocar el dígito
          //   end: const Offset(1.0, 1.0),
          //   duration: quickDuration,
          // )
          // .effect(duration: quickDuration),

          // 3. Decimal Fantasma (Si está activo)
          //if (phantomDecimal.isNotEmpty)
          Text(
            phantomDecimal,
            style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold),
          ),
          // .animate(key: ValueKey('phantom_$phantomDecimal'))
          // .fadeIn(duration: 800.ms),
        ],
      ),
    );
  }
}

//======================================================================
//TRANSACTION CARDS
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
        borderWidth: 1,
        colorBorder: widget.isSelected
            ? colorScheme.primary
            : Colors.transparent,
        colorFilled: widget.isSelected
            ? colorScheme.primary.withAlpha(20)
            : Colors.transparent,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ListTile(
        minVerticalPadding: 0,
        contentPadding: EdgeInsets.zero,
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
                    size: 20,
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
          widget.title != null
              ? widget.title!.toUpperCase()
              : category.name.toUpperCase(),
          style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurface),
        ),
        subtitle: Text(
          subtitle ?? "Sin descripción",
          style: textTheme.bodySmall!.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(widget.amount, style: textTheme.titleSmall),
      ),
    );
  }
}

class CategoryCard extends StatefulWidget {
  const CategoryCard({
    super.key,
    required this.idCategory,
    required this.type,
    required this.title,
    required this.amount,
  });

  final String idCategory;
  final String type;
  final String? title;

  final String amount;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
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

    return Container(
      decoration: decorationContainer(
        context: context,
        radius: 10,
        borderWidth: 1,
        colorFilled: colorScheme.primaryContainer,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ListTile(
        minVerticalPadding: 0,
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
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
              size: 20,
              color: category.color ?? colorScheme.primary,
            ),
          ),
        ),

        title: Text(
          widget.title != null
              ? widget.title!.toUpperCase()
              : category.nombre.toUpperCase(),
          style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurface),
        ),

        trailing: Text(widget.amount, style: textTheme.titleSmall),
      ),
    );
  }
}

//======================================================================
//REPORT CARDS
//======================================================================
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    this.emoji,
    required this.upText,
    required this.dateText,
    this.isSelected = false,
  });

  final String? emoji;
  final String upText;
  final String dateText;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 80,
      width: double.infinity,
      decoration: decorationContainer(
        context: context,

        colorBorder: isSelected ? colorScheme.primary : Colors.transparent,
        colorFilled: isSelected
            ? colorScheme.primary.withAlpha(30)
            : colorScheme.primaryContainer,

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
              isSelected
                  ? ClipRRect(
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
                    )
                  : emoji == null || emoji!.isEmpty
                  ? Icon(
                      Icons.folder,
                      size: 35,
                      color: colorScheme.onSurfaceVariant,
                    )
                  : Text(emoji!, style: TextStyle(fontSize: 30)),
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

//======================================================================
//NETWORTH CARDS
//======================================================================
class NetworkTypeWidget extends StatelessWidget {
  const NetworkTypeWidget({
    super.key,
    required this.title,
    required this.iconData,
    required this.backgrounCircleColor,
  });

  final String title;
  final IconData iconData;
  final Color backgrounCircleColor;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: decorationContainer(
        context: context,
        colorFilled: colorScheme.surface,
        radius: 20,
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      child: ListTile(
        leading: ClipOval(
          child: Container(
            color: backgrounCircleColor,
            width: 60,
            height: 60,
            child: Icon(iconData, size: 30, color: Colors.white),
          ),
        ),
        title: Text(title, style: textTheme.titleSmall!.copyWith(fontSize: 18)),
      ),
    );
  }
}

class NetworthTypeCardResume extends StatelessWidget {
  const NetworthTypeCardResume({
    super.key,

    required this.titleCard,

    required this.assetType,

    required this.balance,
  });

  final String titleCard;

  final NetWorthAssetType assetType;

  final double balance;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        spacing: 15,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                spacing: 10,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(50)),
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
                  Text(titleCard, style: textTheme.titleSmall),
                ],
              ),
              Text(
                AppFormatters.getFormatedNumber(balance.toString(), balance),
                style: textTheme.titleSmall!,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NetworthTypeCardResumeSliver extends StatelessWidget {
  const NetworthTypeCardResumeSliver({
    super.key,
    required this.titleCard,
    required this.subtitleCard,
    required this.assetType,
    required this.titleBalance,
    required this.balance,
  });

  final String titleCard;
  final String subtitleCard;
  final NetWorthAssetType assetType;
  final String titleBalance;
  final String balance;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return SizedBox(
      //color: colorScheme.primaryContainer,
      child: Column(
        spacing: 15,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  Text(titleCard, style: textTheme.titleSmall),
                  Text(
                    subtitleCard,
                    style: textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleBalance,
                style: textTheme.bodySmall!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              Text(
                balance,
                style: textTheme.titleLarge!.copyWith(fontSize: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
