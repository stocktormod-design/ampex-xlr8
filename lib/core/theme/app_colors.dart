import 'package:flutter/cupertino.dart';

/// Ampex design tokens – farger (én sannhet for iOS, Android og web).
///
/// Retning: Spotify Dark Mode, minimal og monokrom.
abstract final class AppColors {
  // ── Bakgrunn (Dyp mørk) ─────────────────────────────────────────────────────
  static const background = Color(0xFF0F0F10);

  /// Overflate nivå 1 (kort, grouped sections)
  static const surface = Color(0xFF18181A);

  /// Overflate nivå 2 (tab bar, nav bar, quick tiles)
  static const surfaceElevated = Color(0xFF202124);

  /// Overflate nivå 3 (felt)
  static const surfaceHighlight = Color(0xFF2A2B30);

  // ── Tekst (Høy kontrast) ───────────────────────────────────────────────────
  static const label = Color(0xFFFFFFFF);
  static const labelSecondary = Color(0xFFB1B1B3);
  static const labelTertiary = Color(0xFF7D7D81);
  static const labelPlaceholder = Color(0xFF5D5D61);

  // ── Accent (Én tydelig handling) ────────────────────────────────────────────
  /// Eneste accent: Spotify-grønn.
  static const accent = Color(0xFF1DB954);
  static const accentSoft = Color(0x261DB954);

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D66B), accent],
  );

  // ── Semantiske ─────────────────────────────────────────────────────────────
  static const destructive = Color(0xFFE5484D);
  static const success = Color(0xFF1DB954);
  static const warning = Color(0xFFFFA42B);

  // ── Skillelinjer (Svært subtile i dark mode) ───────────────────────────────
  static const separator = Color(0x20FFFFFF);
  static const separatorOpaque = Color(0xFF2A2A2A);

  // ── Interaktive states ────────────────────────────────────────────────────
  static const pressed = Color(0x1AFFFFFF);
  static const selected = Color(0x1A1DB954);

  // ── Glassflater (Tilpasset mørk modus) ──────────────────────────────────────
  static const glassSurface = Color(0xD918181A);
  static const glassBar = Color(0xE60F0F10);
  static const glassBorder = Color(0x26FFFFFF);

  // ── Bakteppe (diskret, nesten flat) ────────────────────────────────────────
  static const LinearGradient backdropGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF161618), Color(0xFF0F0F10)],
  );
}
