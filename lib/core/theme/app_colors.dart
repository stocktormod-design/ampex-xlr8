import 'package:flutter/cupertino.dart';

/// Ampex design tokens – farger.
///
/// Inspirert av iOS HIG, Spotify og Airbnb:
/// – nøytral grå bakgrunn (aldri hvit flate overalt)
/// – én accent, brukt sparsomt
/// – ingen gradients, ingen tunge skygger
abstract final class AppColors {
  // ── Bakgrunn ───────────────────────────────────────────────────────────────
  /// Primær sidebakgrunn (iOS grouped background / ~Spotify dark surface ekvivalent i lys)
  static const background = Color(0xFFF2F2F7);

  /// Kortoverflate / grouped section
  static const surface = Color(0xFFFFFFFF);

  /// Nedsenket overflate (tab bar, navigation bar)
  static const surfaceElevated = Color(0xFFFAFAFC);

  // ── Tekst ──────────────────────────────────────────────────────────────────
  static const label = Color(0xFF0D0D0D);
  static const labelSecondary = Color(0xFF6B6B70);
  static const labelTertiary = Color(0xFFAEAEB2);
  static const labelPlaceholder = Color(0xFFC7C7CC);

  // ── Accent (brukes sparsomt: knapper, aktiv tab, lenker) ──────────────────
  /// Ampex primær – blå med karakter, ikke rå iOS #007AFF
  static const accent = Color(0xFF0A66C2);
  static const accentSoft = Color(0xFFE8F0FB);

  // ── Semantiske ─────────────────────────────────────────────────────────────
  static const destructive = Color(0xFFD93025);
  static const success = Color(0xFF1E8A4C);
  static const warning = Color(0xFFF59E0B);

  // ── Skillelinjer ──────────────────────────────────────────────────────────
  static const separator = Color(0xFFE5E5EA);
  static const separatorOpaque = Color(0xFFD1D1D6);

  // ── Interaktive states ────────────────────────────────────────────────────
  static const pressed = Color(0x14000000);
  static const selected = Color(0xFFE8F0FB);
}
