import 'package:flutter/material.dart';

class PlannerTextField extends StatelessWidget {
  const PlannerTextField({
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.prefixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Container(
                padding: EdgeInsets.only(top: maxLines > 1 ? 14.0 : 0.0),
                alignment: maxLines > 1 ? Alignment.topCenter : Alignment.center,
                width: 48,
                child: prefixIcon,
              )
            : null,
        prefixIconConstraints: BoxConstraints(minWidth: 48, minHeight: maxLines > 1 ? 48 : 0),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}
