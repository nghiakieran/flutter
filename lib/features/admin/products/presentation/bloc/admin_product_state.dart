import 'package:app_manager/features/admin/products/data/models/admin_product_models.dart';

class AdminProductState {
  const AdminProductState({
    this.isLoading = false,
    this.products = const <AdminProduct>[],
    this.brands = const <AdminBrand>[],
    this.errorMessage,
    this.productSearch = '',
    this.brandSearch = '',
    this.productPage = 1,
    this.productLimit = 10,
    this.productTotal = 0,
    this.productTotalPages = 1,
    this.brandPage = 1,
    this.brandLimit = 10,
    this.brandTotal = 0,
    this.brandTotalPages = 1,
  });

  final bool isLoading;
  final List<AdminProduct> products;
  final List<AdminBrand> brands;
  final String? errorMessage;
  final String productSearch;
  final String brandSearch;
  final int productPage;
  final int productLimit;
  final int productTotal;
  final int productTotalPages;
  final int brandPage;
  final int brandLimit;
  final int brandTotal;
  final int brandTotalPages;

  AdminProductState copyWith({
    bool? isLoading,
    List<AdminProduct>? products,
    List<AdminBrand>? brands,
    String? errorMessage,
    String? productSearch,
    String? brandSearch,
    int? productPage,
    int? productLimit,
    int? productTotal,
    int? productTotalPages,
    int? brandPage,
    int? brandLimit,
    int? brandTotal,
    int? brandTotalPages,
    bool clearError = false,
  }) {
    return AdminProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      brands: brands ?? this.brands,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      productSearch: productSearch ?? this.productSearch,
      brandSearch: brandSearch ?? this.brandSearch,
      productPage: productPage ?? this.productPage,
      productLimit: productLimit ?? this.productLimit,
      productTotal: productTotal ?? this.productTotal,
      productTotalPages: productTotalPages ?? this.productTotalPages,
      brandPage: brandPage ?? this.brandPage,
      brandLimit: brandLimit ?? this.brandLimit,
      brandTotal: brandTotal ?? this.brandTotal,
      brandTotalPages: brandTotalPages ?? this.brandTotalPages,
    );
  }
}
