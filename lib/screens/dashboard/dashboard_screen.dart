import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/income_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final income = context.watch<IncomeProvider>();

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
        onRefresh: income.refreshIncome,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            _GreetingCard(
              name: appState.userName,
              score: appState.reliabilityScore,
            ),
            const SizedBox(height: AppSpacing.lg),

            const SectionHeader(
              title: 'Multi-source income',
              subtitle: 'One ledger across gigs, freelance work & bank inflows',
            ),
            _PeriodSelector(income: income),
            const SizedBox(height: AppSpacing.sm),
            _TotalIncomeCard(income: income),
            const SizedBox(height: AppSpacing.lg),

            SectionHeader(
              title: 'Income by source',
              subtitle: '${income.periodLabel} · updates every 9 seconds',
            ),
            AppCard(
              child: _SourceIncomeChart(
                buckets: income.chartBuckets,
                sources: income.sourcesInPeriod,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            SectionHeader(
              title: 'Unified ledger',
              subtitle: '${income.filteredTransactions.length} transactions · pull down to refresh',
            ),
            if (income.filteredTransactions.isEmpty)
              const AppCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(child: Text('No income transactions in this period.')),
                ),
              )
            else
              _LedgerList(income: income),
            const SizedBox(height: AppSpacing.lg),

            const SectionHeader(title: 'Reliability metrics'),
            const AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MetricRow(label: 'Income stability', value: 0.82),
                  Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                  ),
                  _MetricRow(label: 'Payment consistency', value: 0.91),
                  Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                  ),
                  _MetricRow(
                    label: 'Receivables collected on time',
                    value: 0.68,
                  ),
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
                      label: 'Selected inflow',
                      value: _formatCurrency(income.totalIncome),
                      color: AppColors.success,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  Container(width: 1, height: 44, color: AppColors.divider),
                  Expanded(
                    child: _CashFlowTile(
                      label: 'Obligations',
                      value: _formatCurrency(appState.totalObligations),
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

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.income});

  final IncomeProvider income;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _PeriodChip(
          label: 'This week',
          selected: income.selectedPeriod == IncomePeriod.week,
          onSelected: () => income.setPeriod(IncomePeriod.week),
        ),
        _PeriodChip(
          label: 'This month',
          selected: income.selectedPeriod == IncomePeriod.month,
          onSelected: () => income.setPeriod(IncomePeriod.month),
        ),
        _PeriodChip(
          label: income.selectedPeriod == IncomePeriod.custom
              ? income.periodLabel
              : 'Custom',
          selected: income.selectedPeriod == IncomePeriod.custom,
          icon: Icons.calendar_month_outlined,
          onSelected: () => _pickCustomRange(context, income),
        ),
      ],
    );
  }

  Future<void> _pickCustomRange(
    BuildContext context,
    IncomeProvider income,
  ) async {
    final now = DateTime.now();
    final initialStart = income.customStart ?? DateTime(now.year, now.month, 1);
    final initialEnd = income.customEnd ?? now;

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2, 1, 1),
      lastDate: now,
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
      helpText: 'Select income period',
    );

    if (range != null) {
      income.setCustomRange(range.start, range.end);
    }
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      avatar: icon == null
          ? null
          : Icon(
              icon,
              size: 16,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
      label: Text(label),
      labelStyle: AppTextStyles.label.copyWith(
        color: selected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
      ),
      selectedColor: AppColors.primarySoft,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: selected ? AppColors.primaryLight : AppColors.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

class _TotalIncomeCard extends StatelessWidget {
  const _TotalIncomeCard({required this.income});

  final IncomeProvider income;

  @override
  Widget build(BuildContext context) {
    final sourceCount = income.sourcesInPeriod.length;

    return AppCard(
      accentColor: AppColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 20,
                  color: AppColors.success,
                ),
              ),
              const Spacer(),
              _LiveStatusBadge(isDemo: income.isUsingDemoData),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Total Income', style: AppTextStyles.label),
          const SizedBox(height: 2),
          Text(_formatCurrency(income.totalIncome), style: AppTextStyles.displayNumber),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$sourceCount ${sourceCount == 1 ? 'source' : 'sources'} · ${income.periodLabel}',
            style: AppTextStyles.bodySmall,
          ),
          if (income.isLoading) ...[
            const SizedBox(height: AppSpacing.sm),
            const LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}

class _LiveStatusBadge extends StatelessWidget {
  const _LiveStatusBadge({required this.isDemo});

  final bool isDemo;

  @override
  Widget build(BuildContext context) {
    final color = isDemo ? AppColors.warning : AppColors.success;
    final background = isDemo ? AppColors.warningSoft : AppColors.successSoft;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            isDemo ? 'Demo fallback' : 'Live sync',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceIncomeChart extends StatelessWidget {
  const _SourceIncomeChart({
    required this.buckets,
    required this.sources,
  });

  final List<IncomeChartBucket> buckets;
  final List<String> sources;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty || sources.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text('No income data yet', style: AppTextStyles.bodySmall),
        ),
      );
    }

    final maxTotal = buckets
        .map((bucket) => bucket.total)
        .fold<double>(0, (max, value) => value > max ? value : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (final source in sources)
              _ChartLegendItem(source: source),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 170,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final bucket in buckets)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _StackedIncomeBar(
                      bucket: bucket,
                      sources: sources,
                      maxTotal: maxTotal,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StackedIncomeBar extends StatelessWidget {
  const _StackedIncomeBar({
    required this.bucket,
    required this.sources,
    required this.maxTotal,
  });

  final IncomeChartBucket bucket;
  final List<String> sources;
  final double maxTotal;

  @override
  Widget build(BuildContext context) {
    const maxBarHeight = 128.0;
    final double barHeight = maxTotal <= 0
        ? 0.0
        : (bucket.total / maxTotal * maxBarHeight)
            .clamp(0.0, maxBarHeight)
            .toDouble();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: maxBarHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: bucket.total <= 0
                ? Container(
                    height: 2,
                    width: 22,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                : SizedBox(
                    height: barHeight,
                    width: 26,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          for (final source in sources.reversed)
                            if ((bucket.valuesBySource[source] ?? 0) > 0)
                              Expanded(
                                flex: _segmentFlex(
                                  bucket.valuesBySource[source] ?? 0,
                                  bucket.total,
                                ),
                                child: Container(color: _sourceColor(source)),
                              ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          bucket.label,
          maxLines: 1,
          overflow: TextOverflow.fade,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  int _segmentFlex(double value, double total) {
    if (total <= 0 || value <= 0) return 1;
    final flex = (value / total * 1000).round();
    if (flex < 1) return 1;
    if (flex > 1000) return 1000;
    return flex;
  }
}

class _ChartLegendItem extends StatelessWidget {
  const _ChartLegendItem({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _sourceColor(source),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(_sourceLabel(source), style: AppTextStyles.caption),
      ],
    );
  }
}

class _LedgerList extends StatelessWidget {
  const _LedgerList({required this.income});

  final IncomeProvider income;

  @override
  Widget build(BuildContext context) {
    final transactions = income.filteredTransactions;
    final estimatedHeight = transactions.length * 76.0;
    final height = estimatedHeight < 230
        ? 230.0
        : estimatedHeight > 430
            ? 430.0
            : estimatedHeight;

    return AppCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: height,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: income.refreshIncome,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: transactions.length,
            itemBuilder: (context, index) =>
                _LedgerTile(transaction: transactions[index]),
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              indent: AppSpacing.md,
              endIndent: AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final source = transaction.source;
    final sourceColor = _sourceColor(source);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: sourceColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(_sourceIcon(source), size: 21, color: sourceColor),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        transaction.description?.trim().isNotEmpty == true
                            ? transaction.description!
                            : '${_sourceLabel(source)} income',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyStrong,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _SourceTag(source: source),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(_formatTransactionDate(transaction.date), style: AppTextStyles.caption),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusLabel(status: transaction.status),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '+${_formatCurrency(transaction.amount)}',
            style: AppTextStyles.bodyStrong.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

class _SourceTag extends StatelessWidget {
  const _SourceTag({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final color = _sourceColor(source);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        _sourceLabel(source),
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final pending = normalized == 'pending' || normalized == 'processing';
    final failed = normalized == 'failed' || normalized == 'reversed';
    final color = failed
        ? AppColors.danger
        : pending
            ? AppColors.warning
            : AppColors.success;

    return Text(
      _titleCase(normalized),
      style: AppTextStyles.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentTrustSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: AppColors.accentTrust,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentTrust,
                        ),
                      ),
                    ],
                  ),
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

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final double value;

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
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.bodyStrong,
              ),
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
        Text(
          value,
          style: AppTextStyles.numericMd.copyWith(color: color, fontSize: 18),
        ),
      ],
    );
  }
}

String _sourceLabel(String source) {
  switch (source.toLowerCase()) {
    case 'swiggy':
      return 'Swiggy';
    case 'zomato':
      return 'Zomato';
    case 'uber':
      return 'Uber';
    case 'rapido':
      return 'Rapido';
    case 'upwork':
      return 'Upwork';
    case 'fiverr':
      return 'Fiverr';
    case 'bank':
      return 'Bank';
    default:
      return _titleCase(source);
  }
}

IconData _sourceIcon(String source) {
  switch (source.toLowerCase()) {
    case 'swiggy':
      return Icons.delivery_dining_rounded;
    case 'zomato':
      return Icons.restaurant_rounded;
    case 'uber':
      return Icons.local_taxi_rounded;
    case 'rapido':
      return Icons.two_wheeler_rounded;
    case 'upwork':
    case 'fiverr':
      return Icons.laptop_mac_rounded;
    case 'bank':
      return Icons.account_balance_rounded;
    default:
      return Icons.payments_outlined;
  }
}

Color _sourceColor(String source) {
  switch (source.toLowerCase()) {
    case 'swiggy':
      return AppColors.warning;
    case 'zomato':
      return AppColors.danger;
    case 'uber':
      return AppColors.textPrimary;
    case 'rapido':
      return AppColors.accentTrust;
    case 'upwork':
      return AppColors.success;
    case 'fiverr':
      return AppColors.primaryLight;
    case 'bank':
      return AppColors.primary;
    default:
      return AppColors.textSecondary;
  }
}

String _formatCurrency(double value) {
  final rounded = value.round();
  final raw = rounded.abs().toString();
  final buffer = StringBuffer();

  for (int i = 0; i < raw.length; i++) {
    final remaining = raw.length - i;
    buffer.write(raw[i]);
    if (remaining > 1 && remaining % 3 == 1 && raw.length > 3) {
      buffer.write(',');
    }
  }

  return '${value < 0 ? '-' : ''}₹$buffer';
}

String _formatTransactionDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final now = DateTime.now();
  final year = date.year == now.year ? '' : ' ${date.year}';
  return '${date.day} ${months[date.month - 1]}$year';
}

String _titleCase(String value) {
  if (value.trim().isEmpty) return 'Unknown';
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
