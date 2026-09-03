import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Financial Identity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: state.loadAll,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            _GreetingCard(name: state.userName, score: state.reliabilityScore),
            const SizedBox(height: AppSpacing.lg),

            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Monthly income',
                    value: '\u20b9${state.totalMonthlyIncome.toStringAsFixed(0)}',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatTile(
                    label: 'Obligations',
                    value: '\u20b9${state.totalObligations.toStringAsFixed(0)}',
                    icon: Icons.receipt_long_outlined,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            const SectionHeader(
              title: 'Income trend',
              subtitle: 'Last 6 months, aggregated across all sources',
            ),
            AppCard(
              child: _IncomeTrendChart(
                values: state.incomeTrend,
                labels: state.incomeTrendLabels,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            const SectionHeader(title: 'Reliability metrics'),
            const AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MetricRow(label: 'Income stability', value: 0.82),
                  Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
                  _MetricRow(label: 'Payment consistency', value: 0.91),
                  Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
                  _MetricRow(label: 'Receivables collected on time', value: 0.68),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            SectionHeader(
              title: 'Income sources',
              subtitle: '${state.incomeSources.where((s) => s.connected).length} connected',
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < state.incomeSources.length; i++) ...[
                    _IncomeSourceTile(source: state.incomeSources[i]),
                    if (i != state.incomeSources.length - 1)
                      const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            const SectionHeader(title: 'Cash flow snapshot'),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: _CashFlowTile(
                      label: 'Inflow',
                      value: '\u20b9${state.totalMonthlyIncome.toStringAsFixed(0)}',
                      color: AppColors.success,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  Container(width: 1, height: 44, color: AppColors.divider),
                  Expanded(
                    child: _CashFlowTile(
                      label: 'Outflow',
                      value: '\u20b9${state.totalObligations.toStringAsFixed(0)}',
                      color: AppColors.danger,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Greeting + reliability score ring. Uses the trust-gold accent for the
/// ring itself, since the reliability score is a verification signal.
class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.name, required this.score});

  final String name;
  final int score;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hi, $name', style: AppTextStyles.headline),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentTrustSoft,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 13, color: AppColors.accentTrust),
                          SizedBox(width: 4),
                          Text('Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accentTrust)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your financial identity is portable & tamper-proof.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accentTrust),
                    ),
                  ),
                  Text('$score', style: AppTextStyles.bodyStrong),
                ],
              ),
              const SizedBox(height: 4),
              Text('Reliability', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTextStyles.numericMd),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

/// Minimal bar chart drawn with plain widgets — zero charting-package
/// dependency, cheap to render on low-end devices.
class _IncomeTrendChart extends StatelessWidget {
  const _IncomeTrendChart({
    required this.values,
    required this.labels,
  });

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(height: 140, child: Center(child: Text('No data yet', style: AppTextStyles.bodySmall)));
    }
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 140,
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
                    height: (140 - 28) * ratio.clamp(0.05, 1.0),
                    decoration: BoxDecoration(
                      color: isLast ? AppColors.primary : AppColors.primary.withValues(alpha: 0.35),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(labels[i], style: AppTextStyles.caption),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final double value; // 0.0 - 1.0

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.body),
              Text('${(value * 100).toStringAsFixed(0)}%', style: AppTextStyles.bodyStrong),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeSourceTile extends StatelessWidget {
  const _IncomeSourceTile({required this.source});

  final IncomeSource source;

  @override
  Widget build(BuildContext context) {
    final connected = source.connected;
    final verified = source.verified;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(source.icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(source.name, style: AppTextStyles.bodyStrong),
                Text(source.platformType, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          if (connected && verified)
            const Icon(Icons.verified_rounded, size: 16, color: AppColors.accentTrust)
          else if (!connected)
            Text('Not connected', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _CashFlowTile extends StatelessWidget {
  const _CashFlowTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.numericMd.copyWith(color: color, fontSize: 18)),
      ],
    );
  }
}
