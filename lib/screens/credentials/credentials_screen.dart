import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_notifications_provider.dart';
import '../../providers/credentials_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';

class CredentialsScreen extends StatefulWidget {
  const CredentialsScreen({super.key});

  @override
  State<CredentialsScreen> createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends State<CredentialsScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CredentialsProvider>().loadCredentials();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CredentialsProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('credentials'))),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: provider.loadCredentials,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
          children: [
            SectionHeader(
              title: context.tr('verifiedCredentials'),
              subtitle: 'API-generated proofs from connected earnings and payment data',
            ),
            AppCard(
              accentColor: AppColors.accentTrust,
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_outlined, color: AppColors.accentTrust),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Create a fresh proof from your currently verified financial profile.',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton.tonal(
                    onPressed: () async {
                      final credential = await context.read<CredentialsProvider>().generateEarningsCredential();
                      if (!context.mounted) return;
                      context.read<AppNotificationsProvider>().addAlert('✅ ${credential.displayType} generated and verified');
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New verified credential generated.')));
                    },
                    child: Text(context.tr('generateCredential')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (provider.isLoading) const LinearProgressIndicator(minHeight: 3),
            for (final credential in provider.credentials) ...[
              _CredentialCard(
                credential: credential,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CredentialDetailScreen(credentialId: credential.id)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _CredentialCard extends StatelessWidget {
  const _CredentialCard({required this.credential, required this.onTap});
  final Credential credential;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentTrustSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.verified_user_outlined, color: AppColors.accentTrust),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(credential.displayType, style: AppTextStyles.title)),
              _VerifiedBadge(label: context.tr('verified')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(credential.displayPeriod, style: AppTextStyles.bodyStrong),
          const SizedBox(height: 4),
          Text(
            'Generated ${_formatDateTime(credential.generatedAt)}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.lock_outline, size: 15, color: AppColors.success),
              const SizedBox(width: 5),
              Expanded(child: Text('Tamper-evident financial data snapshot', style: AppTextStyles.bodySmall)),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

class CredentialDetailScreen extends StatelessWidget {
  const CredentialDetailScreen({super.key, required this.credentialId});
  final String credentialId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CredentialsProvider>();
    final matches = provider.credentials.where((item) => item.id == credentialId);
    if (matches.isEmpty) {
      return Scaffold(appBar: AppBar(title: Text(context.tr('credentials'))), body: const Center(child: Text('Credential unavailable.')));
    }
    final credential = matches.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Credential detail')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
        children: [
          AppCard(
            accentColor: AppColors.accentTrust,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.verified_rounded, color: AppColors.accentTrust, size: 28),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(credential.displayType, style: AppTextStyles.headline)),
                ]),
                const SizedBox(height: AppSpacing.sm),
                Text(credential.displayPeriod, style: AppTextStyles.bodyStrong),
                const SizedBox(height: 4),
                Text('Generated ${_formatDateTime(credential.generatedAt)}', style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Underlying verified data', subtitle: 'Summary of API-sourced data included in this proof'),
          AppCard(
            child: Column(
              children: credential.dataSummary.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key, style: AppTextStyles.bodySmall)),
                    const SizedBox(width: AppSpacing.md),
                    Text(entry.value, style: AppTextStyles.bodyStrong),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Tamper evidence', subtitle: 'Demo integrity fingerprint for this credential'),
          AppCard(
            accentColor: AppColors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.successSoft, borderRadius: BorderRadius.circular(AppRadius.sm)),
                    child: const Icon(Icons.shield_outlined, color: AppColors.success),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(context.tr('integrityVerified'), style: AppTextStyles.title.copyWith(color: AppColors.success))),
                ]),
                const SizedBox(height: AppSpacing.md),
                Text('Fingerprint', style: AppTextStyles.label),
                const SizedBox(height: 5),
                SelectableText(
                  credential.verificationHash ?? 'vf:demo:verified:7fa21c',
                  style: AppTextStyles.bodySmall.copyWith(fontFamily: 'monospace'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Any change to the represented source data would produce a different fingerprint.', style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () {
              provider.generateShareQr(credential);
              context.read<AppNotificationsProvider>().addAlert('🔐 Secure QR snapshot generated for ${credential.displayType}');
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.background,
                builder: (_) => ChangeNotifierProvider.value(
                  value: provider,
                  child: _QrShareSheet(credential: credential),
                ),
              );
            },
            icon: const Icon(Icons.qr_code_2),
            label: Text('${context.tr('share')} with secure QR'),
          ),
        ],
      ),
    );
  }
}

class _QrShareSheet extends StatelessWidget {
  const _QrShareSheet({required this.credential});
  final Credential credential;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CredentialsProvider>();
    final active = !provider.qrRevoked && provider.remainingSeconds > 0 && provider.qrPayload != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(99))),
            const SizedBox(height: AppSpacing.lg),
            Text('Time-limited verifiable snapshot', style: AppTextStyles.headline, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text('Share only this credential snapshot. It automatically expires after 10 minutes.', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)),
              child: active
                  ? QrImageView(data: provider.qrPayload!, version: QrVersions.auto, size: 190, backgroundColor: Colors.white)
                  : SizedBox(
                      width: 190,
                      height: 190,
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.qr_code_2, size: 60, color: AppColors.textMuted),
                        const SizedBox(height: AppSpacing.sm),
                        Text(provider.qrRevoked ? 'Snapshot revoked' : 'Snapshot expired', style: AppTextStyles.bodyStrong),
                      ]),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(color: active ? AppColors.successSoft : AppColors.dangerSoft, borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Text(
                active ? 'Valid for ${provider.countdownLabel}' : 'Not valid',
                style: AppTextStyles.bodyStrong.copyWith(color: active ? AppColors.success : AppColors.danger),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: active ? provider.revokeQr : null,
                  icon: const Icon(Icons.block_outlined),
                  label: const Text('Revoke'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => provider.regenerateQr(credential),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Regenerate'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: AppColors.successSoft, borderRadius: BorderRadius.circular(AppRadius.pill)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
      const SizedBox(width: 4),
      Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
    ]),
  );
}

String _formatDateTime(DateTime? value) {
  if (value == null) return 'Pending';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
  final minute = value.minute.toString().padLeft(2, '0');
  final meridiem = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.day} ${months[value.month - 1]} ${value.year} · $hour:$minute $meridiem';
}
