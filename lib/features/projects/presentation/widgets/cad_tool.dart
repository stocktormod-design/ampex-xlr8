/// Verktøy i tegningsviseren.
enum CadTool {
  pan,
  select,
  line,
  point,
  detector,
  text,
  room,
}

extension CadToolX on CadTool {
  String get label => switch (this) {
        CadTool.pan => 'Panorer',
        CadTool.select => 'Velg',
        CadTool.line => 'Linje',
        CadTool.point => 'Punkt',
        CadTool.detector => 'Detektor',
        CadTool.text => 'Tekst',
        CadTool.room => 'Rom',
      };

  String get hint => switch (this) {
        CadTool.pan =>
          'Dra for å flytte. Knip med to fingre for zoom. Hold rom/detektor for status.',
        CadTool.select =>
          'Trykk for å velge. Slett eller publiser valgte nedenfor.',
        CadTool.line =>
          'Kjed: trykk detektor → neste detektor lukker sløyfe. Ellers kjed videre.',
        CadTool.point => 'Trykk for å plassere punkt.',
        CadTool.detector => 'Trykk for detektorplassering.',
        CadTool.text => 'Trykk der teksten skal stå.',
        CadTool.room =>
          '90° hjørner. Trykk ✓ ved siste punkt. Hold inne ferdig rom for status.',
      };

  bool get capturesGestures => this != CadTool.pan;
}
