import 'package:flutter/cupertino.dart';

/// Ampex design tokens – farger (én sannhet for iOS, Android og web).
///
/// Retning: Spotify Dark Mode. Ekte premium og seamless.
/// – Kullsvart bakgrunn for dybde (`#000000` eller `#121212`).
/// – Rene, svake overflater uten unødvendige kanter og farge-blobs.
/// – Én tydelig accent-farge (Spotify-grønn/Ampex-blå), alt annet er nøytralt.
abstract final class AppColors {
  // ── Bakgrunn (Dyp mørk) ─────────────────────────────────────────────────────
  /// Hovedbakgrunn (Helt svart for OLED-skjermer gir ekstrem dybde)
  static const background = Color(0xFF121212); // Spotify hovedbakgrunn

  /// Overflate nivå 1 (Kort, grouped sections)
  static const surface = Color(0xFF181818); // Spotify overflate

  /// Overflate nivå 2 (Tab bar, nav bar, quick tiles)
  static const surfaceElevated = Color(0xFF282828); // Enda litt lysere
  
  /// Overflate nivå 3 (Søkefelt, myke knapper)
  static const surfaceHighlight = Color(0xFF333333);

  // ── Tekst (Høy kontrast) ───────────────────────────────────────────────────
  static const label = Color(0xFFFFFFFF);
  static const labelSecondary = Color(0xFFA7A7A7); // Spotify grå
  static const labelTertiary = Color(0xFF727272);
  static const labelPlaceholder = Color(0xFF535353);

  // ── Accent (Én tydelig handling) ────────────────────────────────────────────
  /// Vi bruker en premium "elektrisk blå" som føles ren i dark mode.
  static const accent = Color(0xFF3377FF); 
  static const accentSoft = Color(0x263377FF);

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4D8CFF), accent],
  );

  // ── Semantiske ─────────────────────────────────────────────────────────────
  static const destructive = Color(0xFFE91429); // Skarpere rød
  static const success = Color(0xFF1ED760); // Spotify-grønn
  static const warning = Color(0xFFFFA42B);

  // ── Skillelinjer (Svært subtile i dark mode) ───────────────────────────────
  static const separator = Color(0x1AFFFFFF); // Veldig svak hvit
  static const separatorOpaque = Color(0xFF2A2A2A);

  // ── Interaktive states ────────────────────────────────────────────────────
  static const pressed = Color(0x1AFFFFFF);
  static const selected = Color(0x1A3377FF);

  // ── Glassflater (Tilpasset mørk modus) ──────────────────────────────────────
  static const glassSurface = Color(0xFF181818); // Fast overflate i dark mode (ikke frostet for bedre ytelse og Spotify-look)
  static const glassBar = Color(0xF2121212); // Kraftig frostet Spotify-bar
  static const glassBorder = Color(0x1AFFFFFF); // Veldig svak hvit kant
  
  // ── Bakteppe-gradient (helper for hero/login skjermer) ─────────────────────────
  static const LinearGradient backdropGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF282828), Color(0xFF121212)],
  );
}
