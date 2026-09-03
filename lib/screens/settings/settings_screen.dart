import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';

/// Placeholder — Settings tab. Will hold profile details, connected
/// accounts management, security/privacy controls, and app preferences.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const EmptyState(
        icon: Icons.settings_outlined,
        title: 'Settings, coming soon',
        message:
            'Profile details, connected accounts and privacy controls '
            'will live here.',
      ),
    );
  }
}
