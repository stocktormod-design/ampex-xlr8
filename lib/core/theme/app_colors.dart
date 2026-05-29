import 'package:flutter/cupertino.dart';

/// Ampex design tokens – farger (én sannhet for iOS, Android og web).
///
/// Retning: iOS-struktur + Spotify-aktig glassmorfisme.
/// – Mykt gradient-bakteppe gir dybde bak frostede glassflater.
/// – Glassflater = halvgjennomsiktig hvit + blur + hårfin kant.
/// – Én accent med svak gradient, brukt på primærhandlinger.
abstract final class AppColors {
  // ── Gradient-bakteppe (det glasset «blurrer») ──────────────────────────────
  static const backdropTop = Color(0xFFEEF2FB);
  static const backdropMid = Color(0xFFF4F1FB);
  static const backdropBottom = Color(0xFFEAF3F9);

  /// Fargede «blobs» som gir liv bak glasset.
  static const blobBlue = Color(0x330A66C2);
  static const blobViolet = Color(0x2A7C5CFF);
  static const blobCyan = Color(0x2618B5C9);

  /// Solid fallback-bakgrunn (når blur ikke er ønskelig).
  static const background = Color(0xFFEFF1F8);

  // ── Glassflater ─────────────────────────────────────────────────────────────
  /// Frostet kort/seksjon.
  static const glassSurface = Color(0xCCFFFFFF);

  /// Sterkere glass (nav/tab-bar).
  static const glassBar = Color(0xE6FFFFFF);

  /// Hårfin lyskant øverst på glass.
  static const glassBorder = Color(0x4DFFFFFF);

  /// Solid hvit der vi trenger ugjennomsiktig flate.
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFAFAFC);

  // ── Tekst ──────────────────────────────────────────────────────────────────
  static const label = Color(0xFF14151A);
  static const labelSecondary = Color(0xFF60636E);
  static const labelTertiary = Color(0xFF9CA0AC);
  static const labelPlaceholder = Color(0xFFB8BCC6);

  // ── Accent ───────────────────────────────────────────────────────────────────
  static const accent = Color(0xFF0A66C2);
  static const accentBright = Color(0xFF2E7BD6);
  static const accentSoft = Color(0xFFE6EFFB);

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentBright, accent],
  );

  // ── Semantiske ─────────────────────────────────────────────────────────────
  static const destructive = Color(0xFFE5484D);
  static const success = Color(0xFF2D7A4F);
  static const warning = Color(0xFFE8A317);

  // ── Skillelinjer ──────────────────────────────────────────────────────────
  static const separator = Color(0x14000000);
  static const separatorOpaque = Color(0xFFD8DAE2);

  // ── Interaktive states ────────────────────────────────────────────────────
  static const pressed = Color(0x0F000000);
  static const selected = Color(0x140A66C2);

  // ── Bakteppe-gradient (helper) ──────────────────────────────────────────────
  static const LinearGradient backdropGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backdropTop, backdropMid, backdropBottom],
  );
}
