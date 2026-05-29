class OrderCustomer {
  const OrderCustomer({
    this.name,
    this.phone,
    this.address,
  });

  final String? name;
  final String? phone;
  final String? address;

  factory OrderCustomer.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const OrderCustomer();
    return OrderCustomer(
      name: (json['name'] as String?)?.trim(),
      phone: (json['phone'] as String?)?.trim(),
      address: (json['address'] as String?)?.trim(),
    );
  }
}

/// Ordre fra `public.orders` (+ kunde via `order_customers`).
class Order {
  const Order({
    required this.id,
    required this.title,
    required this.status,
    this.type,
    this.description,
    required this.updatedAt,
    this.createdAt,
    this.customer = const OrderCustomer(),
    this.archiveReference,
  });

  final String id;
  final String title;
  final String status;
  final String? type;
  final String? description;
  final DateTime updatedAt;
  final DateTime? createdAt;
  final OrderCustomer customer;
  final String? archiveReference;

  String get displayTitle {
    final t = title.trim();
    if (t.isNotEmpty) return t;
    final name = customer.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Ordre uten tittel';
  }

  String? get subtitle {
    final addr = customer.address?.trim();
    if (addr != null && addr.isNotEmpty) return addr;
    return customer.phone?.trim();
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final customerRaw = json['order_customers'];
    return Order(
      id: json['id'] as String,
      title: (json['title'] as String?)?.trim() ?? '',
      status: json['status'] as String,
      type: json['type'] as String?,
      description: (json['description'] as String?)?.trim(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      customer: OrderCustomer.fromJson(
        customerRaw is Map<String, dynamic> ? customerRaw : null,
      ),
      archiveReference: (json['archive_reference'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'status': status,
        'type': type,
        'description': description,
        'updated_at': updatedAt.toUtc().toIso8601String(),
        if (createdAt != null)
          'created_at': createdAt!.toUtc().toIso8601String(),
        'archive_reference': archiveReference,
        'order_customers': {
          'name': customer.name,
          'phone': customer.phone,
          'address': customer.address,
        },
      };
}
