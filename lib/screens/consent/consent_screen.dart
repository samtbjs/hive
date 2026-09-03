import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/dummy_data.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Sharing & Consent')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: const [
                  Icon(Icons.lock_outline, color: AppColors.primary),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'You control who can access your financial identity. Permissions can be revoked anytime.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...DummyData.institutionAccess.map(
            (inst) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(inst.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(inst.category,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text('Shares: ${inst.scope}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Switch(
                        value: inst.hasAccess,
                        onChanged: (val) {
                          setState(() => inst.hasAccess = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
