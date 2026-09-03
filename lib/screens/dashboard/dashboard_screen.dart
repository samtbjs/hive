import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/obligations_provider.dart';
import '../../providers/financial_reliability_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final income = context.watch<IncomeProvider>();
    final obligations = context.watch<ObligationsProvider>();
    final reliability = context.watch<FinancialReliabilityProvider>();

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
        onRefresh: () async {
          await Future.wait([income.refreshIncome(), obligations.refresh()]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            _GreetingCard(name: appState.userName),
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

            const SectionHeader(
              title: 'Financial reliability profile',
              subtitle: 'Cash flow, obligations and repayment strength',
            ),
            _ReliabilityPeriodSelector(reliability: reliability),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: _CashFlowTrendCard(reliability: reliability),
            ),
            const SizedBox(height: AppSpacing.md),
            _RepaymentCapacityCard(reliability: reliability),
            const SizedBox(height: AppSpacing.md),
            _ObligationsAndReceivablesCard(obligations: obligations),
            const SizedBox(height: AppSpacing.lg),

            const SectionHeader(
              title: 'Trust Score',
              subtitle: 'An explainable alternative-credit signal',
            ),
            _TrustScoreCard(reliability: reliability),
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

class _ReliabilityPeriodSelector extends StatelessWidget {
  const _ReliabilityPeriodSelector({required this.reliability});

  final FinancialReliabilityProvider reliability;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        _PeriodChip(
          label: 'Weekly',
          selected: reliability.selectedPeriod == ReliabilityPeriod.weekly,
          onSelected: () => reliability.setPeriod(ReliabilityPeriod.weekly),
        ),
        _PeriodChip(
          label: 'Monthly',
          selected: reliability.selectedPeriod == ReliabilityPeriod.monthly,
          onSelected: () => reliability.setPeriod(ReliabilityPeriod.monthly),
        ),
      ],
    );
  }
}

class _CashFlowTrendCard extends StatelessWidget {
  const _CashFlowTrendCard({required this.reliability});

  final FinancialReliabilityProvider reliability;

  @override
  Widget build(BuildContext context) {
    final points = reliability.cashFlowPoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Cash flow trend', style: AppTextStyles.title),
            const Spacer(),
            _CashFlowLegend(color: AppColors.success, label: 'Income'),
            const SizedBox(width: 10),
            _CashFlowLegend(color: AppColors.danger, label: 'Outflow'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 170,
          width: double.infinity,
          child: CustomPaint(
            painter: _CashFlowTrendPainter(points: points),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (final point in points)
              Expanded(
                child: Text(
                  point.label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CashFlowLegend extends StatelessWidget {
  const _CashFlowLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _CashFlowTrendPainter extends CustomPainter {
  _CashFlowTrendPainter({required this.points});

  final List<CashFlowPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    var maxValue = 0.0;
    for (final point in points) {
      if (point.income > maxValue) maxValue = point.income;
      if (point.outflow > maxValue) maxValue = point.outflow;
    }
    if (maxValue <= 0) return;

    final usableHeight = size.height - 12;
    final stepX = points.length == 1 ? 0.0 : size.width / (points.length - 1);

    Offset pointFor(int index, double value) {
      final x = points.length == 1 ? size.width / 2 : index * stepX;
      final y = usableHeight - (value / maxValue * usableHeight) + 6;
      return Offset(x, y);
    }

    final incomePath = Path();
    final outflowPath = Path();

    for (var i = 0; i < points.length; i++) {
      final incomePoint = pointFor(i, points[i].income);
      final outflowPoint = pointFor(i, points[i].outflow);

      if (i == 0) {
        incomePath.moveTo(incomePoint.dx, incomePoint.dy);
        outflowPath.moveTo(outflowPoint.dx, outflowPoint.dy);
      } else {
        incomePath.lineTo(incomePoint.dx, incomePoint.dy);
        outflowPath.lineTo(outflowPoint.dx, outflowPoint.dy);
      }
    }

    final incomePaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final outflowPaint = Paint()
      ..color = AppColors.danger
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(incomePath, incomePaint);
    canvas.drawPath(outflowPath, outflowPaint);

    final incomeDotPaint = Paint()..color = AppColors.success;
    final outflowDotPaint = Paint()..color = AppColors.danger;
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(pointFor(i, points[i].income), 4, incomeDotPaint);
      canvas.drawCircle(pointFor(i, points[i].outflow), 4, outflowDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CashFlowTrendPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

class _RepaymentCapacityCard extends StatelessWidget {
  const _RepaymentCapacityCard({required this.reliability});

  final FinancialReliabilityProvider reliability;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Repayment Capacity', style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _formatCurrency(reliability.repaymentCapacity),
            style: AppTextStyles.displayNumber.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            'Estimated amount left each month after regular obligations, based on recent average income.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Avg. income ${_formatCurrency(reliability.averageMonthlyIncome)}  ·  Regular obligations ${_formatCurrency(reliability.averageRecurringObligations)}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _ObligationsAndReceivablesCard extends StatelessWidget {
  const _ObligationsAndReceivablesCard({required this.obligations});

  final ObligationsProvider obligations;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text('Recurring payments', style: AppTextStyles.title),
                const Spacer(),
                Text(
                  _formatCurrency(obligations.monthlyRecurringObligations),
                  style: AppTextStyles.bodyStrong,
                ),
              ],
            ),
          ),
          for (var i = 0; i < obligations.obligations.length; i++) ...[
            _FinancialItemRow(
              icon: _obligationIcon(obligations.obligations[i].type),
              title: obligations.obligations[i].name,
              subtitle: 'Due ${_formatDueDate(obligations.obligations[i].dueDate)}',
              amount: obligations.obligations[i].amount,
              status: obligations.obligations[i].status,
            ),
            if (i != obligations.obligations.length - 1)
              const Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
              ),
          ],
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text('Outstanding receivables', style: AppTextStyles.title),
                const Spacer(),
                Text(
                  _formatCurrency(obligations.outstandingReceivables),
                  style: AppTextStyles.bodyStrong.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ),
          for (var i = 0; i < obligations.receivables.length; i++) ...[
            _FinancialItemRow(
              icon: Icons.request_quote_outlined,
              title: obligations.receivables[i].name,
              subtitle:
                  '${obligations.receivables[i].source} · Due ${_formatDueDate(obligations.receivables[i].dueDate)}',
              amount: obligations.receivables[i].amount,
              status: obligations.receivables[i].status,
              receivable: true,
            ),
            if (i != obligations.receivables.length - 1)
              const Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
              ),
          ],
          if (obligations.isLoading)
            const LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
        ],
      ),
    );
  }
}

class _FinancialItemRow extends StatelessWidget {
  const _FinancialItemRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    this.receivable = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double amount;
  final String status;
  final bool receivable;

  @override
  Widget build(BuildContext context) {
    final statusColor = _financialStatusColor(status);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 11,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (receivable ? AppColors.success : AppColors.primary)
                  .withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              size: 20,
              color: receivable ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyStrong),
                const SizedBox(height: 3),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(amount),
                style: AppTextStyles.bodyStrong.copyWith(
                  color: receivable ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  _titleCase(status),
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustScoreCard extends StatelessWidget {
  const _TrustScoreCard({required this.reliability});

  final FinancialReliabilityProvider reliability;

  @override
  Widget build(BuildContext context) {
    final progress = ((reliability.trustScore - 300) / 600)
        .clamp(0.0, 1.0)
        .toDouble();

    return AppCard(
      accentColor: AppColors.accentTrust,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 138,
                  height: 138,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 11,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.border,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.accentTrust),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${reliability.trustScore}',
                      style: AppTextStyles.displayNumber,
                    ),
                    Text('out of 900', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentTrustSoft,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                reliability.trustLabel,
                style: AppTextStyles.bodyStrong.copyWith(
                  color: AppColors.accentTrust,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('What is driving this score', style: AppTextStyles.bodyStrong),
          const SizedBox(height: AppSpacing.sm),
          for (final factor in reliability.trustFactors) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 15,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(child: Text(factor, style: AppTextStyles.bodySmall)),
              ],
            ),
            const SizedBox(height: 7),
          ],
          const Divider(height: AppSpacing.lg),
          Text(
            'Demo formula: 60% on-time payments + 40% income consistency.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

/// Greeting card for the portable verified identity profile.
class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.name});

  final String name;

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
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.accentTrustSoft,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentTrust),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.accentTrust,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _obligationIcon(String type) {
  switch (type.toLowerCase()) {
    case 'rent':
      return Icons.home_outlined;
    case 'emi':
    case 'loan':
      return Icons.account_balance_outlined;
    case 'utility':
      return Icons.bolt_outlined;
    default:
      return Icons.receipt_long_outlined;
  }
}

Color _financialStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'paid':
      return AppColors.success;
    case 'overdue':
      return AppColors.danger;
    default:
      return AppColors.warning;
  }
}

String _formatDueDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${date.day} ${months[date.month - 1]}';
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
