abstract class AdminUserEvent {
  const AdminUserEvent();
}

class LoadAdminCustomersRequested extends AdminUserEvent {
  const LoadAdminCustomersRequested({this.search, this.page, this.limit});
  final String? search;
  final int? page;
  final int? limit;
}

class LoadAdminStaffsRequested extends AdminUserEvent {
  const LoadAdminStaffsRequested({this.search, this.page, this.limit});
  final String? search;
  final int? page;
  final int? limit;
}

class ToggleCustomerVerifiedRequested extends AdminUserEvent {
  const ToggleCustomerVerifiedRequested({
    required this.userId,
    required this.isVerified,
  });
  final int userId;
  final bool isVerified;
}

class CreateAdminStaffRequested extends AdminUserEvent {
  const CreateAdminStaffRequested({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });
  final String name;
  final String email;
  final String password;
  final String? phone;
}

class UpdateAdminStaffRequested extends AdminUserEvent {
  const UpdateAdminStaffRequested({
    required this.id,
    required this.name,
    this.phone,
    this.isVerified,
  });
  final int id;
  final String name;
  final String? phone;
  final bool? isVerified;
}

class DeleteAdminStaffRequested extends AdminUserEvent {
  const DeleteAdminStaffRequested(this.id);
  final int id;
}
