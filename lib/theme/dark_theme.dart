import 'package:flutter/material.dart';
import 'package:dev_venture/theme/base_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dark theme (UI-REF-2026-001)
/// - canvas: near-neutral dark
/// - primary: syntaxKeyword (ciano) for system actions
abstract class AppDarkTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: AppThemeTokens.neutral900,
    canvasColor: AppThemeTokens.neutral900,
    textTheme: GoogleFonts.firaCodeTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
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
  // primary    → syntaxKeyword (ciano)  — ações principais
  // secondary  → neutral300             — ações secundárias
  // tertiary   → syntaxWarning (âmbar)  — alertas e avisos
  // error      → syntaxError (verm.)    — estados de falha
  // surface    → neutral800             — cards e superfícies

  static const _colorScheme = ColorScheme(
    brightness: Brightness.dark,

    primary: AppThemeTokens.syntaxKeyword,
    onPrimary: AppThemeTokens.brandDark,
    primaryContainer: AppThemeTokens.primaryContainerDark,
    onPrimaryContainer: AppThemeTokens.syntaxKeyword,

    secondary: AppThemeTokens.neutral300,
    onSecondary: AppThemeTokens.neutral900,
    secondaryContainer: AppThemeTokens.neutral700,
    onSecondaryContainer: AppThemeTokens.neutral100,

    tertiary: AppThemeTokens.syntaxWarning,
    onTertiary: AppThemeTokens.brandDark,
    tertiaryContainer: AppThemeTokens.amberContainerDark,
    onTertiaryContainer: AppThemeTokens.syntaxWarning,

    error: AppThemeTokens.errorDark,
    onError: AppThemeTokens.brandDark,
    errorContainer: AppThemeTokens.errorContainerDark,
    onErrorContainer: Color(0xFFFFDAD6),

    surface: AppThemeTokens.neutral800,
    onSurface: AppThemeTokens.neutral100,
    surfaceContainerLowest: AppThemeTokens.neutral900,
    surfaceContainerLow: AppThemeTokens.neutral800,
    surfaceContainer: AppThemeTokens.neutral700,
    surfaceContainerHigh: AppThemeTokens.neutral600,
    surfaceContainerHighest: AppThemeTokens.neutral600,
    onSurfaceVariant: AppThemeTokens.neutral300,

    // Bordas: branco com baixa opacidade — nunca verde sólido
    outline: AppThemeTokens.borderDefault,
    outlineVariant: Color(0x0FFFFFFF), // 6% branco

    inverseSurface: AppThemeTokens.neutral100,
    onInverseSurface: AppThemeTokens.neutral900,
    inversePrimary: AppThemeTokens.brandDark,

    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Colors.transparent, // Remove tint verde do Material 3
  );

  // ── AppBar ───────────────────────────────────────────────────────
  // Mesmo fundo do scaffold — continuidade de editor sem linha divisória verde.
  static const _appBarTheme = AppBarTheme(
    backgroundColor: AppThemeTokens.neutral900,
    foregroundColor: AppThemeTokens.neutral100,
    elevation: 0,
    scrolledUnderElevation: 1,
    surfaceTintColor: Colors.transparent,
  );

  // ── Card ─────────────────────────────────────────────────────────
  // neutral800 com borda sutil branca (8%) — painel de editor neutro.
  static final _cardTheme = CardThemeData(
    color: AppThemeTokens.neutral800,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppThemeTokens.borderDefault, width: 1),
    ),
  );

  // ── Dialog ───────────────────────────────────────────────────────
  // neutral800 com borda ciano sutil — popup de autocomplete de editor.
  static final _dialogTheme = DialogThemeData(
    backgroundColor: AppThemeTokens.neutral800,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: AppThemeTokens.syntaxKeyword.withOpacity(0.25),
        width: 1,
      ),
    ),
  );

  // ── ElevatedButton ───────────────────────────────────────────────
  // Verde sólido com texto escuro — única instância de verde dominante.
  // Representa o sinal de "ação principal / sistema operante".
  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppThemeTokens.syntaxKeyword,
      foregroundColor: AppThemeTokens.brandDark,
      elevation: 0,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  );

  // ── OutlinedButton ───────────────────────────────────────────────
  // Borda cinza neutra — não compete com o botão primário verde.
  static final _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppThemeTokens.neutral300,
      side: const BorderSide(color: AppThemeTokens.borderEmphasis),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),
  );

  // ── TextButton ───────────────────────────────────────────────────
  // Ciano para ações terciárias — mantém hierarquia sem abuso de verde.
  static final _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppThemeTokens.syntaxKeyword),
  );

  // ── FAB ──────────────────────────────────────────────────────────
  static const _fabTheme = FloatingActionButtonThemeData(
    backgroundColor: AppThemeTokens.syntaxKeyword,
    foregroundColor: AppThemeTokens.brandDark,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
    ),
  );

  // ── Input ────────────────────────────────────────────────────────
  // neutral700 com borda de foco em ciano — simula linha de terminal ativo.
  // Borda padrão: branco 8% — nunca verde em repouso.
  static final _inputTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppThemeTokens.neutral700,
    hintStyle: const TextStyle(color: AppThemeTokens.syntaxComment),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: AppThemeTokens.borderDefault,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: AppThemeTokens.syntaxKeyword.withOpacity(0.4),
        width: 1.5,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: AppThemeTokens.syntaxError.withOpacity(0.4),
        width: 1,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: AppThemeTokens.syntaxError,
        width: 1.5,
      ),
    ),
  );

  // ── Chip ─────────────────────────────────────────────────────────
  // Chips de categoria com cor semântica por tecnologia:
  //   Dart     → syntaxType (azul)
  //   Flutter  → syntaxString (verde médio)
  //   Firebase → syntaxWarning (âmbar)
  // Label em laranja (syntaxFunction) como padrão genérico.
  static final _chipTheme = ChipThemeData(
    backgroundColor: AppThemeTokens.neutral700,
    labelStyle: const TextStyle(
      color: AppThemeTokens.syntaxFunction,
      fontSize: 12,
    ),
    side: const BorderSide(color: AppThemeTokens.borderDefault),
    shape: const StadiumBorder(),
  );

  // ── NavigationBar ────────────────────────────────────────────────
  // neutral800 com indicador ciano dim (12%) — só o item ativo recebe verde.
  static final _navigationBarTheme = NavigationBarThemeData(
    backgroundColor: AppThemeTokens.neutral800,
    indicatorColor: AppThemeTokens.keywordContainerDark,
    iconTheme: WidgetStateProperty.resolveWith(
      (s) => IconThemeData(
        color: s.contains(WidgetState.selected)
            ? AppThemeTokens.syntaxKeyword
            : AppThemeTokens.neutral400,
      ),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (s) => TextStyle(
        color: s.contains(WidgetState.selected)
            ? AppThemeTokens.syntaxKeyword
            : AppThemeTokens.neutral400,
        fontSize: 12,
      ),
    ),
  );

  // ── TabBar ───────────────────────────────────────────────────────
  // Abas de arquivos de editor — aba ativa em verde, inativas em cinza.
  static const _tabBarTheme = TabBarThemeData(
    labelColor: AppThemeTokens.syntaxKeyword,
    unselectedLabelColor: AppThemeTokens.syntaxComment,
    indicatorColor: AppThemeTokens.syntaxKeyword,
  );

  // ── Divider ──────────────────────────────────────────────────────
  // Branco 8% — linhas de separação de painel quase invisíveis.
  static const _dividerTheme = DividerThemeData(
    color: AppThemeTokens.borderDefault,
    thickness: 1,
  );

  // ── Switch ───────────────────────────────────────────────────────
  // Verde quando ativo — feature flag ligado.
  static final _switchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? AppThemeTokens.brandDark
          : AppThemeTokens.neutral400,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? AppThemeTokens.syntaxKeyword
          : AppThemeTokens.neutral700,
    ),
  );

  // ── Checkbox ─────────────────────────────────────────────────────
  // Verde quando selecionado — atividades de seleção múltipla (Somatório).
  static final _checkboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected)
          ? AppThemeTokens.syntaxKeyword
          : Colors.transparent,
    ),
    checkColor: WidgetStateProperty.all(AppThemeTokens.brandDark),
    side: const BorderSide(color: AppThemeTokens.neutral400),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );

  // ── SnackBar ─────────────────────────────────────────────────────
  // neutral700 flutuante — mensagem de log no terminal.
  static const _snackBarTheme = SnackBarThemeData(
    backgroundColor: AppThemeTokens.neutral700,
    contentTextStyle: TextStyle(color: AppThemeTokens.neutral100),
    actionTextColor: AppThemeTokens.syntaxKeyword,
    behavior: SnackBarBehavior.floating,
    shape: StadiumBorder(),
  );

  // ── Badge ────────────────────────────────────────────────────────
  // Roxo (syntaxNumber) — valores numéricos como XP e pontos.
  static const _badgeTheme = BadgeThemeData(
    backgroundColor: AppThemeTokens.syntaxNumber,
    textColor: AppThemeTokens.brandDark,
  );
}
