import 'package:flutter/material.dart';

import 'package:app_manager/constants/app_colors.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.disabled = false,
    this.color,
    this.textStyle,
    this.textColor,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    this.primaryBgWhenDisabled = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool loading;
  final bool disabled;
  final Color? color;
  final TextStyle? textStyle;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool primaryBgWhenDisabled;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled =
        !widget.disabled && !widget.loading && widget.onPressed != null;
    final bgColor = widget.color ?? AppColors.primary;
    final fgColor = widget.textColor ?? Theme.of(context).colorScheme.onPrimary;

    final targetScale = enabled && _pressed ? 0.99 : 1.0;

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        child: AnimatedScale(
          scale: targetScale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: ElevatedButton(
            onPressed: enabled ? widget.onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.disabled && widget.primaryBgWhenDisabled
                  ? bgColor
                  : bgColor,
              foregroundColor: fgColor,
              disabledBackgroundColor: widget.primaryBgWhenDisabled
                  ? bgColor
                  : AppColors.buttonDisabled,
              disabledForegroundColor: widget.primaryBgWhenDisabled
                  ? fgColor
                  : AppColors.textSecondary.withValues(alpha: 0.95),
              elevation: 0,
              padding: widget.padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                if (widget.loading) const SizedBox(width: 10),
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.text,
                  style:
                      widget.textStyle ??
                      Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: fgColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AppButton oldWidget) {
    if ((oldWidget.disabled != widget.disabled ||
            oldWidget.loading != widget.loading) &&
        (widget.disabled || widget.loading)) {
      _pressed = false;
    }
    super.didUpdateWidget(oldWidget);
  }
}
