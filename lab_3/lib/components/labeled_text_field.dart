import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Text field with its label on top. Owns its TextEditingController.
class LabeledTextField extends StatefulWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.isPassword = false,
    this.icon,
  });

  final String label;

  final String hint;

  final Function(String) onChanged;

  final bool isPassword;

  final IconData? icon;

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            onChanged: (value) => widget.onChanged(value),
            obscureText: widget.isPassword,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              prefixIcon: widget.icon == null
                  ? null
                  : Icon(
                      widget.icon,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
              filled: true,
              fillColor: AppColors.field,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
