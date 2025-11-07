import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neto_app/constants/app_dimensions.dart';
import 'package:neto_app/constants/app_validators.dart';
import 'package:neto_app/l10n/app_localizations.dart';
import 'package:neto_app/widgets/app_buttons.dart';
import 'package:neto_app/widgets/app_fields.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //#####################################################################################
  //CONTROLLERS
  //#####################################################################################
  TextEditingController emailtextController = TextEditingController();
  TextEditingController emailRestPasswordtextController = TextEditingController();
  TextEditingController passwordtextController = TextEditingController();

  //#####################################################################################
  //VARIABLES
  //#####################################################################################
  bool showPassword = false;

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
      body: Padding(
        padding: AppDimensions.paddingAllMedium,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _widgetImageLogo(textTheme),
            SizedBox(height: AppDimensions.spacingExtraLarge),
            Text(
              appLocalizations.loginTitle,
              textAlign: TextAlign.start,
              style: textTheme.titleMedium,
            ),

            SizedBox(height: AppDimensions.spacingMedium),
            _widgetemailfield(colorScheme),
            SizedBox(height: AppDimensions.spacingMedium),
            _widgetpasswordfield(context, colorScheme, appLocalizations),
            _widgetforgotPassword(colorScheme, context, textTheme, appLocalizations),
            SizedBox(height: AppDimensions.spacingExtraLarge),
            StandarButton(
              height: AppDimensions.inputFieldHeight,
              width: double.infinity,
              onPressed: () {
                debugPrint("Send email with reset pasword");
              },
              text: appLocalizations.buttonSingIn,
            ),
          ],
        ),
      ),
    );
  }

  Row _widgetImageLogo(TextTheme textTheme) {
    return Row(
      children: [
        Image.asset("assets/logos/logo_1024x1024.png", scale: 15),
        SizedBox(width: AppDimensions.spacingSmall),
        Text(
          "NETO",
          textAlign: TextAlign.start,
          style: textTheme.titleLarge!.copyWith(letterSpacing: 10, fontSize: 35),
        ),
      ],
    );
  }

  StandarTextField _widgetemailfield(ColorScheme colorScheme) {
    return StandarTextField(
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
      obscoreText: showPassword == false ? true : false,
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            showPassword = !showPassword;
          });
        },
        icon: Icon(
          showPassword == true ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye,
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

  TextButton _widgetforgotPassword(
    ColorScheme colorScheme,
    BuildContext context,
    TextTheme textTheme,
    AppLocalizations appLocalizations,
  ) {
    return TextButton(
      onPressed: () async {
        final formKeyReset = GlobalKey<FormState>();
        return showModalBottomSheet(
          isScrollControlled: true,
          useSafeArea: true,
          barrierColor: colorScheme.surface,
          context: context,
          builder: (context) {
            return Scaffold(
              backgroundColor: colorScheme.surface,
              appBar: AppBar(),
              body: Form(
                key: formKeyReset,
                child: Container(
                  margin: AppDimensions.paddingAllMedium,

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appLocalizations.sendNewPasswordtittLe,
                            style: textTheme.titleMedium,
                          ),
                          SizedBox(height: AppDimensions.spacingSmall),
                          Text(
                            appLocalizations.sendNewPasswordMsg,
                            style: textTheme.bodyMedium!.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: AppDimensions.spacingMedium),
                          StandarTextField(
                            enable: true,

                            onTapOutside: (event) {
                              FocusScope.of(context).unfocus(); // cierra el teclado
                            },
                            maxLines: 1,
                            labelText: "Email",
                            filledColor: colorScheme.surfaceBright,
                            filled: true,
                            hintText: "ejemplo@workplay.com",
                            controller: emailRestPasswordtextController,
                            validator: emailValidator,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'\s')), // Bloquea espacios
                            ],
                            textInputType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.spacingExtraLarge),
                      StandarButton(
                        height: AppDimensions.inputFieldHeight,
                        width: double.infinity,
                        onPressed: () {
                          debugPrint("Send email with reset pasword");
                        },
                        text: appLocalizations.buttonResetPwd,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Text(
        appLocalizations.forgotPassword,
        style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant),
        textAlign: TextAlign.right,
      ),
    );
  }
}
