import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/institution_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/trust_score_gauge.dart';

class InstitutionPortalShell extends StatelessWidget {
  const InstitutionPortalShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institution Portal'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppRadius.pill)),
            child: Text('Reviewer view', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: const ApplicantListScreen(),
    );
  }
}

class ApplicantListScreen extends StatelessWidget {
  const ApplicantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final applicants = context.watch<InstitutionProvider>().applicants;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
      children: [
        const SectionHeader(
          title: 'Incoming financial identity shares',
          subtitle: 'Review permissioned applicant profiles for underwriting',
        ),
        AppCard(
          child: Row(children: [
            const Icon(Icons.account_balance_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text('Only data explicitly shared by the applicant is shown in this reviewer portal.', style: AppTextStyles.bodySmall)),
          ]),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final applicant in applicants) ...[
          _ApplicantCard(applicant: applicant),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({required this.applicant});
  final InstitutionApplicant applicant;

  @override
  Widget build(BuildContext context) {
    final statusColor = applicant.shareStatus.toLowerCase().contains('active') ? AppColors.success : AppColors.warning;
    return AppCard(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ApplicantDetailScreen(applicantId: applicant.id))),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: const Icon(Icons.person_search_outlined, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(applicant.name, style: AppTextStyles.title),
          const SizedBox(height: 2),
          Text(applicant.id, style: AppTextStyles.caption),
          const SizedBox(height: 5),
          Row(children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(applicant.shareStatus, style: AppTextStyles.caption.copyWith(color: statusColor)),
          ]),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${applicant.trustScore}', style: AppTextStyles.numericMd.copyWith(color: AppColors.accentTrust)),
          Text('Trust Score', style: AppTextStyles.caption),
          if (applicant.decision != null) ...[
            const SizedBox(height: 5),
            Text(_titleCase(applicant.decision!), style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
          ],
        ]),
        const SizedBox(width: AppSpacing.xs),
        const Icon(Icons.chevron_right, color: AppColors.textMuted),
      ]),
    );
  }
}

class ApplicantDetailScreen extends StatelessWidget {
  const ApplicantDetailScreen({super.key, required this.applicantId});
  final String applicantId;

  @override
  Widget build(BuildContext context) {
    final applicant = context.watch<InstitutionProvider>().byId(applicantId);
    if (applicant == null) {
      return Scaffold(appBar: AppBar(title: const Text('Applicant review')), body: const Center(child: Text('Applicant unavailable.')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('${applicant.name} · ${applicant.id}')),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
          decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _chooseReason(context, applicant, 'rejected'),
                icon: const Icon(Icons.close),
                label: const Text('Reject'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _chooseReason(context, applicant, 'approved'),
                icon: const Icon(Icons.check),
                label: const Text('Approve'),
              ),
            ),
          ]),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
        children: [
          AppCard(
            accentColor: AppColors.primary,
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Underwriting snapshot', style: AppTextStyles.headline),
                const SizedBox(height: 5),
                Text('${applicant.shareStatus} · permissioned data only', style: AppTextStyles.bodySmall),
                if (applicant.decision != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text('Recorded decision: ${_titleCase(applicant.decision!)} · ${applicant.decisionReason}', style: AppTextStyles.bodyStrong),
                ],
              ])),
              TrustScoreGauge(score: applicant.trustScore, label: _trustLabel(applicant.trustScore), size: 105),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Reliability profile', subtitle: 'Quick cash-flow and repayment view'),
          _ReviewerReliabilityCard(applicant: applicant),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Shared verifiable credentials', subtitle: 'Applicant-controlled proof references'),
          AppCard(
            child: Column(children: [
              for (var i = 0; i < applicant.sharedCredentials.length; i++) ...[
                Row(children: [
                  const Icon(Icons.verified_outlined, color: AppColors.accentTrust, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(applicant.sharedCredentials[i], style: AppTextStyles.bodyStrong)),
                  const Text('Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                ]),
                if (i != applicant.sharedCredentials.length - 1) const Divider(height: AppSpacing.lg),
              ],
            ]),
          ),
          const SizedBox(height: 92),
        ],
      ),
    );
  }

  void _chooseReason(BuildContext context, InstitutionApplicant applicant, String decision) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_titleCase(decision)} · select reason', style: AppTextStyles.headline),
              const SizedBox(height: 5),
              Text('Uses the same explainability categories shown to applicants in the Why tab.', style: AppTextStyles.bodySmall),
              const SizedBox(height: AppSpacing.md),
              for (final reason in DecisionReasonCategory.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.radio_button_unchecked, color: AppColors.primary),
                  title: Text(reason.label, style: AppTextStyles.bodyStrong),
                  onTap: () {
                    context.read<InstitutionProvider>().decide(applicant.id, decision, reason);
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_titleCase(decision)} recorded with reason: ${reason.label}')));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewerReliabilityCard extends StatelessWidget {
  const _ReviewerReliabilityCard({required this.applicant});
  final InstitutionApplicant applicant;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(children: [
      _MetricRow(label: 'Average monthly income', value: _currency(applicant.averageMonthlyIncome), icon: Icons.trending_up, valueColor: AppColors.success),
      const Divider(height: AppSpacing.lg),
      _MetricRow(label: 'Recurring obligations', value: _currency(applicant.recurringObligations), icon: Icons.receipt_long_outlined),
      const Divider(height: AppSpacing.lg),
      _MetricRow(label: 'Repayment capacity', value: _currency(applicant.repaymentCapacity), icon: Icons.savings_outlined, valueColor: AppColors.primary),
      const Divider(height: AppSpacing.lg),
      Row(children: [
        Expanded(child: _MiniMetric(label: 'Income consistency', value: applicant.incomeConsistency)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _MiniMetric(label: 'On-time payments', value: applicant.paymentConsistency)),
      ]),
    ]),
  );
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value, required this.icon, this.valueColor});
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 20, color: AppColors.primary),
    const SizedBox(width: AppSpacing.sm),
    Expanded(child: Text(label, style: AppTextStyles.bodySmall)),
    Text(value, style: AppTextStyles.bodyStrong.copyWith(color: valueColor)),
  ]);
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.sm),
    decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadius.md)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: AppTextStyles.numericMd),
      const SizedBox(height: 2),
      Text(label, style: AppTextStyles.caption),
    ]),
  );
}

String _currency(double value) => '₹${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
String _titleCase(String value) => value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
String _trustLabel(int score) => score >= 780 ? 'Strong' : (score >= 650 ? 'Reliable' : 'Building');
