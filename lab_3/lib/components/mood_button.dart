import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Pill button that changes color depending on isSelected.
class MoodButton extends StatelessWidget {
  const MoodButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  });

  final String text;
  final bool isSelected;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextButton(
        onPressed: () => onPressed(),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? AppColors.green : AppColors.field,
          foregroundColor: isSelected ? Colors.black : AppColors.textPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
