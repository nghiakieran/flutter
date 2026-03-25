import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_manager/constants/app_colors.dart';

class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.length,
    required this.onChanged,
    this.initialValue = '',
    this.enabled = true,
  });

  final int length;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();

    _controller.addListener(_handleControllerUpdate);
    _focusNode.addListener(_handleFocusUpdate);

    _startCursorTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.enabled) _focusNode.requestFocus();
    });
  }

  void _handleControllerUpdate() {
    if (mounted) setState(() {});
    widget.onChanged(_controller.text);
  }

  void _handleFocusUpdate() {
    if (mounted) setState(() {});
    if (_focusNode.hasFocus) {
      _startCursorTimer();
    } else {
      _cursorTimer?.cancel();
    }
  }

  void _startCursorTimer() {
    _cursorTimer?.cancel();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              maxLength: widget.length,
              enabled: widget.enabled,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: ""),
            ),
          ),
        ),
        // Custom UI view
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, (index) {
              final text = _controller.text;
              final focusedIndex = text.length;
              final isFocusedField =
                  _focusNode.hasFocus && index == focusedIndex;
              final isLastAndFilled =
                  _focusNode.hasFocus &&
                  index == widget.length - 1 &&
                  text.length == widget.length;

              final isCurrentActive = isFocusedField || isLastAndFilled;

              String char = "";
              if (index < text.length) char = text[index];

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == widget.length - 1 ? 0 : 8,
                  ),
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrentActive
                          ? AppColors.primary
                          : AppColors.border,
                      width: isCurrentActive ? 2 : 1,
                    ),
                    boxShadow: isCurrentActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          char,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        if (isFocusedField && _showCursor)
                          Container(
                            width: 2,
                            height: 24,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
