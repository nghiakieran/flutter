class AdminOrderItem {
  const AdminOrderItem({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.total,
    required this.receiverName,
    required this.createdAt,
  });

  final int id;
  final String orderCode;
  final String status;
  final double total;
  final String receiverName;
  final DateTime createdAt;

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    return AdminOrderItem(
      id: _asInt(json['id']),
      orderCode: json['orderCode']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      total: _asDouble(json['total']),
      receiverName: json['receiverName']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class AdminOrderPage {
  const AdminOrderPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<AdminOrderItem> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
}
