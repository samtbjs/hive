import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/dummy_data.dart';
import '../../widgets/section_header.dart';
import '../institution/institution_portal_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.surfaceAlt,
                  child: Icon(Icons.person, size: 40, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(DummyData.userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                const Text('ID: VF-10293', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Portable financial identity'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                'One profile usable across banks, NBFCs, insurers, employers, and government programmes.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Thin-file assessment'),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Evaluated using alternative financial signals since little or no traditional credit history is available.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ListTile(
            tileColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            leading: const Icon(Icons.business_outlined, color: AppColors.primary),
            title: const Text('Institution Portal'),
            subtitle: const Text('Preview the bank / lender side of the app',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InstitutionPortalScreen()),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text('Log out', style: TextStyle(color: AppColors.danger)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
