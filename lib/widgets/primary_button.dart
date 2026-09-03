import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Standard call-to-action button. Wraps ElevatedButton so every primary
/// action in the app (sync income, request credential, grant consent...)
/// looks and behaves identically, including a built-in loading state.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.variant = PrimaryButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final PrimaryButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label),
            ],
          );

    final button = variant == PrimaryButtonVariant.filled
        ? ElevatedButton(onPressed: isLoading ? null : onPressed, child: child)
        : OutlinedButton(onPressed: isLoading ? null : onPressed, child: child);

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

enum PrimaryButtonVariant { filled, outlined }
