/// Norske navn på dokumentasjonsmaler (ordre).
String orderDocumentationLabel(String templateType) {
  final key = templateType.trim().toLowerCase();
  return switch (key) {
    'risk_assessment' || 'risk' => 'Risikovurdering',
    'compliance' || 'samsvar' => 'Samsvarserklæring',
    'final_inspection' || 'sluttkontroll' => 'Sluttkontroll',
    'course_register' || 'kursfortegnelse' => 'Kursfortegnelse',
    'equipment' || 'utstyr' => 'Utstyrsdokumentasjon',
    _ => _humanize(templateType),
  };
}

String _humanize(String raw) {
  if (raw.isEmpty) return 'Dokumentasjon';
  return raw
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
