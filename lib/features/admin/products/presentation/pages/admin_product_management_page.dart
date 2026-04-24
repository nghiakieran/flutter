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
    final hasImage = imageUrl.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasImage
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border,
          width: 1.5,
        ),
      ),
      child: hasImage
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.redAccent),
                          SizedBox(height: 4),
                          Text(
                            'Lỗi tải ảnh',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Colors.black26,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  emptyLabel,
                  style: const TextStyle(
                    color: Colors.black38,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
              child: const Text('Hủy', style: TextStyle(fontSize: 14)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Xóa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Row(
            children: [
              Icon(
                isEdit ? Icons.edit_note : Icons.add_box_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                isEdit ? 'Sửa sản phẩm' : 'Tạo sản phẩm',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'Tên sản phẩm',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: 'Nhập tên...',
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.shopping_bag_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Giá',
                            labelStyle: const TextStyle(fontSize: 14),
                            hintText: '0',
                            hintStyle: const TextStyle(fontSize: 14),
                            suffixText: 'đ',
                            prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: stockCtrl,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            isDense: true,
                            labelText: 'Tồn kho',
                            labelStyle: const TextStyle(fontSize: 14),
                            hintText: '0',
                            hintStyle: const TextStyle(fontSize: 14),
                            prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imageCtrl,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: 'URL ảnh',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: 'http://...',
                      hintStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.link, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (_) => setLocalState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _buildImagePreview(
                    imageUrl: imageCtrl.text.trim(),
                    emptyLabel: 'Chưa có ảnh xem trước',
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
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
                      } catch (e) {
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(
                          ctx,
                        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.cloud_upload, size: 20),
                    label: const Text('Chọn ảnh & tải lên Cloudinary', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text(
                'Hủy',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
              ),
              child: Text(
                isEdit ? 'Lưu' : 'Tạo',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
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
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Row(
            children: [
              Icon(
                isEdit ? Icons.edit_note : Icons.add_business_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                isEdit ? 'Sửa thương hiệu' : 'Tạo thương hiệu',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Tên thương hiệu',
                    labelStyle: const TextStyle(fontSize: 14),
                    hintText: 'Nhập tên...',
                    hintStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(Icons.business_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: logoCtrl,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'URL logo',
                    labelStyle: const TextStyle(fontSize: 14),
                    hintText: 'http://...',
                    hintStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(Icons.link, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (_) => setLocalState(() {}),
                ),
                const SizedBox(height: 20),
                _buildImagePreview(
                  imageUrl: logoCtrl.text.trim(),
                  emptyLabel: 'Chưa có logo xem trước',
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
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
                    } catch (e) {
                      if (!ctx.mounted) return;
                      ScaffoldMessenger.of(
                        ctx,
                      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  icon: const Icon(Icons.cloud_upload, size: 20),
                  label: const Text('Chọn logo & tải lên Cloudinary', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text(
                'Hủy',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
              ),
              child: Text(
                isEdit ? 'Lưu' : 'Tạo',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
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
