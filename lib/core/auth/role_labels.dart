/// Norske visningsnavn for [app_role] fra Supabase.
String roleLabelNorwegian(String role) {
  switch (role) {
    case 'admin':
      return 'Admin';
    case 'prosjektleder':
      return 'Prosjektleder';
    case 'montor':
      return 'Montør';
    case 'installator':
      return 'Installatør';
    case 'owner':
      return 'Eier';
    case 'apprentice':
      return 'Lærling';
    case 'baas':
      return 'Bas';
    case 'regnskapsforer':
      return 'Regnskapsfører';
    case 'member':
      return 'Medlem';
    default:
      return role;
  }
}
