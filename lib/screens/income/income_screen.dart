import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../utils/dummy_data.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_pill.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final connected = DummyData.incomeSources.where((s) => s.connected).toList();
    final available = DummyData.incomeSources.where((s) => !s.connected).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Income Sources')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            color: AppColors.surfaceAlt,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.stacked_line_chart, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Total aggregated income: ₹${DummyData.totalMonthlyIncome.toStringAsFixed(0)} / month',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Connected sources'),
          ...connected.map((s) => _IncomeTile(source: s)),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Available to connect'),
          ...available.map((s) => _IncomeTile(source: s)),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _IncomeTile extends StatelessWidget {
  final IncomeSource source;

  const _IncomeTile({required this.source});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: AppColors.surfaceAlt,
            child: Text(source.icon, style: const TextStyle(fontSize: 18)),
          ),
          title: Text(source.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(source.type, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          trailing: source.connected
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (source.monthlyAmount > 0)
                      Text('₹${source.monthlyAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const StatusPill(label: 'Connected'),
                  ],
                )
              : OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Connect ${source.name} — UI only, not wired up yet')),
                    );
                  },
                  child: const Text('Connect'),
                ),
        ),
      ),
    );
  }
}
