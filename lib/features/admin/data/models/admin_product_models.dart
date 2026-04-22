class AdminProduct {
  const AdminProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.categoryId,
    this.image,
    this.createdAt,
  });

  final int id;
  final String name;
  final double price;
  final int stock;
  final int? categoryId;
  final String? image;
  final DateTime? createdAt;

  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    return AdminProduct(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: _asDouble(json['price']),
      stock: _asInt(json['stock']),
      categoryId: json['categoryId'] == null
          ? null
          : _asInt(json['categoryId']),
      image: json['image']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  static int _asInt(dynamic value) =>
      int.tryParse(value?.toString() ?? '') ?? 0;
  static double _asDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '') ?? 0;
}

class AdminBrand {
  const AdminBrand({
    required this.id,
    required this.name,
    this.image,
    this.createdAt,
  });

  final int id;
  final String name;
  final String? image;
  final DateTime? createdAt;

  factory AdminBrand.fromJson(Map<String, dynamic> json) {
    return AdminBrand(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class AdminProductPage {
  const AdminProductPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<AdminProduct> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
}

class AdminBrandPage {
  const AdminBrandPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<AdminBrand> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
}
