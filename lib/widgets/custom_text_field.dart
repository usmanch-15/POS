// lib/widgets/custom_text_field.dart
// ─────────────────────────────────────────────────────────────
//  StockPro — Reusable Text Input Widget
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefix;
  final String? suffix;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
  });

  /// Numeric field factory
  factory CustomTextField.number({
    Key? key,
    required String label,
    String? hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? prefix,
    String? suffix,
    bool decimal = true,
  }) {
    return CustomTextField(
      key: key,
      label: label,
      hint: hint ?? '0.00',
      controller: controller,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          decimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*'),
        ),
      ],
      onChanged: onChanged,
      prefix: prefix,
      suffix: suffix,
    );
  }

  /// Password field factory
  factory CustomTextField.password({
    Key? key,
    required String label,
    TextEditingController? controller,
    String? Function(String?)? validator,
    FocusNode? focusNode,
  }) {
    return _PasswordTextField(
      key: key,
      label: label,
      controller: controller,
      validator: validator,
      focusNode: focusNode,
    );
  }

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      obscureText: widget.obscureText,
      readOnly: widget.readOnly,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onFieldSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      style: TextStyle(
        fontSize: AppDimensions.fontBase,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.lightText1,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        prefixText: widget.prefix != null ? '${widget.prefix} ' : null,
        suffixText: widget.suffix,
        counterText: '',
      ),
    );
  }
}

// ── Password variant (internal) ────────────────────────────────
class _PasswordTextField extends CustomTextField {
  const _PasswordTextField({
    super.key,
    required super.label,
    super.controller,
    super.validator,
    super.focusNode,
  }) : super(obscureText: true);

  @override
  State<CustomTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends _CustomTextFieldState {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      focusNode: widget.focusNode,
      obscureText: !_visible,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      style: TextStyle(
        fontSize: AppDimensions.fontBase,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.lightText1,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _visible = !_visible),
          icon: Icon(
            _visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: AppColors.lightText3,
          ),
        ),
      ),
    );
  }
}
