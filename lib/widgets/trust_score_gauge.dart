import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class TrustScoreGauge extends StatelessWidget {
  const TrustScoreGauge({
    super.key,
    required this.score,
    required this.label,
    this.size = 138,
    this.showScaleLabel = true,
  });

  final int score;
  final String label;
  final double size;
  final bool showScaleLabel;

  @override
  Widget build(BuildContext context) {
    final progress = ((score - 300) / 600).clamp(0.0, 1.0).toDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: size * 0.08,
                strokeCap: StrokeCap.round,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.accentTrust),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$score', style: AppTextStyles.displayNumber),
                if (showScaleLabel) Text('out of 900', style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentTrustSoft,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyStrong.copyWith(color: AppColors.accentTrust),
          ),
        ),
      ],
    );
  }
}
