abstract class AdminProductEvent {
  const AdminProductEvent();
}

class LoadAdminProductsRequested extends AdminProductEvent {
  const LoadAdminProductsRequested({this.search, this.page, this.limit});
  final String? search;
  final int? page;
  final int? limit;
}

class LoadAdminBrandsRequested extends AdminProductEvent {
  const LoadAdminBrandsRequested({this.search, this.page, this.limit});
  final String? search;
  final int? page;
  final int? limit;
}

class CreateAdminProductRequested extends AdminProductEvent {
  const CreateAdminProductRequested({
    required this.name,
    required this.price,
    required this.stock,
    this.categoryId,
    this.image,
  });
  final String name;
  final double price;
  final int stock;
  final int? categoryId;
  final String? image;
}

class UpdateAdminProductRequested extends AdminProductEvent {
  const UpdateAdminProductRequested({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.image,
  });
  final int id;
  final String name;
  final double price;
  final int stock;
  final String? image;
}

class DeleteAdminProductRequested extends AdminProductEvent {
  const DeleteAdminProductRequested(this.id);
  final int id;
}

class CreateAdminBrandRequested extends AdminProductEvent {
  const CreateAdminBrandRequested(this.name, {this.image});
  final String name;
  final String? image;
}

class UpdateAdminBrandRequested extends AdminProductEvent {
  const UpdateAdminBrandRequested({
    required this.id,
    required this.name,
    this.image,
  });
  final int id;
  final String name;
  final String? image;
}

class DeleteAdminBrandRequested extends AdminProductEvent {
  const DeleteAdminBrandRequested(this.id);
  final int id;
}
