import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../utils/dummy_data.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_pill.dart';

class ApplicantDetailScreen extends StatelessWidget {
  final ApplicantSummary applicant;

  const ApplicantDetailScreen({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(applicant.name)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: CircularProgressIndicator(
                              value: applicant.reliabilityScore / 100,
                              strokeWidth: 5,
                              backgroundColor: AppColors.border,
                              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                          Text('${applicant.reliabilityScore}',
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Score', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(applicant.id, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('₹${applicant.monthlyIncome.toStringAsFixed(0)} / month',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 8),
                        StatusPill(label: applicant.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Explainable decision'),
          const Text(
            'Instead of a flat rejection, applicants and reviewers see the specific reasons behind the outcome.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...DummyData.decisionReasonsPositive.map((r) => _ReasonTile(reason: r)),
          ...DummyData.decisionReasonsNegative.map((r) => _ReasonTile(reason: r)),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Verification'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: const [
                  _VerifyRow(label: 'Documents verified', ok: true),
                  Divider(height: 20),
                  _VerifyRow(label: 'Earnings data cross-checked', ok: true),
                  Divider(height: 20),
                  _VerifyRow(label: 'Fraud signals detected', ok: false, warn: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Request more info'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Confirm decision'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final DecisionReason reason;

  const _ReasonTile({required this.reason});

  @override
  Widget build(BuildContext context) {
    final color = reason.isPositive ? AppColors.primary : AppColors.danger;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        child: ListTile(
          leading: Icon(
            reason.isPositive ? Icons.check_circle_outline : Icons.error_outline,
            color: color,
          ),
          title: Text(reason.label, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(reason.detail, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
      ),
    );
  }
}

class _VerifyRow extends StatelessWidget {
  final String label;
  final bool ok;
  final bool warn;

  const _VerifyRow({required this.label, required this.ok, this.warn = false});

  @override
  Widget build(BuildContext context) {
    final color = warn ? AppColors.warning : (ok ? AppColors.primary : AppColors.danger);
    final icon = warn ? Icons.warning_amber_outlined : (ok ? Icons.check_circle_outline : Icons.cancel_outlined);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Icon(icon, color: color, size: 20),
      ],
    );
  }
}
