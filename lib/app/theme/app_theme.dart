import 'package:flutter/material.dart';

class EcoLinkTheme {
  static const Color forest = Color(0xFF164E63);
  static const Color moss = Color(0xFF3B7A57);
  static const Color meadow = Color(0xFF7DBA78);
  static const Color sand = Color(0xFFF4E9D8);
  static const Color clay = Color(0xFFB86442);
  static const Color deepNight = Color(0xFF0F172A);
  static const Color cardSurface = Color(0xFFF8FAFC);

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: forest,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFBFE5DC),
      onPrimaryContainer: deepNight,
      secondary: moss,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD9F0E4),
      onSecondaryContainer: deepNight,
      tertiary: clay,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFF5D9CA),
      onTertiaryContainer: deepNight,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: sand,
      onSurface: deepNight,
      surfaceContainerHighest: Colors.white,
      onSurfaceVariant: Color(0xFF475569),
      outline: Color(0xFFCBD5E1),
      shadow: Color(0xFF0F172A),
      scrim: Color(0xFF0F172A),
      inverseSurface: deepNight,
      onInverseSurface: Colors.white,
      inversePrimary: Color(0xFFB5E3C8),
      surfaceTint: forest,
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F8F5),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: Color(0xFFF4F8F5),
      elevation: 0,
      foregroundColor: deepNight,
    ),
    cardTheme: CardThemeData(
      color: cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFD9F0E4),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: forest,
          );
        }
        return const TextStyle(fontSize: 12, color: Color(0xFF475569));
      }),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w700, color: deepNight),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: deepNight),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, color: deepNight),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: deepNight),
      bodyLarge: TextStyle(color: deepNight),
      bodyMedium: TextStyle(color: deepNight),
      labelLarge: TextStyle(fontWeight: FontWeight.w600, color: deepNight),
    ),
  );
}
