import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.controller,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.onTap,
  });

  final String hintText;
  final IconData prefixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffix,
      ),
    );
  }
}
