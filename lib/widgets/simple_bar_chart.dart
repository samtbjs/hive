import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A minimal bar chart drawn with plain widgets so the project has zero
/// charting-package dependency. Good enough for a UI mock-up; swap for
/// fl_chart/syncfusion later if you want richer interactions.
class SimpleBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final double height;

  const SimpleBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final ratio = maxVal == 0 ? 0.0 : values[i] / maxVal;
          final isLast = i == values.length - 1;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: (height - 28) * ratio.clamp(0.05, 1.0),
                    decoration: BoxDecoration(
                      color: isLast ? AppColors.primary : AppColors.primaryMuted,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(labels[i],
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
