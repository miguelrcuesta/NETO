import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//##########################################################################################
//                                      DECORATIONS
//##########################################################################################
OutlineInputBorder outlineInputBorder({
  required BuildContext context,

  Color? colorBorder,
  double? borderWidth,
  double? radius,
}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)),
    borderSide: BorderSide(width: borderWidth ?? 0.0, color: colorBorder ?? Colors.transparent),
  );
}

BoxDecoration? decorationContainer({
  required BuildContext context,
  Color? colorFilled,
  Color? colorBorder,
  double? borderWidth,
  double? radius,
  List<BoxShadow>? boxShadow,
}) {
  ColorScheme colorScheme = Theme.of(context).colorScheme;
  return BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
    color: colorFilled ?? colorScheme.surfaceBright,
    border: Border.all(color: colorBorder ?? Colors.transparent, width: borderWidth ?? 0),
    boxShadow: boxShadow,
  );
}

// ignore: must_be_immutable
class StandarTextField extends StatelessWidget {
  final bool enable;
  final TextInputType? textInputType;
  final String? initialValue;
  final bool? filled;
  final Color? filledColor;
  final String? hintText;
  final String? labelText;
  final TextStyle? labelStyle;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final void Function()? onTap;
  final void Function(String)? onChange;
  final Widget? suffixIcon;
  final String? sufix;
  final String? prefix;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? paddingContent;
  final Color? colorFocusBorder;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign? textAlign;
  final TextStyle? textInputTheme;
  final TextStyle? textHintStyle;
  final double? prefixwidth;
  final bool? expands;
  final int? maxLines;
  final TextAlignVertical? textAlignVertical;
  final bool? obscoreText;
  void Function(PointerDownEvent)? onTapOutside;
  TextInputAction? textInputAction;
  StandarTextField({
    super.key,
    this.prefix,
    this.sufix,
    this.hintText,
    this.labelText,
    required this.enable,
    this.initialValue,
    this.controller,
    this.validator,
    this.onTap,
    this.onChange,
    this.textInputType,
    this.filledColor,
    this.filled,
    this.suffixIcon,
    this.prefixIcon,
    this.paddingContent,
    this.colorFocusBorder,
    this.textAlign,
    this.inputFormatters,
    this.textInputTheme,
    this.labelStyle,
    this.textHintStyle,
    this.prefixwidth,
    this.maxLines,
    this.expands,
    this.textAlignVertical,
    this.obscoreText,
    this.onTapOutside,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return TextFormField(
      enabled: enable,
      textAlignVertical: textAlignVertical ?? TextAlignVertical.center,
      expands: expands ?? false,
      selectionHeightStyle: BoxHeightStyle.strut,
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines == null ? null : 1,
      inputFormatters: inputFormatters,
      controller: controller,
      validator: validator,
      cursorColor: colorScheme.onSurfaceVariant,
      initialValue: initialValue,
      textInputAction: textInputAction ?? TextInputAction.none,
      keyboardType: textInputType ?? TextInputType.emailAddress,
      obscureText: obscoreText ?? false,
      style: textInputTheme ?? textTheme.bodyLarge,
      onTap: onTap,
      onChanged: onChange,

      onTapOutside:
          onTapOutside ??
          (event) {
            // code to unfocus after tap outside
            FocusManager.instance.primaryFocus?.unfocus();
          },

      decoration: InputDecoration(
        filled: filled,
        fillColor: filled == true ? filledColor : null,
        contentPadding: paddingContent,
        labelText: labelText,
        labelStyle:
            labelStyle ?? textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant),
        hintText: hintText,
        hintStyle:
            textHintStyle ?? textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant),

        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefix: prefix != null
            ? SizedBox(
                width: prefixwidth ?? 85,
                // padding: const EdgeInsets.only(right: 25.0), // 👈 separa el texto
                child: Text(
                  prefix ?? "",
                  softWrap: true,
                  style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              )
            : null,
        prefixStyle: textTheme.bodySmall!.copyWith(color: colorScheme.primary),
        suffix: sufix != null
            ? SizedBox(
                width: prefixwidth ?? 85,
                //padding: const EdgeInsets.only(left: 25.0), // 👈 separa el texto
                child: Text(
                  sufix ?? "",
                  softWrap: true,
                  style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              )
            : null,
        border: outlineInputBorder(
          context: context,
          colorBorder: Colors.transparent,
          borderWidth: 1,
          radius: 5,
        ),
        enabledBorder: outlineInputBorder(
          context: context,

          colorBorder: Colors.transparent,
          borderWidth: 1,
          radius: 5,
        ),
        focusedBorder: outlineInputBorder(
          context: context,
          colorBorder: colorFocusBorder ?? colorScheme.primary,
          borderWidth: 1.5,
          radius: 5,
        ),
        errorBorder: outlineInputBorder(
          context: context,

          colorBorder: Colors.transparent,
          borderWidth: 1,
          radius: 5,
        ),
        disabledBorder: outlineInputBorder(
          context: context,

          colorBorder: Colors.transparent,
          borderWidth: 1,
          radius: 5,
        ),
      ),
    );
  }
}
