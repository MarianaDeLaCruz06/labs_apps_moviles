import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Outlined button with a transparent background.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fullWidth = false,
  });

  final String text;
  final Function() onPressed;

  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: () => onPressed(),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return Align(alignment: Alignment.centerLeft, child: button);
  }
}
