import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neto_app/widgets/app_buttons.dart';

class AppEmptyStates extends StatelessWidget {
  final String asset;
  final double? heightAsset;
  final String upText;
  final String downText;
  final String btnText;
  final void Function()? onPressed;
  const AppEmptyStates({
    super.key,
    required this.asset,
    this.heightAsset,
    required this.upText,
    required this.downText,
    required this.btnText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 40,
          children: [
            SvgPicture.asset(
              height: heightAsset ?? 180,
              // 'assets/animations/transactions_empty.svg',
              asset,
            ),
            Column(
              spacing: 10,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  upText,
                  style: textTheme.titleMedium!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  textAlign: TextAlign.center,
                  downText,
                  style: textTheme.titleSmall!.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            StandarButton(
              onPressed: onPressed,
              text: btnText,
              width: 160,
              radius: 200,
            ),
          ],
        ),
      ),
    );
  }
}
