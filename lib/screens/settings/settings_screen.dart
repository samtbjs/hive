import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_notifications_provider.dart';
import '../../providers/language_provider.dart';
import '../../screens/institution/institution_portal.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    final alerts = context.watch<AppNotificationsProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
        children: [
          const SectionHeader(title: 'Vernacular mode', subtitle: 'Change key app screens to your preferred language'),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('App language', style: AppTextStyles.bodyStrong),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<AppLanguage>(
                initialValue: language.language,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.translate), isDense: true),
                items: AppLanguage.values.map((item) => DropdownMenuItem(value: item, child: Text(item.nativeName))).toList(),
                onChanged: (value) {
                  if (value != null) context.read<LanguageProvider>().setLanguage(value);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Applied app-wide to key Dashboard, Credentials, Sharing and Why labels.', style: AppTextStyles.caption),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'WhatsApp notification bridge', subtitle: 'Demo alert thread — no real WhatsApp API connection'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              SwitchListTile.adaptive(
                title: Text('WhatsApp Alerts', style: AppTextStyles.title),
                subtitle: Text(alerts.whatsAppAlertsEnabled ? 'Mock financial alerts are enabled' : 'Mock financial alerts are paused', style: AppTextStyles.caption),
                value: alerts.whatsAppAlertsEnabled,
                onChanged: alerts.setWhatsAppAlerts,
              ),
              const Divider(height: 1),
              SizedBox(
                height: 340,
                child: Container(
                  color: const Color(0xFFEFEAE2),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: ListView.builder(
                    reverse: true,
                    itemCount: alerts.messages.length,
                    itemBuilder: (context, reverseIndex) {
                      final index = alerts.messages.length - 1 - reverseIndex;
                      return _WhatsAppBubble(message: alerts.messages[index].message, timestamp: alerts.messages[index].timestamp);
                    },
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Role', subtitle: 'Demo the lender/reviewer side of the same platform'),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: const Icon(Icons.account_balance_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Institution / Lender Portal', style: AppTextStyles.title),
                  const SizedBox(height: 3),
                  Text('Review permissioned applicant profiles and record decisions.', style: AppTextStyles.bodySmall),
                ])),
              ]),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InstitutionPortalShell())),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Switch to Institution View'),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _WhatsAppBubble extends StatelessWidget {
  const _WhatsAppBubble({required this.message, required this.timestamp});
  final String message;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.only(bottom: 8, left: 36),
        padding: const EdgeInsets.fromLTRB(11, 8, 8, 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD9FDD3),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
          Flexible(child: Text(message, style: const TextStyle(fontSize: 13.5, color: Color(0xFF111B21), height: 1.35))),
          const SizedBox(width: 8),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(_time(timestamp), style: const TextStyle(fontSize: 10, color: Color(0xFF667781))),
            const SizedBox(width: 3),
            const Icon(Icons.done_all, size: 14, color: Color(0xFF53BDEB)),
          ]),
        ]),
      ),
    );
  }

  String _time(DateTime value) {
    final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${value.hour >= 12 ? 'PM' : 'AM'}';
  }
}
