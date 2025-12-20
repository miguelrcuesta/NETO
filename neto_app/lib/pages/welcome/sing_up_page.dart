import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neto_app/constants/app_utils.dart';
import 'package:neto_app/constants/app_validators.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/provider/user_provider.dart';
import 'package:neto_app/widgets/app_bars.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  //#####################################################################################
  //CONTROLLERS
  //#####################################################################################
  TextEditingController emailtextController = TextEditingController();
  TextEditingController passwordtextController = TextEditingController();
  TextEditingController repeatPasswordtextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //#####################################################################################
  //VARIABLES
  //#####################################################################################
  bool showPassword = false;
  bool showPasswordRepeated = false;
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasNumber = false;
  bool samePassword = false;

  //#####################################################################################
  //FUNCIONES
  //#####################################################################################
  void resetCkecks() {
    setState(() {
      hasMinLength = false;
      hasUppercase = false;
      hasNumber = false;
      samePassword = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    //double mediaWidth = MediaQuery.of(context).size.width;
    //double mediaHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: colorScheme.surface,
      appBar: TitleAppbarBack(title: ''),
      body: Padding(
        padding: AppDimensions.paddingAllMedium,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              _widgetImageLogo(textTheme),
              SizedBox(height: AppDimensions.spacingMedium),
              Text(
                appLocalizations.registerTitle,
                textAlign: TextAlign.start,
                style: textTheme.titleMedium,
              ),

              SizedBox(height: AppDimensions.spacingMedium),
              _widgetemailfield(colorScheme),
              SizedBox(height: AppDimensions.spacingMedium),
              _widgetpasswordfield(context, colorScheme, appLocalizations),
              SizedBox(height: AppDimensions.spacingMedium),

              _widgetrepeatpasswordfield(
                context,
                colorScheme,
                appLocalizations,
              ),

              SizedBox(height: AppDimensions.spacingExtraLarge),
              StandarButton(
                radius: 100,
                height: AppDimensions.inputFieldHeight,
                width: double.infinity,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).register(
                      context,
                      emailtextController.text.trim(),
                      passwordtextController.text,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  }
                },
                text: appLocalizations.buttonSingUp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _widgetImageLogo(TextTheme textTheme) {
    return Row(
      children: [
        Image.asset("assets/logos/logo_1024x1024.png", scale: 20),
        SizedBox(width: AppDimensions.spacingSmall),
        Text(
          "NETO",
          textAlign: TextAlign.start,
          style: textTheme.titleLarge!.copyWith(letterSpacing: 6, fontSize: 25),
        ),
      ],
    );
  }

  StandarTextField _widgetemailfield(ColorScheme colorScheme) {
    return StandarTextField(
      textInputAction: TextInputAction.next,
      enable: true,
      controller: emailtextController,
      maxLines: 1,
      filled: true,
      filledColor: colorScheme.primaryContainer,
      colorFocusBorder: Colors.transparent,
      hintText: "Email",
      validator: emailValidator,
      textInputType: TextInputType.emailAddress,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')), // Bloquea espacios
      ],
    );
  }

  StandarTextField _widgetpasswordfield(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations appLocalizations,
  ) {
    return StandarTextField(
      textInputAction: TextInputAction.next,
      obscoreText: showPassword == false ? true : false,
      onChange: (value) {
        setState(() {
          hasMinLength = value.length >= 8;
          hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
          hasNumber = RegExp(r'\d').hasMatch(value);
          //samePassword = passwordtextController.text == value;
        });
      },
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            showPassword = !showPassword;
          });
        },
        icon: Icon(
          showPassword == true
              ? CupertinoIcons.eye_slash_fill
              : CupertinoIcons.eye,
          color: Theme.of(context).colorScheme.outline,
          size: 18,
        ),
      ),
      enable: true,
      controller: passwordtextController,
      maxLines: 1,
      filled: true,
      filledColor: colorScheme.primaryContainer,
      colorFocusBorder: Colors.transparent,
      hintText: appLocalizations.password,
      validator: passwordValidator,
      textInputType: TextInputType.visiblePassword,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')), // Bloquea espacios
      ],
    );
  }

  StandarTextField _widgetrepeatpasswordfield(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations appLocalizations,
  ) {
    return StandarTextField(
      textInputAction: TextInputAction.done,
      obscoreText: showPasswordRepeated == false ? true : false,
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            showPasswordRepeated = !showPasswordRepeated;
          });
        },
        icon: Icon(
          showPasswordRepeated == true
              ? CupertinoIcons.eye_slash_fill
              : CupertinoIcons.eye,
          color: Theme.of(context).colorScheme.outline,
          size: 18,
        ),
      ),
      enable: true,
      controller: repeatPasswordtextController,
      maxLines: 1,
      filled: true,
      filledColor: colorScheme.primaryContainer,
      colorFocusBorder: Colors.transparent,
      hintText: appLocalizations.repeatpassword,
      validator: passwordValidator,
      textInputType: TextInputType.visiblePassword,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')), // Bloquea espacios
      ],
    );
  }
}
