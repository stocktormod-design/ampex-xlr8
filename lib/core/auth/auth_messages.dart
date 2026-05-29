import 'package:supabase_flutter/supabase_flutter.dart';

/// Oversetter vanlige Supabase Auth-feil til norsk.
String authErrorMessageNorwegian(Object error) {
  if (error is AuthException) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials')) {
      return 'Feil e-post eller passord.';
    }
    if (message.contains('email not confirmed')) {
      return 'E-posten er ikke bekreftet ennå.';
    }
    if (message.contains('too many requests')) {
      return 'For mange forsøk. Vent litt og prøv igjen.';
    }
    if (message.contains('network') || message.contains('fetch')) {
      return 'Ingen nettforbindelse. Sjekk tilkoblingen og prøv igjen.';
    }
    return error.message;
  }
  return 'Kunne ikke logge inn. Prøv igjen.';
}
