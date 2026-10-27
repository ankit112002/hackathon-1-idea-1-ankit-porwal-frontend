import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    String? hintText,
    this.keyboardType,
    this.obscure = false,
    this.maxLines = 1,
    this.onChanged,
  }) : hintText = hintText ?? hint;

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? hintText;

  final TextInputType? keyboardType;
  final bool obscure;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLines: obscure ? 1 : maxLines,
      onChanged: onChanged,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
          : null,
      decoration: InputDecoration(
        labelText: label.isEmpty ? null : label,
        hintText: hintText,
      ),
    );
  }
}

