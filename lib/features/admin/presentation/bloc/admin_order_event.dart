abstract class AdminOrderEvent {
  const AdminOrderEvent();
}

class LoadAdminOrdersRequested extends AdminOrderEvent {
  const LoadAdminOrdersRequested({
    this.status,
    this.search,
    this.page,
    this.limit,
  });

  final String? status;
  final String? search;
  final int? page;
  final int? limit;
}

class UpdateAdminOrderStatusRequested extends AdminOrderEvent {
  const UpdateAdminOrderStatusRequested({
    required this.orderId,
    required this.status,
  });

  final int orderId;
  final String status;
}
