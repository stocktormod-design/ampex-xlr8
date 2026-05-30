import 'dart:convert';
import 'dart:ui';

/// Normalisert punkt på en PDF-side (0–1).
class MarkupNorm {
  const MarkupNorm({
    required this.page,
    required this.x,
    required this.y,
  });

  final int page;
  final double x;
  final double y;

  Offset get asOffset => Offset(x, y);

  Map<String, dynamic> toJson() => {'page': page, 'x': x, 'y': y};

  factory MarkupNorm.fromJson(Map<String, dynamic> json) => MarkupNorm(
        page: json['page'] as int,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
      );
}

sealed class MarkupElement {
  const MarkupElement({required this.id, required this.page});

  final String id;
  final int page;

  Map<String, dynamic> toJson();
  static MarkupElement fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'detector' => MarkupDetector.fromJson(json),
      'point' => MarkupPoint.fromJson(json),
      'line' => MarkupLine.fromJson(json),
      'text' => MarkupText.fromJson(json),
      'room' => MarkupRoom.fromJson(json),
      _ => throw FormatException('Ukjent markuptype: ${json['type']}'),
    };
  }
}

/// Monteringsstatus for detektor (sokkel / kappe / serienr).
class MarkupDetectorStatus {
  const MarkupDetectorStatus({
    this.sokkelMontert = false,
    this.detektorMontert = false,
    this.serienummer,
    this.tagnummer,
    this.kappeAv,
    this.scanImagePath,
  });

  final bool sokkelMontert;
  final bool detektorMontert;
  final String? serienummer;
  final String? tagnummer;
  final bool? kappeAv;
  final String? scanImagePath;

  MarkupDetectorStatus copyWith({
    bool? sokkelMontert,
    bool? detektorMontert,
    String? serienummer,
    String? tagnummer,
    bool? kappeAv,
    String? scanImagePath,
  }) =>
      MarkupDetectorStatus(
        sokkelMontert: sokkelMontert ?? this.sokkelMontert,
        detektorMontert: detektorMontert ?? this.detektorMontert,
        serienummer: serienummer ?? this.serienummer,
        tagnummer: tagnummer ?? this.tagnummer,
        kappeAv: kappeAv ?? this.kappeAv,
        scanImagePath: scanImagePath ?? this.scanImagePath,
      );

  Map<String, dynamic> toJson() => {
        'sokkelMontert': sokkelMontert,
        'detektorMontert': detektorMontert,
        if (serienummer != null) 'serienummer': serienummer,
        if (tagnummer != null) 'tagnummer': tagnummer,
        if (kappeAv != null) 'kappeAv': kappeAv,
        if (scanImagePath != null) 'scanImagePath': scanImagePath,
      };

  factory MarkupDetectorStatus.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MarkupDetectorStatus();
    return MarkupDetectorStatus(
      sokkelMontert: json['sokkelMontert'] as bool? ?? false,
      detektorMontert: json['detektorMontert'] as bool? ?? false,
      serienummer: json['serienummer'] as String?,
      tagnummer: json['tagnummer'] as String?,
      kappeAv: json['kappeAv'] as bool?,
      scanImagePath: json['scanImagePath'] as String?,
    );
  }
}

class MarkupDetector extends MarkupElement {
  const MarkupDetector({
    required super.id,
    required super.page,
    required this.x,
    required this.y,
    this.label,
    this.status = const MarkupDetectorStatus(),
  });

  final double x;
  final double y;
  final String? label;
  final MarkupDetectorStatus status;

  MarkupNorm get norm => MarkupNorm(page: page, x: x, y: y);

  MarkupDetector copyWith({MarkupDetectorStatus? status, String? label}) =>
      MarkupDetector(
        id: id,
        page: page,
        x: x,
        y: y,
        label: label ?? this.label,
        status: status ?? this.status,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'detector',
        'id': id,
        'page': page,
        'x': x,
        'y': y,
        if (label != null) 'label': label,
        'status': status.toJson(),
      };

  factory MarkupDetector.fromJson(Map<String, dynamic> json) => MarkupDetector(
        id: json['id'] as String,
        page: json['page'] as int,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        label: json['label'] as String?,
        status: MarkupDetectorStatus.fromJson(
          json['status'] as Map<String, dynamic>?,
        ),
      );
}

class MarkupPoint extends MarkupElement {
  const MarkupPoint({
    required super.id,
    required super.page,
    required this.x,
    required this.y,
  });

  final double x;
  final double y;

  MarkupNorm get norm => MarkupNorm(page: page, x: x, y: y);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'point',
        'id': id,
        'page': page,
        'x': x,
        'y': y,
      };

  factory MarkupPoint.fromJson(Map<String, dynamic> json) => MarkupPoint(
        id: json['id'] as String,
        page: json['page'] as int,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
      );
}

class MarkupLine extends MarkupElement {
  const MarkupLine({
    required super.id,
    required super.page,
    this.startId,
    this.endId,
    this.startX,
    this.startY,
    this.endX,
    this.endY,
  });

  final String? startId;
  final String? endId;
  final double? startX;
  final double? startY;
  final double? endX;
  final double? endY;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'line',
        'id': id,
        'page': page,
        if (startId != null) 'startId': startId,
        if (endId != null) 'endId': endId,
        if (startX != null) 'startX': startX,
        if (startY != null) 'startY': startY,
        if (endX != null) 'endX': endX,
        if (endY != null) 'endY': endY,
      };

  factory MarkupLine.fromJson(Map<String, dynamic> json) => MarkupLine(
        id: json['id'] as String,
        page: json['page'] as int,
        startId: json['startId'] as String?,
        endId: json['endId'] as String?,
        startX: (json['startX'] as num?)?.toDouble(),
        startY: (json['startY'] as num?)?.toDouble(),
        endX: (json['endX'] as num?)?.toDouble(),
        endY: (json['endY'] as num?)?.toDouble(),
      );
}

class MarkupText extends MarkupElement {
  const MarkupText({
    required super.id,
    required super.page,
    required this.x,
    required this.y,
    required this.text,
  });

  final double x;
  final double y;
  final String text;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'text',
        'id': id,
        'page': page,
        'x': x,
        'y': y,
        'text': text,
      };

  factory MarkupText.fromJson(Map<String, dynamic> json) => MarkupText(
        id: json['id'] as String,
        page: json['page'] as int,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        text: json['text'] as String,
      );
}

/// Fremdrift per fag (0–100 %) for et rom.
class MarkupRoomProgress {
  const MarkupRoomProgress({
    this.sterkstrom = 0,
    this.svakstrom = 0,
    this.automasjon = 0,
    this.brann = 0,
  });

  final int sterkstrom;
  final int svakstrom;
  final int automasjon;
  final int brann;

  MarkupRoomProgress copyWith({
    int? sterkstrom,
    int? svakstrom,
    int? automasjon,
    int? brann,
  }) =>
      MarkupRoomProgress(
        sterkstrom: sterkstrom ?? this.sterkstrom,
        svakstrom: svakstrom ?? this.svakstrom,
        automasjon: automasjon ?? this.automasjon,
        brann: brann ?? this.brann,
      );

  Map<String, dynamic> toJson() => {
        'sterkstrom': sterkstrom,
        'svakstrom': svakstrom,
        'automasjon': automasjon,
        'brann': brann,
      };

  factory MarkupRoomProgress.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MarkupRoomProgress();
    return MarkupRoomProgress(
      sterkstrom: json['sterkstrom'] as int? ?? 0,
      svakstrom: json['svakstrom'] as int? ?? 0,
      automasjon: json['automasjon'] as int? ?? 0,
      brann: json['brann'] as int? ?? 0,
    );
  }
}

/// Monteringsstatus for et rom (feltregistrering).
class MarkupRoomStatus {
  const MarkupRoomStatus({
    this.sokkelMontert = false,
    this.detektorMontert = false,
    this.serienummer,
    this.tagnummer,
    this.kappeAv,
    this.scanImagePath,
  });

  final bool sokkelMontert;
  final bool detektorMontert;
  final String? serienummer;
  final String? tagnummer;

  /// `true` = kappe av, `false` = kappe på, `null` = ikke registrert.
  final bool? kappeAv;
  final String? scanImagePath;

  MarkupRoomStatus copyWith({
    bool? sokkelMontert,
    bool? detektorMontert,
    String? serienummer,
    String? tagnummer,
    bool? kappeAv,
    String? scanImagePath,
  }) =>
      MarkupRoomStatus(
        sokkelMontert: sokkelMontert ?? this.sokkelMontert,
        detektorMontert: detektorMontert ?? this.detektorMontert,
        serienummer: serienummer ?? this.serienummer,
        tagnummer: tagnummer ?? this.tagnummer,
        kappeAv: kappeAv ?? this.kappeAv,
        scanImagePath: scanImagePath ?? this.scanImagePath,
      );

  Map<String, dynamic> toJson() => {
        'sokkelMontert': sokkelMontert,
        'detektorMontert': detektorMontert,
        if (serienummer != null) 'serienummer': serienummer,
        if (tagnummer != null) 'tagnummer': tagnummer,
        if (kappeAv != null) 'kappeAv': kappeAv,
        if (scanImagePath != null) 'scanImagePath': scanImagePath,
      };

  factory MarkupRoomStatus.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MarkupRoomStatus();
    return MarkupRoomStatus(
      sokkelMontert: json['sokkelMontert'] as bool? ?? false,
      detektorMontert: json['detektorMontert'] as bool? ?? false,
      serienummer: json['serienummer'] as String?,
      tagnummer: json['tagnummer'] as String?,
      kappeAv: json['kappeAv'] as bool?,
      scanImagePath: json['scanImagePath'] as String?,
    );
  }
}

class MarkupRoom extends MarkupElement {
  const MarkupRoom({
    required super.id,
    required super.page,
    required this.vertices,
    this.name,
    this.status = const MarkupRoomStatus(),
    this.progress = const MarkupRoomProgress(),
    this.lidarRequestedAt,
  });

  final List<MarkupNorm> vertices;
  final String? name;
  final MarkupRoomStatus status;
  final MarkupRoomProgress progress;
  final DateTime? lidarRequestedAt;

  @override
  Map<String, dynamic> toJson() => {
        'type': 'room',
        'id': id,
        'page': page,
        'vertices': vertices.map((v) => v.toJson()).toList(),
        if (name != null) 'name': name,
        'status': status.toJson(),
        'progress': progress.toJson(),
        if (lidarRequestedAt != null)
          'lidarRequestedAt': lidarRequestedAt!.toIso8601String(),
      };

  factory MarkupRoom.fromJson(Map<String, dynamic> json) => MarkupRoom(
        id: json['id'] as String,
        page: json['page'] as int,
        vertices: (json['vertices'] as List)
            .map((e) => MarkupNorm.fromJson(e as Map<String, dynamic>))
            .toList(),
        name: json['name'] as String?,
        status: MarkupRoomStatus.fromJson(
          json['status'] as Map<String, dynamic>?,
        ),
        progress: MarkupRoomProgress.fromJson(
          json['progress'] as Map<String, dynamic>?,
        ),
        lidarRequestedAt: json['lidarRequestedAt'] != null
            ? DateTime.tryParse(json['lidarRequestedAt'] as String)
            : null,
      );

  MarkupRoom copyWith({
    String? name,
    MarkupRoomStatus? status,
    MarkupRoomProgress? progress,
    List<MarkupNorm>? vertices,
    DateTime? lidarRequestedAt,
  }) =>
      MarkupRoom(
        id: id,
        page: page,
        vertices: vertices ?? this.vertices,
        name: name ?? this.name,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        lidarRequestedAt: lidarRequestedAt ?? this.lidarRequestedAt,
      );
}

class DrawingMarkupDocument {
  const DrawingMarkupDocument({
    required this.drawingId,
    required this.elements,
    this.revision = 0,
    this.publishedRevision = 0,
    this.publishedAt,
  });

  final String drawingId;
  final List<MarkupElement> elements;
  final int revision;
  final int publishedRevision;
  final DateTime? publishedAt;

  bool get hasUnpublishedChanges => revision > publishedRevision;

  int get unpublishedChangeCount => revision - publishedRevision;

  List<MarkupDetector> get detectors =>
      elements.whereType<MarkupDetector>().toList();

  DrawingMarkupDocument copyWith({
    List<MarkupElement>? elements,
    int? revision,
    int? publishedRevision,
    DateTime? publishedAt,
  }) {
    return DrawingMarkupDocument(
      drawingId: drawingId,
      elements: elements ?? this.elements,
      revision: revision ?? this.revision,
      publishedRevision: publishedRevision ?? this.publishedRevision,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'drawingId': drawingId,
        'revision': revision,
        'publishedRevision': publishedRevision,
        if (publishedAt != null) 'publishedAt': publishedAt!.toIso8601String(),
        'elements': elements.map((e) => e.toJson()).toList(),
      };

  factory DrawingMarkupDocument.fromJson(Map<String, dynamic> json) {
    return DrawingMarkupDocument(
      drawingId: json['drawingId'] as String,
      revision: json['revision'] as int? ?? 0,
      publishedRevision: json['publishedRevision'] as int? ?? 0,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      elements: (json['elements'] as List? ?? [])
          .map((e) => MarkupElement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String encode() => jsonEncode(toJson());

  factory DrawingMarkupDocument.decode(String drawingId, String raw) {
    if (raw.isEmpty) {
      return DrawingMarkupDocument(drawingId: drawingId, elements: []);
    }
    return DrawingMarkupDocument.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }
}
