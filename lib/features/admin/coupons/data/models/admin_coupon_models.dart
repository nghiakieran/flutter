class AdminCoupon {
  const AdminCoupon({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minOrderValue,
    this.maxDiscountValue,
    required this.startDate,
    required this.endDate,
    required this.usageLimit,
    required this.isActive,
    this.createdAt,
  });

  final int id;
  final String code;
  final String type;
  final double value;
  final double minOrderValue;
  final double? maxDiscountValue;
  final DateTime startDate;
  final DateTime endDate;
  final int usageLimit;
  final bool isActive;
  final DateTime? createdAt;

  factory AdminCoupon.fromJson(Map<String, dynamic> json) {
    return AdminCoupon(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? 'PERCENT',
      value: double.tryParse(json['value']?.toString() ?? '') ?? 0,
      minOrderValue:
          double.tryParse(json['minOrderValue']?.toString() ?? '') ?? 0,
      maxDiscountValue: json['maxDiscountValue'] == null
          ? null
          : double.tryParse(json['maxDiscountValue']?.toString() ?? ''),
      startDate:
          DateTime.tryParse(json['startDate']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endDate:
          DateTime.tryParse(json['endDate']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      usageLimit: int.tryParse(json['usageLimit']?.toString() ?? '') ?? 0,
      isActive: json['isActive'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class AdminCouponPage {
  const AdminCouponPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<AdminCoupon> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
}
