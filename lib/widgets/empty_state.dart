import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'primary_button.dart';

/// Used for empty lists, un-built feature tabs, and "nothing to show yet"
/// states. Keeps every blank screen in the app feeling intentional rather
/// than broken.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
                variant: PrimaryButtonVariant.outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
