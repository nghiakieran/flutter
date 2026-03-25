import 'package:flutter/material.dart';

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
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    final trimmed = widget.initialValue.replaceAll(' ', '');
    for (var i = 0; i < widget.length; i++) {
      if (i < trimmed.length) {
        _controllers[i].text = trimmed[i];
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _emit() {
    final value = _controllers.map((c) => c.text).join();
    widget.onChanged(value);
  }

  void _onDigitChanged(int index, String digit) {
    if (digit.length > 1) {
      digit = digit.characters.first;
    }
    _controllers[index].text = digit;
    _emit();

    if (digit.isNotEmpty && index < widget.length - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[];
    for (var i = 0; i < widget.length; i++) {
      cells.add(
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == widget.length - 1 ? 0 : 8),
            child: Focus(
              focusNode: _focusNodes[i],
              child: AnimatedBuilder(
                animation: _focusNodes[i],
                builder: (context, child) {
                  final focused = _focusNodes[i].hasFocus;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: focused ? AppColors.secondary : AppColors.border,
                        width: focused ? 2 : 1,
                      ),
                      boxShadow: focused
                          ? [
                              BoxShadow(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 18,
                              ),
                            ]
                          : null,
                    ),
                    child: TextField(
                      enabled: widget.enabled,
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) => _onDigitChanged(i, val),
                      onTap: () {
                        // Ensure cursor at end.
                        _controllers[i].selection = TextSelection.fromPosition(
                          TextPosition(offset: _controllers[i].text.length),
                        );
                      },
                      // Handle backspace: in TextField we use key events indirectly.
                      // For simplicity, we rely on user deleting in the field; when empty,
                      // focus won't auto-jump back on backspace across platforms.
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    return Row(children: cells);
  }
}
