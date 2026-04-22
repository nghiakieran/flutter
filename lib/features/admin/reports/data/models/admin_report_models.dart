class AdminReportTotals {
  const AdminReportTotals({
    required this.revenue,
    required this.orders,
    required this.users,
    required this.aov,
  });

  final double revenue;
  final int orders;
  final int users;
  final double aov;

  factory AdminReportTotals.fromJson(Map<String, dynamic> json) {
    return AdminReportTotals(
      revenue: double.tryParse(json['revenue']?.toString() ?? '') ?? 0,
      orders: int.tryParse(json['orders']?.toString() ?? '') ?? 0,
      users: int.tryParse(json['users']?.toString() ?? '') ?? 0,
      aov: double.tryParse(json['aov']?.toString() ?? '') ?? 0,
    );
  }
}

class AdminReportStatusItem {
  const AdminReportStatusItem({required this.status, required this.count});
  final String status;
  final int count;

  factory AdminReportStatusItem.fromJson(Map<String, dynamic> json) {
    return AdminReportStatusItem(
      status: json['status']?.toString() ?? '',
      count: int.tryParse(json['count']?.toString() ?? '') ?? 0,
    );
  }
}

class AdminReportTopProduct {
  const AdminReportTopProduct({
    required this.productId,
    required this.name,
    required this.soldQty,
  });

  final int productId;
  final String name;
  final int soldQty;

  factory AdminReportTopProduct.fromJson(Map<String, dynamic> json) {
    return AdminReportTopProduct(
      productId: int.tryParse(json['productId']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      soldQty: int.tryParse(json['soldQty']?.toString() ?? '') ?? 0,
    );
  }
}

class AdminReportSummary {
  const AdminReportSummary({
    required this.period,
    required this.from,
    required this.to,
    required this.totals,
    required this.statuses,
    required this.topProducts,
  });

  final String period;
  final String from;
  final String to;
  final AdminReportTotals totals;
  final List<AdminReportStatusItem> statuses;
  final List<AdminReportTopProduct> topProducts;

  factory AdminReportSummary.fromJson(Map<String, dynamic> json) {
    final totalsMap = json['totals'] is Map<String, dynamic>
        ? json['totals'] as Map<String, dynamic>
        : <String, dynamic>{};
    final statusesRaw = json['statuses'] is List
        ? json['statuses'] as List
        : const [];
    final topRaw = json['topProducts'] is List
        ? json['topProducts'] as List
        : const [];
    return AdminReportSummary(
      period: json['period']?.toString() ?? 'month',
      from: json['from']?.toString() ?? '',
      to: json['to']?.toString() ?? '',
      totals: AdminReportTotals.fromJson(totalsMap),
      statuses: statusesRaw
          .whereType<Map<String, dynamic>>()
          .map(AdminReportStatusItem.fromJson)
          .toList(),
      topProducts: topRaw
          .whereType<Map<String, dynamic>>()
          .map(AdminReportTopProduct.fromJson)
          .toList(),
    );
  }
}
