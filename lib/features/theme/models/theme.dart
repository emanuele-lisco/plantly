import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette Plantly — Botanica Chiara
///
/// Principio: sfondi chiari e caldi, verde botanico come accento principale.
/// Card bianche o avorio. Gerarchia visiva pulita e leggibile.
class LightTheme {
  // ── Sfondi ─────────────────────────────────────────────────────────────────

  /// Scaffold background — verde sage chiaro, quasi bianco.
  static const canvas = Color(0xFFE9EDE0); // Soft sage background

  /// Sfondo caldo alternativo — per pagine auth e profilo.
  static const warmBackground = Color(0xFFF7F3EA);

  /// Surface principale — avorio quasi bianco.
  static const surface1 = Color(0xFFFFFDF7);

  /// Surface elevata — bianco puro per card in primo piano.
  static const surface2 = Color(0xFFFFFFFF);

  /// Input fill, chip — grigio verdino molto chiaro.
  static const surface3 = Color(0xFFF0F4EC);

  // ── Verde botanico ──────────────────────────────────────────────────────────

  /// Verde scuro — CTA principali, header accenti.
  static const primaryDark = Color(0xFF0A4028);

  /// Verde primario — bottoni, badge, accenti principali.
  static const primary = Color(0xFF1F5C3A);

  /// Sage secondario — accenti morbidi, icone secondarie.
  static const sage = Color(0xFFA8BFA3);

  // ── Colori semantici ────────────────────────────────────────────────────────

  /// Azzurro acqua — umidità, irrigazione.
  static const water = Color(0xFF2AAAE0);

  /// Ambra — luce, fioritura, promemoria medi.
  static const amber = Color(0xFFD89A3D);

  /// Terra calda — cura, indoor/outdoor badge.
  static const earth = Color(0xFFB07040);

  /// Corallo soft — avvisi non critici.
  static const coral = Color(0xFFC85A54);

  /// Successo — conferme, salute ottima.
  static const success = Color(0xFF2F7D4F);

  /// Errore — pericolo, tossicità, stati critici.
  static const danger = Color(0xFFC85A54);

  // ── Testo ──────────────────────────────────────────────────────────────────

  /// Testo primario — quasi nero su sfondo chiaro.
  static const textPrimary = Color(0xFF102018);

  /// Testo secondario — grigio-verde medio.
  static const textSecondary = Color(0xFF5F6F66);

  /// Testo muted — placeholder, hint, disabled.
  static const textMuted = Color(0xFF8A948C);

  // ── Bordi ──────────────────────────────────────────────────────────────────

  /// Bordo soft — divisori e contorni card.
  static const border = Color(0xFFE1DED2);

  // ── Legacy aliases (mantenuti per compatibilità riferimenti esistenti) ──────
  static const accent = primary;
  static const midGreen = primary;
  static const moss = primaryDark;
  static const deepForest = primaryDark;
  static const seed = primary;
  static const primaryLight = sage;
  static const sand = Color(0xFFF7F3EA);
  static const clay = earth;
  static const mist = canvas;
  static const mintTint = surface3;

  // ── Gradienti ──────────────────────────────────────────────────────────────

  /// Gradiente hero card — warm botanical.
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F5C3A), Color(0xFF0A4028)],
  );

  /// Gradiente pagina — sfondo leggermente degradante (quasi piatto).
  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE9EDE0), Color(0xFFF7F3EA)],
  );

  /// Gradiente header profilo — sage morbido.
  static const profileGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1F5C3A), Color(0xFF0A4028)],
  );

  // ── Theme ──────────────────────────────────────────────────────────────────

  static ThemeData get make {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: sage,
      surface: surface1,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      brightness: Brightness.light,
    );

    return base.copyWith(
      // ── Testo ─────────────────────────────────────────────────────────────
      textTheme: GoogleFonts.soraTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.sora(
          fontSize: 38,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.sora(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.sora(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.sora(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.sora(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.sora(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.sora(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.55,
        ),
        bodyMedium: GoogleFonts.sora(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.45,
        ),
        bodySmall: GoogleFonts.sora(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        labelMedium: GoogleFonts.sora(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.sora(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textMuted,
        ),
      ),

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surface1,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border),
        ),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryDark,
        contentTextStyle: GoogleFonts.sora(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── ElevatedButton ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),

      // ── FilledButton ──────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          foregroundColor: primary,
          side: const BorderSide(color: border, width: 1.5),
          textStyle: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // ── TextButton ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // ── Input ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: GoogleFonts.sora(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.sora(
          color: textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        prefixIconColor: primary,
        suffixIconColor: textSecondary,
        errorStyle: GoogleFonts.sora(
          color: danger,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 1.8),
        ),
      ),
    );
  }
}