abstract class AdminReportEvent {
  const AdminReportEvent();
}

class LoadAdminReportRequested extends AdminReportEvent {
  const LoadAdminReportRequested({required this.period, this.from, this.to});
  final String period;
  final String? from;
  final String? to;
}
