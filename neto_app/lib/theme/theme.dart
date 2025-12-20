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

//===============================================================================
//===============================================================================
//TEMA OSCURO
//===============================================================================
//===============================================================================

class CustomDarkTheme {
  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      surface: Color.fromARGB(255, 0, 0, 0),
      onSurface: Color(0xffF0F2F4),
      surfaceBright: Color(0xff121212),
      onSurfaceVariant: Color(0xff7C8092),
      primary: Color(0xFF7281FF),
      onPrimary: Color(0xffFFFFFF),
      secondary: Color(0xffF0F2F4),
      onSecondary: Color(0xff1C202B),
      primaryContainer: Color.fromARGB(255, 19, 19, 23),
      onPrimaryContainer: Color(0xffF0F2F4),
      error: Color(0xffFF5544),
      onError: Color(0xff1C202B),
      outline: Color(0xff2C303E),
      outlineVariant: Color(0xff3D4151),
    );
  }

  static ElevatedButtonThemeData darkButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.transparent,
        padding: EdgeInsets.zero,
        backgroundColor: darkScheme().primary,
        minimumSize: const Size(double.infinity, 45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        disabledBackgroundColor: darkScheme().primary.withOpacity(0.5),
        disabledForegroundColor: darkScheme().primary.withOpacity(0.5),
      ),
    );
  }

  static BottomNavigationBarThemeData darkNavBottom() {
    return BottomNavigationBarThemeData(
      showSelectedLabels: true,
      showUnselectedLabels: true,
      backgroundColor: darkScheme().surfaceBright,
      landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
      type: BottomNavigationBarType.fixed,
      selectedIconTheme: IconThemeData(color: darkScheme().onSurface, size: 25),
      selectedItemColor: darkScheme().onSurface,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        color: darkScheme().onSurface,
        fontWeight: FontWeight.bold,
      ),
      unselectedIconTheme: IconThemeData(
        color: darkScheme().onSurfaceVariant,
        size: 25,
      ),
      unselectedItemColor: darkScheme().onSurfaceVariant,
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        color: darkScheme().onSurfaceVariant,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static lightListTitleExpanded() {
    return ExpansionTileThemeData(
      backgroundColor: Colors.transparent,
      collapsedBackgroundColor: Colors.transparent,
      collapsedIconColor: darkScheme().onSurface,
      iconColor: darkScheme().onSurface,
    );
  }

  static AppBarTheme darkAppBarTheme() {
    return AppBarTheme(
      toolbarHeight: 50,
      surfaceTintColor: darkScheme().primaryContainer,
      backgroundColor: darkScheme().primaryContainer,
      titleTextStyle: TextStyle(
        fontSize: 18,
        color: darkScheme().onPrimaryContainer,
        fontWeight: FontWeight.w500,
      ),
      centerTitle: true,
    );
  }

  static TextTheme darkTextThemeData() {
    TextTheme getBaseTextTheme() {
      try {
        return GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
      } on Exception {
        return const TextTheme(
          titleLarge: TextStyle(),
          titleMedium: TextStyle(),
          titleSmall: TextStyle(),
          bodyLarge: TextStyle(),
          bodyMedium: TextStyle(),
          bodySmall: TextStyle(),
        );
      }
    }

    final darkColors = darkScheme();

    return TextTheme(
      titleLarge: getBaseTextTheme().titleLarge!.copyWith(
        fontSize: 25.0,
        height: 32.0 / 22.0,
        fontWeight: FontWeight.bold,
        color: darkColors.onSurface,
        letterSpacing: 0.5,
      ),
      titleMedium: getBaseTextTheme().titleMedium!.copyWith(
        fontSize: 20.0,
        height: 27.0 / 17.0,
        fontWeight: FontWeight.w600,
        color: darkColors.onSurface,
        letterSpacing: 0.5,
      ),
      titleSmall: getBaseTextTheme().titleMedium!.copyWith(
        fontSize: 15.0,
        height: 25.0 / 15.0,
        fontWeight: FontWeight.bold,
        color: darkColors.onSurface,
        letterSpacing: 0.5,
      ),
      bodyLarge: getBaseTextTheme().titleMedium!.copyWith(
        fontSize: 17.0,
        color: darkColors.onSurface,
      ),
      bodyMedium: getBaseTextTheme().titleMedium!.copyWith(
        fontSize: 16.0,
        color: darkColors.onSurface,
      ),
      bodySmall: getBaseTextTheme().titleMedium!.copyWith(
        fontSize: 13,
        color: darkColors.onSurface,
      ),
    );
  }

  static ThemeData darkThemeData() {
    return ThemeData(
      scaffoldBackgroundColor: darkScheme().surfaceBright,
      dividerColor: darkScheme().outline,
      appBarTheme: darkAppBarTheme(),
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      shadowColor: Colors.transparent,
      splashColor: Colors.transparent,
      textTheme: darkTextThemeData(),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: darkScheme().onSurface,
        selectionColor: darkScheme().primary.withOpacity(0.5),
      ),
      fontFamily: "Inter",
      colorScheme: darkScheme(),
      elevatedButtonTheme: darkButtonTheme(),
      bottomNavigationBarTheme: darkNavBottom(),
    );
  }
}
