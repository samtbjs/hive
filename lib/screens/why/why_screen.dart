import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/decisions_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';

class WhyScreen extends StatefulWidget {
  const WhyScreen({super.key});

  @override
  State<WhyScreen> createState() => _WhyScreenState();
}

class _WhyScreenState extends State<WhyScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DecisionsProvider>().loadDecisions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DecisionsProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('why'))),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: provider.loadDecisions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
          children: [
            SectionHeader(
              title: context.tr('decisionHistory'),
              subtitle: 'Every non-approval includes clear reasons and a next step',
            ),
            AppCard(
              child: Row(children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.accentTrust),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('Decisions use a fixed reason set so “Rejected” is never a dead end.', style: AppTextStyles.bodySmall)),
              ]),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final decision in provider.decisions) ...[
              _DecisionTile(decision: decision),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _DecisionTile extends StatelessWidget {
  const _DecisionTile({required this.decision});
  final InstitutionDecision decision;

  @override
  Widget build(BuildContext context) {
    final color = _decisionColor(decision.decision);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Icon(_decisionIcon(decision.decision), color: color),
          ),
          title: Text(decision.institutionName, style: AppTextStyles.title),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: Text(_decisionLabel(decision.decision), style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 7),
              Text(_formatDate(decision.decidedOn), style: AppTextStyles.caption),
            ]),
          ),
          children: [
            if (decision.offerSummary != null) ...[
              Align(alignment: Alignment.centerLeft, child: Text(decision.offerSummary!, style: AppTextStyles.bodySmall)),
              const SizedBox(height: AppSpacing.md),
            ],
            if (decision.reasons.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.successSoft, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Row(children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text('No adverse reason was recorded for this approval.', style: AppTextStyles.bodySmall)),
                ]),
              )
            else ...[
              Align(alignment: Alignment.centerLeft, child: Text(context.tr('whatAffectedDecision'), style: AppTextStyles.bodyStrong)),
              const SizedBox(height: AppSpacing.sm),
              for (final reason in decision.reasons) ...[
                _ReasonCard(reason: reason),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ReasonCard extends StatelessWidget {
  const _ReasonCard({required this.reason});
  final DecisionReason reason;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: AppColors.warningSoft.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(AppRadius.md),
      border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.info_outline, color: AppColors.warning, size: 19),
        const SizedBox(width: 7),
        Expanded(child: Text(reason.category.label, style: AppTextStyles.bodyStrong)),
      ]),
      const SizedBox(height: 7),
      Text(reason.explanation, style: AppTextStyles.bodySmall),
      const SizedBox(height: AppSpacing.sm),
      Text(context.tr('nextStep'), style: AppTextStyles.label.copyWith(color: AppColors.primary)),
      const SizedBox(height: 3),
      Text(reason.nextStep, style: AppTextStyles.bodyStrong.copyWith(color: AppColors.primary)),
    ]),
  );
}

Color _decisionColor(String value) {
  switch (value) {
    case 'approved': return AppColors.success;
    case 'rejected': return AppColors.danger;
    default: return AppColors.warning;
  }
}
IconData _decisionIcon(String value) {
  switch (value) {
    case 'approved': return Icons.check_circle_outline;
    case 'rejected': return Icons.cancel_outlined;
    default: return Icons.rule_outlined;
  }
}
String _decisionLabel(String value) {
  switch (value) {
    case 'approved': return 'Approved';
    case 'rejected': return 'Rejected';
    default: return 'Conditional approval';
  }
}
String _formatDate(DateTime value) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}
