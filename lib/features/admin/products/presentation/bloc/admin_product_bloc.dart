import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_manager/core/blocs/base_bloc.dart';
import 'package:app_manager/features/admin/products/data/repositories/admin_product_repository.dart';
import 'package:app_manager/features/admin/products/presentation/bloc/admin_product_event.dart';
import 'package:app_manager/features/admin/products/presentation/bloc/admin_product_state.dart';

class AdminProductBloc extends BaseBloc<AdminProductEvent, AdminProductState> {
  AdminProductBloc(this._repository) : super(const AdminProductState()) {
    on<LoadAdminProductsRequested>(_onLoadProducts);
    on<LoadAdminBrandsRequested>(_onLoadBrands);
    on<CreateAdminProductRequested>(_onCreateProduct);
    on<UpdateAdminProductRequested>(_onUpdateProduct);
    on<DeleteAdminProductRequested>(_onDeleteProduct);
    on<CreateAdminBrandRequested>(_onCreateBrand);
    on<UpdateAdminBrandRequested>(_onUpdateBrand);
    on<DeleteAdminBrandRequested>(_onDeleteBrand);
  }

  final IAdminProductRepository _repository;

  Future<void> _onLoadProducts(
    LoadAdminProductsRequested event,
    Emitter<AdminProductState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.getProducts(
        search: event.search ?? state.productSearch,
        page: event.page ?? state.productPage,
        limit: event.limit ?? state.productLimit,
      ),
      onStart: () => emit(
        state.copyWith(
          isLoading: true,
          productSearch: event.search ?? state.productSearch,
          productPage: event.page ?? state.productPage,
          productLimit: event.limit ?? state.productLimit,
          clearError: true,
        ),
      ),
      onSuccess: (data) async => emit(
        state.copyWith(
          isLoading: false,
          products: data.items,
          productPage: data.page,
          productLimit: data.limit,
          productTotal: data.total,
          productTotalPages: data.totalPages,
          clearError: true,
        ),
      ),
      onError: () async => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Tải danh sách sản phẩm thất bại',
        ),
      ),
    );
  }

  Future<void> _onLoadBrands(
    LoadAdminBrandsRequested event,
    Emitter<AdminProductState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.getBrands(
        search: event.search ?? state.brandSearch,
        page: event.page ?? state.brandPage,
        limit: event.limit ?? state.brandLimit,
      ),
      onStart: () => emit(
        state.copyWith(
          isLoading: true,
          brandSearch: event.search ?? state.brandSearch,
          brandPage: event.page ?? state.brandPage,
          brandLimit: event.limit ?? state.brandLimit,
          clearError: true,
        ),
      ),
      onSuccess: (data) async => emit(
        state.copyWith(
          isLoading: false,
          brands: data.items,
          brandPage: data.page,
          brandLimit: data.limit,
          brandTotal: data.total,
          brandTotalPages: data.totalPages,
          clearError: true,
        ),
      ),
      onError: () async => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Tải danh sách thương hiệu thất bại',
        ),
      ),
    );
  }

  Future<void> _onCreateProduct(
    CreateAdminProductRequested event,
    Emitter<AdminProductState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.createProduct(
        name: event.name,
        price: event.price,
        stock: event.stock,
        categoryId: event.categoryId,
        image: event.image,
      ),
      onSuccess: (_) async => add(
        LoadAdminProductsRequested(
          search: state.productSearch,
          page: 1,
          limit: state.productLimit,
        ),
      ),
      onError: () async =>
          emit(state.copyWith(errorMessage: 'Tạo sản phẩm thất bại')),
    );
  }

  Future<void> _onUpdateProduct(
    UpdateAdminProductRequested event,
    Emitter<AdminProductState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.updateProduct(
        id: event.id,
        name: event.name,
        price: event.price,
        stock: event.stock,
        image: event.image,
      ),
      onSuccess: (_) async => add(
        LoadAdminProductsRequested(
          search: state.productSearch,
          page: state.productPage,
          limit: state.productLimit,
        ),
      ),
      onError: () async =>
          emit(state.copyWith(errorMessage: 'Cập nhật sản phẩm thất bại')),
    );
  }

  Future<void> _onDeleteProduct(
    DeleteAdminProductRequested event,
    Emitter<AdminProductState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.deleteProduct(event.id),
      onSuccess: (_) async => add(
        LoadAdminProductsRequested(
          search: state.productSearch,
          page: state.productPage,
          limit: state.productLimit,
        ),
      ),
      onError: () async =>
          emit(state.copyWith(errorMessage: 'Xóa sản phẩm thất bại')),
    );
  }

  Future<void> _onCreateBrand(
    CreateAdminBrandRequested event,
    Emitter<AdminProductState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.createBrand(event.name, image: event.image),
      onSuccess: (_) async => add(
        LoadAdminBrandsRequested(
          search: state.brandSearch,
          page: 1,
          limit: state.brandLimit,
        ),
      ),
      onError: () async =>
          emit(state.copyWith(errorMessage: 'Tạo thương hiệu thất bại')),
    );
  }

  Future<void> _onUpdateBrand(
    UpdateAdminBrandRequested event,
    Emitter<AdminProductState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.updateBrand(
        id: event.id,
        name: event.name,
        image: event.image,
      ),
      onSuccess: (_) async => add(
        LoadAdminBrandsRequested(
          search: state.brandSearch,
          page: state.brandPage,
          limit: state.brandLimit,
        ),
      ),
      onError: () async =>
          emit(state.copyWith(errorMessage: 'Cập nhật thương hiệu thất bại')),
    );
  }

  Future<void> _onDeleteBrand(
    DeleteAdminBrandRequested event,
    Emitter<AdminProductState> emit,
  ) async {
    await executeWithErrorHandling(
      () => _repository.deleteBrand(event.id),
      onSuccess: (_) async => add(
        LoadAdminBrandsRequested(
          search: state.brandSearch,
          page: state.brandPage,
          limit: state.brandLimit,
        ),
      ),
      onError: () async =>
          emit(state.copyWith(errorMessage: 'Xóa thương hiệu thất bại')),
    );
  }
}
