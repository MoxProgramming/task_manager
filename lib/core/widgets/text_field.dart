import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final Function(String)? onSubmit;

  const AppTextField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: obscureText,
      onSubmitted: onSubmit,
    );
  }
}
