class DashboardMetricCard {
  const DashboardMetricCard({
    required this.label,
    required this.value,
    required this.delta,
  });

  final String label;
  final double value;
  final double delta;
}

class DashboardOrderStatusMetric {
  const DashboardOrderStatusMetric({required this.status, required this.count});

  final String status;
  final int count;
}

class AdminDashboardSummary {
  const AdminDashboardSummary({
    required this.todayRevenue,
    required this.monthRevenue,
    required this.yearRevenue,
    required this.totalUsers,
    required this.orderByStatus,
  });

  final DashboardMetricCard todayRevenue;
  final DashboardMetricCard monthRevenue;
  final DashboardMetricCard yearRevenue;
  final int totalUsers;
  final List<DashboardOrderStatusMetric> orderByStatus;

  factory AdminDashboardSummary.fromJson(Map<String, dynamic> json) {
    final revenue = _asMap(json['revenue']);
    final ordersByStatus = json['ordersByStatus'];

    return AdminDashboardSummary(
      todayRevenue: _parseMetricCard(
        revenue['day'],
        fallbackLabel: 'Revenue (Day)',
      ),
      monthRevenue: _parseMetricCard(
        revenue['month'],
        fallbackLabel: 'Revenue (Month)',
      ),
      yearRevenue: _parseMetricCard(
        revenue['year'],
        fallbackLabel: 'Revenue (Year)',
      ),
      totalUsers: _asInt(json['totalUsers']),
      orderByStatus: ordersByStatus is List
          ? ordersByStatus
                .whereType<Map<String, dynamic>>()
                .map(
                  (item) => DashboardOrderStatusMetric(
                    status: item['status']?.toString() ?? 'unknown',
                    count: _asInt(item['count']),
                  ),
                )
                .toList()
          : <DashboardOrderStatusMetric>[],
    );
  }

  static DashboardMetricCard _parseMetricCard(
    dynamic raw, {
    required String fallbackLabel,
  }) {
    final metricMap = _asMap(raw);
    return DashboardMetricCard(
      label: metricMap['label']?.toString() ?? fallbackLabel,
      value: _asDouble(metricMap['value']),
      delta: _asDouble(metricMap['delta']),
    );
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
