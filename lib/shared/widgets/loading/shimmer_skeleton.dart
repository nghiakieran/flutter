import 'package:flutter/material.dart';

import 'package:app_manager/constants/app_colors.dart';

class ShimmerSkeleton extends StatefulWidget {
  const ShimmerSkeleton({
    super.key,
    this.height = 16,
    this.width,
    this.radius = 16,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              gradient: LinearGradient(
                begin: Alignment(-1.0 + (t * 2), 0),
                end: Alignment(1.0 + (t * 2), 0),
                colors: [
                  AppColors.neutral100,
                  Colors.white.withValues(alpha: 0.8),
                  AppColors.neutral100,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
