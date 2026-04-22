import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/core/services/media/cloudinary_upload_service.dart';
import 'package:app_manager/core/di/di_container.dart';
import 'package:app_manager/features/admin/products/data/models/admin_product_models.dart';
import 'package:app_manager/features/admin/products/presentation/bloc/admin_product_bloc.dart';
import 'package:app_manager/features/admin/products/presentation/bloc/admin_product_event.dart';
import 'package:app_manager/features/admin/products/presentation/bloc/admin_product_state.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_add_icon_button.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_page_app_bar.dart';
import 'package:app_manager/features/admin/shared/presentation/widgets/admin_table_shell.dart';

class AdminProductManagementPage extends StatelessWidget {
  const AdminProductManagementPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminProductBloc>(
      create: (_) => getIt<AdminProductBloc>()
        ..add(const LoadAdminProductsRequested())
        ..add(const LoadAdminBrandsRequested()),
      child: _AdminProductManagementView(initialTab: initialTab),
    );
  }
}

class _AdminProductManagementView extends StatelessWidget {
  const _AdminProductManagementView({required this.initialTab});

  final int initialTab;
  static final ImagePicker _imagePicker = ImagePicker();

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  Widget _buildImagePreview({
    required String imageUrl,
    required String emptyLabel,
  }) {
    if (imageUrl.trim().isEmpty) {
      return Container(
        width: double.infinity,
        height: 124,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, color: Colors.black38, size: 20),
            const SizedBox(height: 6),
            Text(
              emptyLabel,
              style: const TextStyle(color: Colors.black45, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: 124,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 96,
          height: 96,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Center(
              child: Text(
                'URL ảnh không hợp lệ',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context, {
    required String itemLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa $itemLabel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _showProductDialog(
    BuildContext context, {
    AdminProduct? product,
  }) async {
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final priceCtrl = TextEditingController(
      text: product == null ? '' : '${product.price}',
    );
    final stockCtrl = TextEditingController(
      text: product == null ? '' : '${product.stock}',
    );
    final imageCtrl = TextEditingController(text: product?.image ?? '');
    final isEdit = product != null;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: Text(isEdit ? 'Sửa sản phẩm' : 'Tạo sản phẩm'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Tên'),
                ),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Giá'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(labelText: 'Tồn kho'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(labelText: 'URL ảnh'),
                  onChanged: (_) => setLocalState(() {}),
                ),
                const SizedBox(height: 8),
                _buildImagePreview(
                  imageUrl: imageCtrl.text.trim(),
                  emptyLabel: 'Chưa có ảnh xem trước',
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final picked = await _imagePicker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (picked == null) return;
                        setLocalState(() {});
                        final url = await CloudinaryUploadService.uploadImage(
                          File(picked.path),
                        );
                        imageCtrl.text = url;
                        setLocalState(() {});
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Tải ảnh sản phẩm thành công'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Upload ảnh thất bại: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Chọn ảnh & tải lên Cloudinary'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
                final image = imageCtrl.text.trim();
                if (isEdit) {
                  context.read<AdminProductBloc>().add(
                    UpdateAdminProductRequested(
                      id: product.id,
                      name: name,
                      price: price,
                      stock: stock,
                      image: image.isEmpty ? null : image,
                    ),
                  );
                } else {
                  context.read<AdminProductBloc>().add(
                    CreateAdminProductRequested(
                      name: name,
                      price: price,
                      stock: stock,
                      image: image.isEmpty ? null : image,
                    ),
                  );
                }
                Navigator.of(ctx).pop();
              },
              child: Text(isEdit ? 'Lưu' : 'Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBrandDialog(
    BuildContext context, {
    AdminBrand? brand,
  }) async {
    final nameCtrl = TextEditingController(text: brand?.name ?? '');
    final logoCtrl = TextEditingController(text: brand?.image ?? '');
    final isEdit = brand != null;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: Text(isEdit ? 'Sửa thương hiệu' : 'Tạo thương hiệu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên thương hiệu',
                  ),
                ),
                TextField(
                  controller: logoCtrl,
                  decoration: const InputDecoration(labelText: 'URL logo'),
                  onChanged: (_) => setLocalState(() {}),
                ),
                const SizedBox(height: 8),
                _buildImagePreview(
                  imageUrl: logoCtrl.text.trim(),
                  emptyLabel: 'Chưa có logo xem trước',
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final picked = await _imagePicker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (picked == null) return;
                        final url = await CloudinaryUploadService.uploadImage(
                          File(picked.path),
                        );
                        logoCtrl.text = url;
                        setLocalState(() {});
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Tải logo thương hiệu thành công'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Upload logo thất bại: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Chọn logo & tải lên Cloudinary'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final image = logoCtrl.text.trim();
                if (isEdit) {
                  context.read<AdminProductBloc>().add(
                    UpdateAdminBrandRequested(
                      id: brand.id,
                      name: nameCtrl.text.trim(),
                      image: image.isEmpty ? null : image,
                    ),
                  );
                } else {
                  context.read<AdminProductBloc>().add(
                    CreateAdminBrandRequested(
                      nameCtrl.text.trim(),
                      image: image.isEmpty ? null : image,
                    ),
                  );
                }
                Navigator.of(ctx).pop();
              },
              child: Text(isEdit ? 'Lưu' : 'Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab.clamp(0, 1),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AdminPageAppBar(
          title: 'Quản lý sản phẩm',
          subtitle: 'Danh mục sản phẩm và thương hiệu',
          bottom: TabBar(
            tabs: [
              Tab(text: 'Sản phẩm'),
              Tab(text: 'Thương hiệu'),
            ],
          ),
        ),
        body: BlocBuilder<AdminProductBloc, AdminProductState>(
          builder: (context, state) {
            return TabBarView(
              children: [
                AdminTableShell(
                  isLoading: state.isLoading,
                  enableSearch: true,
                  searchHint: 'Tìm sản phẩm...',
                  searchTrailing: AdminAddIconButton(
                    onPressed: () => _showProductDialog(context),
                    tooltip: 'Thêm sản phẩm',
                  ),
                  onSearchChanged: (value) {
                    context.read<AdminProductBloc>().add(
                      LoadAdminProductsRequested(
                        search: value,
                        page: 1,
                        limit: state.productLimit,
                      ),
                    );
                  },
                  isRemotePagination: true,
                  currentPage: state.productPage,
                  rowsPerPage: state.productLimit,
                  totalPages: state.productTotalPages,
                  onPageChanged: (page) {
                    context.read<AdminProductBloc>().add(
                      LoadAdminProductsRequested(
                        search: state.productSearch,
                        page: page,
                        limit: state.productLimit,
                      ),
                    );
                  },
                  onRowsPerPageChanged: (limit) {
                    context.read<AdminProductBloc>().add(
                      LoadAdminProductsRequested(
                        search: state.productSearch,
                        page: 1,
                        limit: limit,
                      ),
                    );
                  },
                  columns: const [
                    DataColumn(label: Text('STT')),
                    DataColumn(label: Text('Ảnh')),
                    DataColumn(label: Text('Tên')),
                    DataColumn(label: Text('Giá')),
                    DataColumn(label: Text('Tồn kho')),
                    DataColumn(label: Text('Ngày tạo')),
                    DataColumn(label: Text('Thao tác')),
                  ],
                  itemCount: state.products.length,
                  totalItems: state.productTotal,
                  onRefresh: () async {
                    context.read<AdminProductBloc>().add(
                      LoadAdminProductsRequested(
                        search: state.productSearch,
                        page: state.productPage,
                        limit: state.productLimit,
                      ),
                    );
                  },
                  emptyTitle: 'Chưa có sản phẩm',
                  emptyMessage: 'Hãy thêm sản phẩm đầu tiên để hiển thị bảng.',
                  rowBuilder: (index) {
                    final p = state.products[index];
                    final stt =
                        ((state.productPage - 1) * state.productLimit) +
                        index +
                        1;
                    return DataRow(
                      cells: [
                        DataCell(Text('$stt')),
                        DataCell(
                          p.image?.isNotEmpty == true
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    p.image!,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 18,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.image_outlined,
                                  size: 18,
                                  color: Colors.black45,
                                ),
                        ),
                        DataCell(Text(p.name)),
                        DataCell(Text(p.price.toStringAsFixed(0))),
                        DataCell(Text('${p.stock}')),
                        DataCell(Text(_formatDate(p.createdAt))),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _showProductDialog(context, product: p),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final confirmed = await _confirmDelete(
                                    context,
                                    itemLabel: 'sản phẩm "${p.name}"',
                                  );
                                  if (!confirmed || !context.mounted) {
                                    return;
                                  }
                                  context.read<AdminProductBloc>().add(
                                    DeleteAdminProductRequested(p.id),
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFE57373),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                AdminTableShell(
                  isLoading: state.isLoading,
                  enableSearch: true,
                  searchHint: 'Tìm thương hiệu...',
                  searchTrailing: AdminAddIconButton(
                    onPressed: () => _showBrandDialog(context),
                    tooltip: 'Thêm thương hiệu',
                  ),
                  onSearchChanged: (value) {
                    context.read<AdminProductBloc>().add(
                      LoadAdminBrandsRequested(
                        search: value,
                        page: 1,
                        limit: state.brandLimit,
                      ),
                    );
                  },
                  isRemotePagination: true,
                  currentPage: state.brandPage,
                  rowsPerPage: state.brandLimit,
                  totalPages: state.brandTotalPages,
                  onPageChanged: (page) {
                    context.read<AdminProductBloc>().add(
                      LoadAdminBrandsRequested(
                        search: state.brandSearch,
                        page: page,
                        limit: state.brandLimit,
                      ),
                    );
                  },
                  onRowsPerPageChanged: (limit) {
                    context.read<AdminProductBloc>().add(
                      LoadAdminBrandsRequested(
                        search: state.brandSearch,
                        page: 1,
                        limit: limit,
                      ),
                    );
                  },
                  columns: const [
                    DataColumn(label: Text('STT')),
                    DataColumn(label: Text('Logo')),
                    DataColumn(label: Text('Thương hiệu')),
                    DataColumn(label: Text('Ngày tạo')),
                    DataColumn(label: Text('Thao tác')),
                  ],
                  itemCount: state.brands.length,
                  totalItems: state.brandTotal,
                  onRefresh: () async {
                    context.read<AdminProductBloc>().add(
                      LoadAdminBrandsRequested(
                        search: state.brandSearch,
                        page: state.brandPage,
                        limit: state.brandLimit,
                      ),
                    );
                  },
                  emptyTitle: 'Chưa có thương hiệu',
                  emptyMessage:
                      'Hãy thêm thương hiệu đầu tiên để hiển thị bảng.',
                  rowBuilder: (index) {
                    final b = state.brands[index];
                    final stt =
                        ((state.brandPage - 1) * state.brandLimit) + index + 1;
                    return DataRow(
                      cells: [
                        DataCell(Text('$stt')),
                        DataCell(
                          b.image?.isNotEmpty == true
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    b.image!,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 18,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.image_outlined,
                                  size: 18,
                                  color: Colors.black45,
                                ),
                        ),
                        DataCell(Text(b.name)),
                        DataCell(Text(_formatDate(b.createdAt))),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _showBrandDialog(context, brand: b),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final confirmed = await _confirmDelete(
                                    context,
                                    itemLabel: 'thương hiệu "${b.name}"',
                                  );
                                  if (!confirmed || !context.mounted) {
                                    return;
                                  }
                                  context.read<AdminProductBloc>().add(
                                    DeleteAdminBrandRequested(b.id),
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFE57373),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
