import 'package:flutter/material.dart';

import 'package:app_manager/constants/app_colors.dart';

class AdminAddIconButton extends StatefulWidget {
  const AdminAddIconButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  State<AdminAddIconButton> createState() => _AdminAddIconButtonState();
}

class _AdminAddIconButtonState extends State<AdminAddIconButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? 0.93 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutBack,
          child: Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            elevation: _pressed ? 0.6 : 1.8,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
