import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightTheme {
  // ── Dark Botanical Palette ─────────────────────────────────────────────────
  //
  // Regola d'oro: il verde saturo appare SOLO negli elementi interattivi
  // (accent, sage, bordi sottili). Sfondi e surface sono neutri quasi-neri
  // con una tinta forest appena percettibile.
  //
  // Risultato visivo: app botanica premium, non terminale Matrix.

  // ── Brand ─────────────────────────────────────────────────────────────────


  static const primary = Color(0xFF0A4028);

  // ── Canvas & Surface ──────────────────────────────────────────────────────
  // Desaturati intenzionalmente: la tinta verde è < 5% sul cerchio colori.
  // Questo crea profondità senza monotonicità.

  /// Sfondo principale — nero caldo con appena una tinta foresta.
  static const canvas = Color(0xFF0E1612);

  /// Card principale — grigio carbonio con leggerissima nota verde.
  static const surface1 = Color(0xFF1A1F1C);

  /// Card elevata — un passo più chiaro, per bottom nav e modal.
  static const surface2 = Color(0xFF242B27);

  /// Riempimento input, chip interni — warm-dark slate.
  static const surface3 = Color(0xFF2D3530);

  // ── Accenti verdi — usati SOLO per elementi interattivi e bordi ───────────

  /// Bordi sottili, divisori, anelli — mai come sfondo pieno.
  static const midGreen = Color(0xFF2E5C42);

  /// Verde brillante — CTA, stati attivi, badge salute ottima.
  static const accent = Color(0xFF3DC97A);

  /// Sage desaturato — icone secondarie, label, tag.
  static const sage = Color(0xFF6BAE89);

  // ── Accenti caldi — varietà cromatica botanica ────────────────────────────

  /// Marrone terra — icone cura, badge annaffiatura.
  static const earth = Color(0xFFB87A4E);

  /// Azzurro acqua — indicatori umidità e irrigazione.
  static const water = Color(0xFF5BB8E8);

  /// Ambra — avvisi cura, promemoria.
  static const amber = Color(0xFFE8A94A);

  /// Rosso — salute critica, errori.
  static const danger = Color(0xFFE05252);

  // ── Testo ─────────────────────────────────────────────────────────────────

  /// Ivory caldo — testo primario. Mai bianco puro.
  static const textPrimary = Color(0xFFF0EDE8);

  /// Grigio slate caldo — label secondarie, metadati.
  static const textSecondary = Color(0xFF9AA89F);

  /// Grigio muted — placeholder, hint, testo disabilitato.
  static const textMuted = Color(0xFF5C6862);

  // ── Legacy aliases ─────────────────────────────────────────────────────────
  static const primaryLight = midGreen;
  static const deepForest = Color(0xFF0A2016);
  static const moss = Color(0xFF1A4D30);
  static const sand = Color(0xFFE5D6BF);
  static const clay = earth;
  static const mist = canvas;
  static const mintTint = surface3;
  static const seed = Color(0xFF2A6B48);

  // ── Theme ──────────────────────────────────────────────────────────────────

  static ThemeData get make {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      primary: accent,
      secondary: sage,
      surface: surface1,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      brightness: Brightness.dark,
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
          fontSize: 28,
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
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: midGreen.withOpacity(0.18)),
        ),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: midGreen.withOpacity(0.16),
        thickness: 1,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surface2,
        contentTextStyle: GoogleFonts.sora(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: midGreen.withOpacity(0.25)),
        ),
      ),

      // ── ElevatedButton ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: accent,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          foregroundColor: accent,
          side: BorderSide(color: accent.withOpacity(0.35)),
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
          foregroundColor: sage,
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
        prefixIconColor: sage,
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
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: midGreen.withOpacity(0.22)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: midGreen.withOpacity(0.22)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: accent, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: danger, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: danger, width: 1.8),
        ),
      ),
    );
  }
}
