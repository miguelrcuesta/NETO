import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class CustomLightTheme {
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,

      //##################################################
      //SURFACE
      //##################################################
      surface: Color(0xffF0F2F4),
      onSurface: Color(0xff1C202B),
      surfaceBright: Color(0xffFFFFFF),
      onSurfaceVariant: Color(0xffA7AEC4),
      primary: Color(0xFF7236FF),
      onPrimary: Color(0xffFFFFFF),
      secondary: Color(0xff1C202B),
      onSecondary: Color(0xffFFFFFF),
      primaryContainer: Color(0xffFFFFFF),
      onPrimaryContainer: Color(0xff1C202B),

      //Colors for errors
      error: Color(0xffD41500),
      onError: Color(0xffffffff),

      //Lines colors
      outline: Color(0xffECEDEE),
      outlineVariant: Color(0xffA7AEC4),
    );
  }

  static ElevatedButtonThemeData lightButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.transparent,
        padding: EdgeInsets.zero,
        backgroundColor: lightScheme().primary,
        minimumSize: const Size(double.infinity, 45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        disabledBackgroundColor: lightScheme().primary.withValues(alpha: 0.5),
        disabledForegroundColor: lightScheme().primary.withValues(alpha: 0.5),
      ),
    );
  }

  static BottomNavigationBarThemeData lightNavBottom() {
    return BottomNavigationBarThemeData(
      showSelectedLabels: true,
      showUnselectedLabels: true,
      backgroundColor: lightScheme().surface,
      landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
      type: BottomNavigationBarType.fixed,
      selectedIconTheme: IconThemeData(
        color: lightScheme().onSurface,
        size: 25,
      ),
      selectedItemColor: lightScheme().onSurface,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        color: lightScheme().onSurface,
        fontWeight: FontWeight.bold,
      ),
      unselectedIconTheme: IconThemeData(
        color: lightScheme().onSurfaceVariant,
        size: 25,
      ),
      unselectedItemColor: lightScheme().onSurfaceVariant,
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        color: lightScheme().onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static lightListTitleExpanded() {
    return ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      collapsedIconColor: lightScheme().onSurface,
      iconColor: lightScheme().onSurface,
    );
  }

  static AppBarTheme lightAppBarTheme() {
    return AppBarTheme(
      toolbarHeight: 50,
      surfaceTintColor: lightScheme().primaryContainer,
      backgroundColor: lightScheme().primaryContainer,
      titleTextStyle: TextStyle(
        fontSize: 18,
        color: lightScheme().onPrimaryContainer,
        fontWeight: FontWeight.w500,
      ),
      centerTitle: true,
    );
  }

  static TextTheme lightTextThemeData() {
    TextTheme getBaseTextTheme() {
      try {
        return GoogleFonts.interTextTheme(ThemeData.light().textTheme);
      } on Exception {
        return const TextTheme(
          titleLarge: TextStyle(),
          titleMedium: TextStyle(),
          titleSmall: TextStyle(),
          bodyLarge: TextStyle(),
          bodyMedium: TextStyle(),
          bodySmall: TextStyle(),
        ); // fallback, no necesario realmente
      }
    }

    // TextTheme getBaseTextTheme() {
    //   return const TextTheme(
    //     titleLarge: TextStyle(),
    //     titleMedium: TextStyle(),
    //     titleSmall: TextStyle(),
    //     bodyLarge: TextStyle(),
    //     bodyMedium: TextStyle(),
    //     bodySmall: TextStyle(),
    //   ); // fallback, no necesario realmente
    // }

    return TextTheme(
      titleLarge: getBaseTextTheme().titleLarge!.copyWith(
        fontSize: 25.0,
        height: 32.0 / 22.0,
        fontWeight: FontWeight.bold,
        color: lightScheme().onSurface,
        letterSpacing: 0.5,
      ),
      titleMedium: getBaseTextTheme().titleMedium!.copyWith(
        fontSize: 20.0,
        height: 27.0 / 17.0,
        fontWeight: FontWeight.w600,
        color: lightScheme().onSurface,
        letterSpacing: 0.5,
      ),
      titleSmall: getBaseTextTheme().titleMedium!.copyWith(
        fontSize: 15.0,
        height: 25.0 / 15.0,
        fontWeight: FontWeight.bold,
        color: lightScheme().onSurface,
        letterSpacing: 0.5,
      ),
      bodyLarge: getBaseTextTheme().titleMedium!.copyWith(
        fontSize: 17.0,
        // height: 27.0 / 17.0,
        color: lightScheme().onSurface,
        // letterSpacing: 0.5,
      ),
      bodyMedium: getBaseTextTheme().titleMedium!.copyWith(
        fontSize: 16.0,
        // height: 25.0 / 15.0,
        //fontWeight: FontWeight.w300,
        color: lightScheme().onSurface,
        // letterSpacing: 0.5,
      ),
      bodySmall: getBaseTextTheme().titleMedium!.copyWith(
        fontSize: 13,
        // height: 16.0 / 13.0,
        color: lightScheme().onSurface,
        // letterSpacing: 0.5,
      ),
    );
  }

  static ThemeData lightThemeData() {
    return ThemeData(
      scaffoldBackgroundColor: lightScheme().surfaceBright,
      dividerColor: Colors.transparent,
      appBarTheme: lightAppBarTheme(),
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      shadowColor: Colors.transparent,
      splashColor: Colors.transparent,
      textTheme: lightTextThemeData(),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: const Color(0xff353535),
        selectionColor: Colors.blue[300],
      ),
      fontFamily: "Inter",
      colorScheme: lightScheme(),
      elevatedButtonTheme: lightButtonTheme(),
      bottomNavigationBarTheme: lightNavBottom(),
      // tabBarTheme: lightTabBarTheme(),
    );
  }
}
