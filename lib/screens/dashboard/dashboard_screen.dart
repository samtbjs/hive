import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/dummy_data.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/simple_bar_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Greeting + reliability score ring
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hi, ${DummyData.userName}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        const Text('Your financial identity is portable & verified.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                              value: DummyData.reliabilityScore / 100,
                              strokeWidth: 6,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                          Text('${DummyData.reliabilityScore}',
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Reliability', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Stat cards row
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Monthly income',
                  value: '₹${DummyData.totalMonthlyIncome.toStringAsFixed(0)}',
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatCard(
                  label: 'Obligations',
                  value: '₹${DummyData.totalObligations.toStringAsFixed(0)}',
                  icon: Icons.receipt_long,
                  accent: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          const SectionHeader(title: 'Income trend (6 months)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SimpleBarChart(
                values: DummyData.incomeTrend,
                labels: DummyData.incomeTrendLabels,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          const SectionHeader(title: 'Reliability metrics'),
          Card(
            child: Column(
              children: const [
                _MetricRow(label: 'Income stability', value: 0.82),
                Divider(height: 1),
                _MetricRow(label: 'Payment consistency', value: 0.91),
                Divider(height: 1),
                _MetricRow(label: 'Receivables collected on time', value: 0.68),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          const SectionHeader(title: 'Cash flow snapshot'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: const [
                  Expanded(
                    child: _CashFlowTile(label: 'Inflow', value: '₹42,350', color: AppColors.primary),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _CashFlowTile(label: 'Outflow', value: '₹16,800', color: AppColors.danger),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final double value; // 0.0 - 1.0

  const _MetricRow({required this.label, required this.value});

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
              Text(label, style: const TextStyle(fontSize: 13)),
              Text('${(value * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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

class _CashFlowTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CashFlowTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
