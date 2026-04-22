abstract class AdminCouponEvent {
  const AdminCouponEvent();
}

class LoadAdminCouponsRequested extends AdminCouponEvent {
  const LoadAdminCouponsRequested({this.search, this.page, this.limit});
  final String? search;
  final int? page;
  final int? limit;
}

class CreateAdminCouponRequested extends AdminCouponEvent {
  const CreateAdminCouponRequested({
    required this.code,
    required this.type,
    required this.value,
    required this.minOrderValue,
    this.maxDiscountValue,
    required this.startDateIso,
    required this.endDateIso,
    required this.usageLimit,
    required this.isActive,
  });

  final String code;
  final String type;
  final double value;
  final double minOrderValue;
  final double? maxDiscountValue;
  final String startDateIso;
  final String endDateIso;
  final int usageLimit;
  final bool isActive;
}

class UpdateAdminCouponRequested extends AdminCouponEvent {
  const UpdateAdminCouponRequested({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minOrderValue,
    this.maxDiscountValue,
    required this.startDateIso,
    required this.endDateIso,
    required this.usageLimit,
    required this.isActive,
  });

  final int id;
  final String code;
  final String type;
  final double value;
  final double minOrderValue;
  final double? maxDiscountValue;
  final String startDateIso;
  final String endDateIso;
  final int usageLimit;
  final bool isActive;
}

class DeleteAdminCouponRequested extends AdminCouponEvent {
  const DeleteAdminCouponRequested(this.id);
  final int id;
}
