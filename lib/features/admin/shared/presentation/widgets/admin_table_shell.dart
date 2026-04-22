import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:app_manager/constants/app_colors.dart';
import 'package:app_manager/shared/widgets/error-empty/empty_state_widget.dart';

class AdminTableShell extends StatefulWidget {
  const AdminTableShell({
    super.key,
    required this.columns,
    required this.itemCount,
    required this.totalItems,
    required this.rowBuilder,
    required this.onRefresh,
    required this.emptyTitle,
    required this.emptyMessage,
    this.enableSearch = false,
    this.searchHint = 'Tìm kiếm...',
    this.onSearchChanged,
    this.searchTrailing,
    this.isRemotePagination = false,
    this.currentPage = 1,
    this.rowsPerPage = 10,
    this.totalPages = 1,
    this.onPageChanged,
    this.onRowsPerPageChanged,
    this.isLoading = false,
    this.loadingRowCount = 8,
  });

  final List<DataColumn> columns;
  final int itemCount;
  final int totalItems;
  final DataRow Function(int index) rowBuilder;
  final Future<void> Function() onRefresh;
  final String emptyTitle;
  final String emptyMessage;
  final bool enableSearch;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final Widget? searchTrailing;
  final bool isRemotePagination;
  final int currentPage;
  final int rowsPerPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onRowsPerPageChanged;
  final bool isLoading;
  final int loadingRowCount;

  @override
  State<AdminTableShell> createState() => _AdminTableShellState();
}

class _AdminTableShellState extends State<AdminTableShell> {
  int _page = 1;
  int _rowsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<DataCell> _extractCells(DataRow row) => row.cells;

  String _labelText(Widget widget) {
    if (widget is Text) return widget.data ?? '';
    return '';
  }

  double _estimateColumnWidth(DataColumn column) {
    final label = _labelText(column.label).toLowerCase();
    if (label.contains('stt')) return 56;
    if (label.contains('ảnh') || label.contains('logo')) return 78;
    if (label.contains('giá')) return 90;
    if (label.contains('tồn')) return 84;
    if (label.contains('ngày')) return 92;
    if (label.contains('thao tác')) return 132;
    return 170;
  }

  List<DataRow> _buildSkeletonRows() {
    final rowCount = math.max(1, widget.loadingRowCount);
    return List.generate(
      rowCount,
      (_) => DataRow(
        cells: List.generate(
          widget.columns.length,
          (_) => const DataCell(_SkeletonCell()),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRowsPerPage = widget.isRemotePagination
        ? widget.rowsPerPage
        : _rowsPerPage;
    final totalPages = widget.isRemotePagination
        ? math.max(1, widget.totalPages)
        : math.max(1, (widget.totalItems / effectiveRowsPerPage).ceil());
    if (!widget.isRemotePagination && _page > totalPages) _page = totalPages;
    final effectivePage = widget.isRemotePagination
        ? widget.currentPage
        : _page;

    final showEmptyState = !widget.isLoading && widget.totalItems == 0;
    final columnWidths = widget.columns.map(_estimateColumnWidth).toList();
    final totalTableWidth = columnWidths.fold<double>(0, (a, b) => a + b);

    final rows = widget.isLoading
        ? _buildSkeletonRows()
        : widget.isRemotePagination
        ? List.generate(widget.itemCount, widget.rowBuilder)
        : () {
            final start = (_page - 1) * _rowsPerPage;
            final end = math.min(start + _rowsPerPage, widget.itemCount);
            return List.generate(
              end - start,
              (i) => widget.rowBuilder(start + i),
            );
          }();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (widget.enableSearch) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      hintText: widget.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                widget.onSearchChanged?.call('');
                                setState(() {});
                              },
                              icon: const Icon(Icons.close),
                            ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      if (widget.onSearchChanged == null) return;
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(
                        const Duration(milliseconds: 400),
                        () {
                          widget.onSearchChanged!(value.trim());
                        },
                      );
                    },
                  ),
                ),
                if (widget.searchTrailing != null) ...[
                  const SizedBox(width: 10),
                  widget.searchTrailing!,
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (showEmptyState)
            SizedBox(
              height: 420,
              child: EmptyStateWidget(
                icon: Icons.table_rows_outlined,
                title: widget.emptyTitle,
                message: widget.emptyMessage,
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  children: [
                    Container(
                      height: 3,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2F6FA3), Color(0xFF7BA7CC)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: math.max(
                            MediaQuery.of(context).size.width - 24,
                            totalTableWidth,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 54,
                              color: const Color(0xFFE3EEF7),
                              child: Row(
                                children: List.generate(widget.columns.length, (
                                  i,
                                ) {
                                  final c = widget.columns[i];
                                  return SizedBox(
                                    width: columnWidths[i],
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: DefaultTextStyle(
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.25,
                                        ),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: c.label,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            SizedBox(
                              height: 366,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: List.generate(rows.length, (ri) {
                                    final row = rows[ri];
                                    final cells = _extractCells(row);
                                    return Container(
                                      height: 52,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppColors.border,
                                            width: 0.6,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: List.generate(cells.length, (
                                          ci,
                                        ) {
                                          return SizedBox(
                                            width: columnWidths[ci],
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: DefaultTextStyle(
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontSize: 15,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  child: cells[ci].child,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!showEmptyState) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                DropdownButton<int>(
                  value: effectiveRowsPerPage,
                  items: const [10, 20, 30]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text('$e / trang'),
                        ),
                      )
                      .toList(),
                  onChanged: widget.isLoading
                      ? null
                      : (v) {
                          if (v == null) return;
                          if (widget.isRemotePagination) {
                            widget.onRowsPerPageChanged?.call(v);
                          } else {
                            setState(() {
                              _rowsPerPage = v;
                              _page = 1;
                            });
                          }
                        },
                ),
                const Spacer(),
                Text(
                  '${widget.itemCount} / ${widget.totalItems} mục',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: !widget.isLoading && effectivePage > 1
                      ? () {
                          if (widget.isRemotePagination) {
                            widget.onPageChanged?.call(effectivePage - 1);
                          } else {
                            setState(() => _page--);
                          }
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('Trang $effectivePage / $totalPages'),
                IconButton(
                  onPressed: !widget.isLoading && effectivePage < totalPages
                      ? () {
                          if (widget.isRemotePagination) {
                            widget.onPageChanged?.call(effectivePage + 1);
                          } else {
                            setState(() => _page++);
                          }
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SkeletonCell extends StatefulWidget {
  const _SkeletonCell();

  @override
  State<_SkeletonCell> createState() => _SkeletonCellState();
}

class _SkeletonCellState extends State<_SkeletonCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.45,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.neutral100,
              Color(0xFFF1F5F9),
              AppColors.neutral100,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
