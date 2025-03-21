import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Main Colors
  static const Color primaryColor = Color(0xFF4A6572);
  static const Color accentColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFFF9AA33);
  static const Color backgroundLightColor = Color(0xFFF5F5F5);
  static const Color backgroundDarkColor = Color(0xFF333333);
  static const Color backgroundColor = Color(0xFFF5F5F5); // Alias for backgroundLightColor

  // Semantic Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color infoColor = Color(0xFF2196F3);

  // Text Colors
  static const Color textPrimaryDarkColor = Color(0xFF333333);
  static const Color textSecondaryDarkColor = Color(0xFF757575);
  static const Color textPrimaryLightColor = Color(0xFFFFFFFF);
  static const Color textSecondaryLightColor = Color(0xFFE0E0E0);

  // Common text colors (to match dashboard_screen and other files)
  static const Color textPrimaryColor = Color(0xFF333333); // Alias for textPrimaryDarkColor
  static const Color textSecondaryColor = Color(0xFF757575); // Alias for textSecondaryDarkColor
  static const Color primaryContrastText = Color(0xFFFFFFFF); // Alias for textPrimaryLightColor

  // Custom Status Colors
  static const Color attendancePresent = Color(0xFF4CAF50);
  static const Color attendanceAbsent = Color(0xFFE53935);
  static const Color attendanceLate = Color(0xFFFFA000);
  static const Color attendanceExcused = Color(0xFF2196F3);

  // Define font families
  static String fontFamily = 'Poppins_regular';

  // Text Theme
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 96,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
      color: textPrimaryDarkColor,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 60,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: textPrimaryDarkColor,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 48,
      fontWeight: FontWeight.w400,
      color: textPrimaryDarkColor,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 34,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: textPrimaryDarkColor,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: textPrimaryDarkColor,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: textPrimaryDarkColor,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      color: textPrimaryDarkColor,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: textPrimaryDarkColor,
    ),
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: textPrimaryDarkColor,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: textPrimaryDarkColor,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: textPrimaryDarkColor,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: textPrimaryDarkColor,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
      color: textPrimaryDarkColor,
    ),
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    fontFamily: 'Poppins',
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor),
      ),
    ),
    scaffoldBackgroundColor: backgroundLightColor,
    appBarTheme: AppBarTheme(
      color: primaryColor,
      iconTheme: const IconThemeData(color: textPrimaryLightColor),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: textPrimaryLightColor,
      ),
    ),
    iconTheme: const IconThemeData(color: primaryColor),
    textTheme: GoogleFonts.poppinsTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: textPrimaryLightColor,
        backgroundColor: primaryColor,
        textStyle: textTheme.labelLarge?.copyWith(color: textPrimaryLightColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        textStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: textSecondaryDarkColor,
      labelStyle: textTheme.labelLarge,
      unselectedLabelStyle: textTheme.labelLarge,
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey.shade400;
        }
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade50;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey.shade200;
        }
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.5);
        }
        return Colors.grey.shade300;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey.shade400;
        }
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryDarkColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: textTheme.bodySmall?.copyWith(color: textPrimaryLightColor),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: textPrimaryLightColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      actionTextColor: secondaryColor,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      onPrimary: textPrimaryLightColor,
      onSecondary: textPrimaryDarkColor,
      background: backgroundDarkColor,
      surface: Color(0xFF424242),
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundDarkColor,
    appBarTheme: AppBarTheme(
      color: Colors.grey.shade900,
      iconTheme: const IconThemeData(color: textPrimaryLightColor),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: textPrimaryLightColor,
      ),
    ),
    iconTheme: const IconThemeData(color: textPrimaryLightColor),
    textTheme: textTheme.apply(
      bodyColor: textPrimaryLightColor,
      displayColor: textPrimaryLightColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.grey.shade800,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(color: textPrimaryLightColor),
      hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondaryLightColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: textPrimaryDarkColor,
        backgroundColor: secondaryColor,
        textStyle: textTheme.labelLarge?.copyWith(color: textPrimaryDarkColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimaryLightColor,
        side: const BorderSide(color: textPrimaryLightColor),
        textStyle: textTheme.labelLarge?.copyWith(color: textPrimaryLightColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondaryColor,
        textStyle: textTheme.labelLarge?.copyWith(color: secondaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.grey.shade800,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: secondaryColor,
      unselectedLabelColor: textSecondaryLightColor,
      labelStyle: textTheme.labelLarge?.copyWith(color: secondaryColor),
      unselectedLabelStyle: textTheme.labelLarge?.copyWith(color: textSecondaryLightColor),
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: secondaryColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey.shade700;
        }
        if (states.contains(MaterialState.selected)) {
          return secondaryColor;
        }
        return Colors.grey.shade400;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey.shade800;
        }
        if (states.contains(MaterialState.selected)) {
          return secondaryColor.withOpacity(0.5);
        }
        return Colors.grey.shade700;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.grey.shade700;
        }
        if (states.contains(MaterialState.selected)) {
          return secondaryColor;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.black),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey.shade900,
      selectedItemColor: secondaryColor,
      unselectedItemColor: textSecondaryLightColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: textTheme.bodySmall?.copyWith(color: textPrimaryLightColor),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.grey.shade800,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: textTheme.titleLarge?.copyWith(color: textPrimaryLightColor),
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: textPrimaryLightColor),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey.shade800,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: textPrimaryLightColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      actionTextColor: secondaryColor,
    ),
  );
}