import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/app_notifications_provider.dart';
import '../../providers/consent_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';

class SharingScreen extends StatefulWidget {
  const SharingScreen({super.key});

  @override
  State<SharingScreen> createState() => _SharingScreenState();
}

class _SharingScreenState extends State<SharingScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ConsentProvider>().loadConsents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConsentProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('sharing')),
        actions: [
          TextButton.icon(
            onPressed: () => _showExport(context),
            icon: const Icon(Icons.ios_share_outlined, size: 18),
            label: Text(context.tr('exportProfile')),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: provider.loadConsents,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
          children: [
            SectionHeader(
              title: context.tr('dataAccess'),
              subtitle: 'Choose exactly what each institution can see',
            ),
            AppCard(
              child: Row(children: [
                const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('Income, obligations and credentials are controlled separately. You can revoke access at any time.', style: AppTextStyles.bodySmall)),
              ]),
            ),
            const SizedBox(height: AppSpacing.md),
            if (provider.isLoading) const LinearProgressIndicator(minHeight: 3),
            for (final institution in provider.institutions) ...[
              _InstitutionConsentCard(institution: institution),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }

  void _showExport(BuildContext context) {
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
              Text(context.tr('exportProfile'), style: AppTextStyles.headline),
              const SizedBox(height: AppSpacing.sm),
              Text('Portable summary for lenders, government programs or employers.', style: AppTextStyles.bodySmall),
              const SizedBox(height: AppSpacing.lg),
              const _ExportLine(icon: Icons.payments_outlined, title: 'Verified income summary', subtitle: 'Source totals and consistency'),
              const _ExportLine(icon: Icons.receipt_long_outlined, title: 'Obligations summary', subtitle: 'Recurring commitments and repayment capacity'),
              const _ExportLine(icon: Icons.verified_outlined, title: 'Credential references', subtitle: 'Verification IDs, not uploaded documents'),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Portable profile package prepared for sharing.')));
                  },
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('Prepare export'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstitutionConsentCard extends StatelessWidget {
  const _InstitutionConsentCard({required this.institution});
  final ConsentGrant institution;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(institution.status);
    return AppCard(
      accentColor: institution.status == 'pending' ? AppColors.warning : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Center(child: Text(_initials(institution.institutionName), style: AppTextStyles.bodyStrong.copyWith(color: AppColors.primary))),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(institution.institutionName, style: AppTextStyles.title),
              const SizedBox(height: 2),
              Text('${institution.category} · ${institution.accessLevel}', style: AppTextStyles.caption),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Text(_titleCase(institution.status), style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          Text('Allowed data', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.xs),
          for (final category in ConsentProvider.dataCategories)
            SwitchListTile.adaptive(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(_titleCase(category), style: AppTextStyles.bodyStrong),
              subtitle: Text(_categoryDescription(category), style: AppTextStyles.caption),
              value: institution.hasScope(category),
              onChanged: (value) async {
                await context.read<ConsentProvider>().setCategoryAccess(institution.id, category, value);
                if (!context.mounted) return;
                final action = value ? 'granted' : 'removed';
                context.read<AppNotificationsProvider>().addAlert('🔔 $action ${_titleCase(category)} access for ${institution.institutionName}');
              },
            ),
          const Divider(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: institution.status == 'revoked' ? null : () async {
                await context.read<ConsentProvider>().revokeAccess(institution.id);
                if (!context.mounted) return;
                context.read<AppNotificationsProvider>().addAlert('🔒 Access revoked for ${institution.institutionName}');
              },
              icon: const Icon(Icons.block_outlined),
              label: Text(context.tr('revokeAccess')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportLine extends StatelessWidget {
  const _ExportLine({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [
      Icon(icon, color: AppColors.primary, size: 20),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.bodyStrong), Text(subtitle, style: AppTextStyles.caption)])),
      const Icon(Icons.check_circle, color: AppColors.success, size: 18),
    ]),
  );
}

String _initials(String value) => value.split(' ').where((e) => e.isNotEmpty).take(2).map((e) => e[0]).join().toUpperCase();
String _titleCase(String value) => value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'active': return AppColors.success;
    case 'pending': return AppColors.warning;
    case 'revoked': return AppColors.danger;
    default: return AppColors.textSecondary;
  }
}
String _categoryDescription(String category) {
  switch (category) {
    case 'income': return 'Income totals, sources and consistency';
    case 'obligations': return 'Recurring payments and repayment capacity';
    case 'credentials': return 'Verified credential references';
    default: return '';
  }
}
