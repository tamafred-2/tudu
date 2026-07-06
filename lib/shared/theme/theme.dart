import 'package:flutter/material.dart';

class AppTheme {
  // Custom cozy colors
  static const Color _lightSeedColor = Color(0xFF0F5A47); // Cozy Deep Teal
  static const Color _darkSeedColor = Color(0xFF45A285);  // Calm Mint Teal

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightSeedColor,
        brightness: Brightness.light,
        surface: const Color(0xFFF9FBF9), // Soft off-white with a hint of green
      ),
      scaffoldBackgroundColor: const Color(0xFFF9FBF9),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF191C1B),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFFE0E3E1),
            width: 1,
          ),
        ),
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: const Color(0xFFF0F4F1),
        indicatorColor: const Color(0xFFCDE8E0),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 64,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFF002018), size: 24);
          }
          return const IconThemeData(color: Color(0xFF707974), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF002018),
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF707974),
          );
        }),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFF0F4F1),
        indicatorColor: Color(0xFFCDE8E0),
        labelType: NavigationRailLabelType.all,
        selectedIconTheme: IconThemeData(color: Color(0xFF002018), size: 24),
        unselectedIconTheme: IconThemeData(color: Color(0xFF707974), size: 24),
        selectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF002018),
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF707974),
        ),
      ),
      navigationDrawerTheme: const NavigationDrawerThemeData(
        elevation: 0,
        backgroundColor: Color(0xFFF0F4F1),
        indicatorColor: Color(0xFFCDE8E0),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _darkSeedColor,
        brightness: Brightness.dark,
        surface: const Color(0xFF111413), // Deep slate dark background
      ),
      scaffoldBackgroundColor: const Color(0xFF111413),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE1E3E0),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFF2C322F),
            width: 1,
          ),
        ),
        color: const Color(0xFF1A1E1C),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: const Color(0xFF191D1A),
        indicatorColor: const Color(0xFF334B43),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 64,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Color(0xFFE1E3E0), size: 24);
          }
          return const IconThemeData(color: Color(0xFF8B938F), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE1E3E0),
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B938F),
          );
        }),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF191D1A),
        indicatorColor: Color(0xFF334B43),
        labelType: NavigationRailLabelType.all,
        selectedIconTheme: IconThemeData(color: Color(0xFFE1E3E0), size: 24),
        unselectedIconTheme: IconThemeData(color: Color(0xFF8B938F), size: 24),
        selectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE1E3E0),
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF8B938F),
        ),
      ),
      navigationDrawerTheme: const NavigationDrawerThemeData(
        elevation: 0,
        backgroundColor: Color(0xFF191D1A),
        indicatorColor: Color(0xFF334B43),
      ),
    );
  }
}
