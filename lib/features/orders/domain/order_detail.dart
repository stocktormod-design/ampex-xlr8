import 'order.dart';

/// Full ordredetalj med relaterte registreringer (fase 1 – lesing).
class OrderDetail {
  const OrderDetail({
    required this.order,
    this.assignedInstallerName,
    this.hours = const [],
    this.materials = const [],
    this.documentation = const [],
    this.photos = const [],
  });

  final Order order;
  final String? assignedInstallerName;
  final List<OrderHourEntry> hours;
  final List<OrderMaterialEntry> materials;
  final List<OrderDocumentationEntry> documentation;
  final List<OrderPhotoEntry> photos;

  int get totalMinutes => hours.fold(0, (sum, h) => sum + h.minutes);

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      order: Order.fromJson(json),
      assignedInstallerName:
          _profileName(json['assigned_installer'] as Map<String, dynamic>?),
      hours: _parseList(json['order_hours'], OrderHourEntry.fromJson),
      materials:
          _parseList(json['order_materials'], OrderMaterialEntry.fromJson),
      documentation: _parseList(
        json['order_documentation'],
        OrderDocumentationEntry.fromJson,
      ),
      photos: _parseList(json['order_photos'], OrderPhotoEntry.fromJson),
    );
  }

  Map<String, dynamic> toJson() => {
        ...order.toJson(),
        if (assignedInstallerName != null)
          'assigned_installer': {'full_name': assignedInstallerName},
        'order_hours': hours.map((e) => e.toJson()).toList(),
        'order_materials': materials.map((e) => e.toJson()).toList(),
        'order_documentation':
            documentation.map((e) => e.toJson()).toList(),
        'order_photos': photos.map((e) => e.toJson()).toList(),
      };

  static String? _profileName(Map<String, dynamic>? json) {
    if (json == null) return null;
    final name = (json['full_name'] as String?)?.trim();
    return name != null && name.isNotEmpty ? name : null;
  }

  static List<T> _parseList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! List) return const [];
    return raw
        .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

class OrderHourEntry {
  const OrderHourEntry({
    required this.id,
    required this.workDate,
    required this.minutes,
    this.note,
    this.userName,
  });

  final String id;
  final DateTime workDate;
  final int minutes;
  final String? note;
  final String? userName;

  String get hoursLabel {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}t ${m}min';
    if (h > 0) return '${h}t';
    return '${m}min';
  }

  factory OrderHourEntry.fromJson(Map<String, dynamic> json) {
    return OrderHourEntry(
      id: json['id'] as String,
      workDate: DateTime.parse(json['work_date'] as String),
      minutes: json['minutes'] as int? ?? 0,
      note: (json['note'] as String?)?.trim(),
      userName: OrderDetail._profileName(
        json['profiles'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'work_date': workDate.toIso8601String().split('T').first,
        'minutes': minutes,
        'note': note,
        if (userName != null) 'profiles': {'full_name': userName},
      };
}

class OrderMaterialEntry {
  const OrderMaterialEntry({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit,
    this.note,
  });

  final String id;
  final String name;
  final double quantity;
  final String? unit;
  final String? note;

  String get quantityLabel {
    final q = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    final u = unit?.trim();
    return u != null && u.isNotEmpty ? '$q $u' : q;
  }

  factory OrderMaterialEntry.fromJson(Map<String, dynamic> json) {
    return OrderMaterialEntry(
      id: json['id'] as String,
      name: (json['name'] as String?)?.trim() ?? 'Materiell',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: (json['unit'] as String?)?.trim(),
      note: (json['note'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'note': note,
      };
}

class OrderDocumentationEntry {
  const OrderDocumentationEntry({
    required this.id,
    required this.sectionKey,
    required this.templateType,
    required this.isCompleted,
  });

  final String id;
  final String sectionKey;
  final String templateType;
  final bool isCompleted;

  factory OrderDocumentationEntry.fromJson(Map<String, dynamic> json) {
    return OrderDocumentationEntry(
      id: json['id'] as String,
      sectionKey: (json['section_key'] as String?)?.trim() ?? '',
      templateType: (json['template_type'] as String?)?.trim() ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'section_key': sectionKey,
        'template_type': templateType,
        'is_completed': isCompleted,
      };
}

class OrderPhotoEntry {
  const OrderPhotoEntry({
    required this.id,
    required this.filePath,
    this.caption,
    this.photoType,
    required this.createdAt,
  });

  final String id;
  final String filePath;
  final String? caption;
  final String? photoType;
  final DateTime createdAt;

  factory OrderPhotoEntry.fromJson(Map<String, dynamic> json) {
    return OrderPhotoEntry(
      id: json['id'] as String,
      filePath: json['file_path'] as String,
      caption: (json['caption'] as String?)?.trim(),
      photoType: (json['photo_type'] as String?)?.trim(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'file_path': filePath,
        'caption': caption,
        'photo_type': photoType,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}
