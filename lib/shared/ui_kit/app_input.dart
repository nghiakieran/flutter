import 'package:flutter/material.dart';

import 'package:app_manager/constants/app_colors.dart';

class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.focusNode,
    this.autoFillHints,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final Iterable<String>? autoFillHints;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  late final bool _hasExternalFocusNode = widget.focusNode != null;

  @override
  void initState() {
    super.initState();
    if (!_hasExternalFocusNode) {
      // Keep focus node lifecycle here.
    }
  }

  @override
  void dispose() {
    if (!_hasExternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusNode,
      builder: (context, child) {
        final focused = _focusNode.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: focused
              ? BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.28),
                      blurRadius: 18,
                    ),
                  ],
                )
              : const BoxDecoration(),
          child: child,
        );
      },
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        autofillHints: widget.autoFillHints,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          errorText: widget.errorText,
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: widget.validator,
        onChanged: widget.onChanged,
      ),
    );
  }
}
