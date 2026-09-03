import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// The single card container used everywhere in the app. Centralizing it
/// here keeps radius/border/shadow/padding consistent instead of every
/// screen rolling its own `Container` + `BoxDecoration`.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.accentColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Optional 3px left accent bar — used sparingly to draw the eye to
  /// something important (e.g. a pending action) without new color.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1A1F2E),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (accentColor != null) Container(width: 3, color: accentColor),
            Expanded(child: Padding(padding: padding, child: child)),
          ],
        ),
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: card,
      ),
    );
  }
}
