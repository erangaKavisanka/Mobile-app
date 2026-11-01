import 'package:flutter/material.dart';

/// EcoLink visual identity: deep trail-green primary, signal-blue secondary,
/// amber for caution and a dedicated emergency red.
class EcoColors {
  EcoColors._();

  static const trail = Color(0xFF0F766E);
  static const signal = Color(0xFF2F5BA8);
  static const amber = Color(0xFFB45309);
  static const emergency = Color(0xFFC62828);
  static const ink = Color(0xFF0F1F1D);
}

/// Semantic colors that Material's ColorScheme has no slot for.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.info,
    required this.infoContainer,
    required this.neutral,
    required this.neutralContainer,
    required this.simulated,
    required this.simulatedContainer,
  });

  final Color success, successContainer;
  final Color warning, warningContainer;
  final Color danger, dangerContainer;
  final Color info, infoContainer;
  final Color neutral, neutralContainer;
  final Color simulated, simulatedContainer;

  static const light = StatusColors(
    success: Color(0xFF166534),
    successContainer: Color(0xFFDCF5E3),
    warning: Color(0xFF92400E),
    warningContainer: Color(0xFFFDEBC8),
    danger: Color(0xFF991B1B),
    dangerContainer: Color(0xFFFDE2E2),
    info: Color(0xFF1E429F),
    infoContainer: Color(0xFFDDE7FB),
    neutral: Color(0xFF475467),
    neutralContainer: Color(0xFFE8ECEF),
    simulated: Color(0xFF5B21B6),
    simulatedContainer: Color(0xFFEBE3FB),
  );

  static const dark = StatusColors(
    success: Color(0xFF86E0A0),
    successContainer: Color(0xFF123C22),
    warning: Color(0xFFF6C26B),
    warningContainer: Color(0xFF4A2D08),
    danger: Color(0xFFFFADAD),
    dangerContainer: Color(0xFF5A1515),
    info: Color(0xFFA9C3FF),
    infoContainer: Color(0xFF16305F),
    neutral: Color(0xFFB4BEC8),
    neutralContainer: Color(0xFF2A3338),
    simulated: Color(0xFFD0BCFF),
    simulatedContainer: Color(0xFF3B2A66),
  );

  @override
  StatusColors copyWith() => this;

  @override
  StatusColors lerp(StatusColors? other, double t) =>
      t < 0.5 ? this : other ?? this;
}

extension StatusColorsContext on BuildContext {
  StatusColors get status => Theme.of(this).extension<StatusColors>()!;
}

class Spacing {
  Spacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class Radii {
  Radii._();
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;
}

class EcoTheme {
  EcoTheme._();

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ColorScheme.fromSeed(
      seedColor: EcoColors.trail,
      brightness: brightness,
      primary: isDark ? const Color(0xFF5FD3C4) : EcoColors.trail,
      secondary: isDark ? const Color(0xFFA9C3FF) : EcoColors.signal,
      tertiary: isDark ? const Color(0xFFF6C26B) : EcoColors.amber,
      error: isDark ? const Color(0xFFFF8A80) : EcoColors.emergency,
    );
    final scheme = base.copyWith(
      surface: isDark ? const Color(0xFF0E1614) : const Color(0xFFF5F8F7),
      surfaceContainerLowest: isDark ? const Color(0xFF0A110F) : Colors.white,
      surfaceContainerLow: isDark
          ? const Color(0xFF141E1B)
          : const Color(0xFFFFFFFF),
      surfaceContainer: isDark
          ? const Color(0xFF18241F)
          : const Color(0xFFEEF3F1),
      outlineVariant: isDark
          ? const Color(0xFF2E3D38)
          : const Color(0xFFDCE5E1),
    );

    final text = _textTheme(scheme.onSurface);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.md),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      extensions: [isDark ? StatusColors.dark : StatusColors.light],
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: shape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: shape,
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelMedium!.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        backgroundColor: scheme.surfaceContainerLowest,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(minVerticalPadding: 8),
    );
  }

  /// Typography scale. Weights and tracking are tuned for outdoor legibility.
  static TextTheme _textTheme(Color color) {
    TextStyle s(double size, FontWeight w, {double h = 1.3, double ls = 0}) =>
        TextStyle(
          fontSize: size,
          fontWeight: w,
          height: h,
          letterSpacing: ls,
          color: color,
        );
    return TextTheme(
      displaySmall: s(34, FontWeight.w800, h: 1.15, ls: -0.5),
      headlineMedium: s(26, FontWeight.w800, h: 1.2, ls: -0.3),
      headlineSmall: s(22, FontWeight.w700, h: 1.25, ls: -0.2),
      titleLarge: s(20, FontWeight.w700, ls: -0.1),
      titleMedium: s(16, FontWeight.w700),
      titleSmall: s(14, FontWeight.w700),
      bodyLarge: s(16, FontWeight.w400, h: 1.45),
      bodyMedium: s(14, FontWeight.w400, h: 1.45),
      bodySmall: s(12, FontWeight.w400, h: 1.4),
      labelLarge: s(15, FontWeight.w700, ls: 0.1),
      labelMedium: s(12, FontWeight.w600, ls: 0.2),
      labelSmall: s(11, FontWeight.w600, ls: 0.3),
    );
  }
}
