import 'package:flutter/material.dart';
import 'package:dev_venture/theme/base_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Light theme (UI-REF-2026-001)
/// - primary: brandDark for contrast
/// - inversePrimary: syntaxKeyword for highlights
abstract class AppLightTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: AppThemeTokens.surface50,
    canvasColor: AppThemeTokens.surface50,
    textTheme: GoogleFonts.firaCodeTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    ),
    appBarTheme: _appBarTheme,
    cardTheme: _cardTheme,
    dialogTheme: _dialogTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    textButtonTheme: _textButtonTheme,
    floatingActionButtonTheme: _fabTheme,
    inputDecorationTheme: _inputTheme,
    chipTheme: _chipTheme,
    navigationBarTheme: _navigationBarTheme,
    tabBarTheme: _tabBarTheme,
    dividerTheme: _dividerTheme,
    switchTheme: _switchTheme,
    checkboxTheme: _checkboxTheme,
    snackBarTheme: _snackBarTheme,
    badgeTheme: _badgeTheme,
  );

  // ── ColorScheme ──────────────────────────────────────────────────
  //
  // primary → brandDark: verde escuro garante WCAG AA sobre fundos claros.
  // O ciano puro (#00FFB2) não tem contraste suficiente no light.

  static const _colorScheme = ColorScheme(
    brightness: Brightness.light,

    primary: AppThemeTokens.brandDark,
    onPrimary: AppThemeTokens.surface50,
    primaryContainer: AppThemeTokens.primaryContainerLight,
    onPrimaryContainer: AppThemeTokens.brandDark,

    secondary: AppThemeTokens.neutralLight400,
    onSecondary: AppThemeTokens.surface50,
    secondaryContainer: AppThemeTokens.surface200,
    onSecondaryContainer: AppThemeTokens.neutralLight600,

    tertiary: AppThemeTokens.syntaxWarning,
    onTertiary: AppThemeTokens.brandDark,
    tertiaryContainer: AppThemeTokens.amberContainerLight,
    onTertiaryContainer: AppThemeTokens.brandDark,

    error: AppThemeTokens.errorLight,
    onError: AppThemeTokens.surface50,
    errorContainer: AppThemeTokens.errorContainerLight,
    onErrorContainer: AppThemeTokens.brandDark,

    surface: AppThemeTokens.surface100,
    onSurface: AppThemeTokens.neutralLight600,
    surfaceContainerLowest: AppThemeTokens.surface50,
    surfaceContainerLow: AppThemeTokens.surface100,
    surfaceContainer: AppThemeTokens.surface200,
    surfaceContainerHigh: Color(0xFFC8E0DC),
    surfaceContainerHighest: Color(0xFFBDD8D4),
    onSurfaceVariant: AppThemeTokens.neutralLight400,

    outline: Color(0x30000000),
    outlineVariant: Color(0x18000000),

    inverseSurface: AppThemeTokens.neutralLight600,
    onInverseSurface: AppThemeTokens.surface50,
    inversePrimary: AppThemeTokens.syntaxKeyword,

    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent,
  );

  // ── AppBar ───────────────────────────────────────────────────────
  static const _appBarTheme = AppBarTheme(
    backgroundColor: AppThemeTokens.surface50,
    foregroundColor: AppThemeTokens.neutralLight600,
    elevation: 0,
    scrolledUnderElevation: 1,
    surfaceTintColor: Colors.transparent,
  );

  // ── Card ─────────────────────────────────────────────────────────
  static final _cardTheme = CardThemeData(
    color: AppThemeTokens.surface100,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0x20000000), width: 1),
    ),
  );

  // ── Dialog ───────────────────────────────────────────────────────
  static final _dialogTheme = DialogThemeData(
    backgroundColor: AppThemeTokens.surface100,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: AppThemeTokens.brandDark.withOpacity(0.25),
        width: 1,
      ),
    ),
  );

  // ── ElevatedButton ───────────────────────────────────────────────
  // brandDark com texto claro — alto contraste no light.
  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppThemeTokens.brandDark,
      foregroundColor: AppThemeTokens.surface50,
      elevation: 0,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  );

  // ── OutlinedButton ───────────────────────────────────────────────
  // Borda neutra escura — não compete com o botão primário.
  static final _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppThemeTokens.neutralLight600,
      side: const BorderSide(color: Color(0x40000000)),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  );

  // ── TextButton ───────────────────────────────────────────────────
  static final _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppThemeTokens.brandDark),
  );

  // ── FAB ──────────────────────────────────────────────────────────
  static const _fabTheme = FloatingActionButtonThemeData(
    backgroundColor: AppThemeTokens.brandDark,
    foregroundColor: AppThemeTokens.surface50,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
  );

  // ── Input ────────────────────────────────────────────────────────
  static final _inputTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppThemeTokens.surface200,
    hintStyle: const TextStyle(color: AppThemeTokens.neutralLight300),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0x20000000), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppThemeTokens.brandDark, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppThemeTokens.errorLight, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: AppThemeTokens.errorLight,
        width: 1.5,
      ),
    ),
  );

  // ── Chip ─────────────────────────────────────────────────────────
  // No light, laranja não tem contraste — usamos brandDark para legibilidade.
  static final _chipTheme = ChipThemeData(
    backgroundColor: AppThemeTokens.surface200,
    labelStyle: const TextStyle(color: AppThemeTokens.brandDark, fontSize: 12),
    side: const BorderSide(color: Color(0x30000000)),
    shape: const StadiumBorder(),
  );

  // ── NavigationBar ────────────────────────────────────────────────
  static final _navigationBarTheme = NavigationBarThemeData(
    backgroundColor: AppThemeTokens.surface100,
    indicatorColor: AppThemeTokens.keywordContainerLight,
    iconTheme: WidgetStateProperty.resolveWith(
      (s) => IconThemeData(
        color: s.contains(WidgetState.selected)
            ? AppThemeTokens.brandDark
            : AppThemeTokens.neutralLight300,
      ),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (s) => TextStyle(
        color: s.contains(WidgetState.selected)
            ? AppThemeTokens.brandDark
            : AppThemeTokens.neutralLight300,
        fontSize: 12,
      ),
    ),
  );

  // ── TabBar ───────────────────────────────────────────────────────
  static const _tabBarTheme = TabBarThemeData(
    labelColor: AppThemeTokens.brandDark,
    unselectedLabelColor: AppThemeTokens.neutralLight300,
    indicatorColor: AppThemeTokens.brandDark,
  );

  // ── Divider ──────────────────────────────────────────────────────
  static const _dividerTheme = DividerThemeData(
    color: Color(0x15000000),
    thickness: 1,
  );

  // ── Switch ───────────────────────────────────────────────────────
  static final _switchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? AppThemeTokens.surface50
          : AppThemeTokens.neutralLight300,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? AppThemeTokens.brandDark
          : AppThemeTokens.surface200,
    ),
  );

  // ── Checkbox ─────────────────────────────────────────────────────
  static final _checkboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? AppThemeTokens.brandDark
          : Colors.transparent,
    ),
    checkColor: WidgetStateProperty.all(AppThemeTokens.surface50),
    side: const BorderSide(color: AppThemeTokens.neutralLight300),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  // ── SnackBar ─────────────────────────────────────────────────────
  static const _snackBarTheme = SnackBarThemeData(
    backgroundColor: AppThemeTokens.neutralLight600,
    contentTextStyle: TextStyle(color: AppThemeTokens.surface50),
    actionTextColor: AppThemeTokens.syntaxKeyword,
    behavior: SnackBarBehavior.floating,
    shape: StadiumBorder(),
  );

  // ── Badge ────────────────────────────────────────────────────────
  static const _badgeTheme = BadgeThemeData(
    backgroundColor: AppThemeTokens.syntaxNumber,
    textColor: AppThemeTokens.surface50,
  );
}
