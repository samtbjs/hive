import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Lightweight shimmer placeholder — no external package dependency.
/// Animates a soft gradient sweep across a rounded box, used while data
/// is loading (income sync, credential issuance, etc).
class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(AppRadius.sm);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
              colors: const [
                AppColors.shimmerBase,
                AppColors.shimmerHighlight,
                AppColors.shimmerBase,
              ],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}

/// A ready-made stack of shimmer lines shaped like a typical card, so
/// screens can drop in a loading state without hand-building layouts.
class LoadingShimmerCard extends StatelessWidget {
  const LoadingShimmerCard({super.key, this.lines = 3});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoadingShimmer(width: 120, height: 14),
          const SizedBox(height: AppSpacing.sm),
          for (int i = 0; i < lines; i++) ...[
                const LoadingShimmer(width: double.infinity, height: 12),
            if (i != lines - 1) const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}
