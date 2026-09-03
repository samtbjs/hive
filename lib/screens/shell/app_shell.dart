import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../credentials/credentials_screen.dart';
import '../sharing/sharing_screen.dart';
import '../why/why_screen.dart';
import '../settings/settings_screen.dart';

/// Hosts the bottom navigation bar and swaps between the 5 primary tabs.
/// Only Dashboard has real, restyled content right now — Credentials,
/// Sharing, Why and Settings are placeholders on the new design system so
/// navigation works end-to-end while those features are built out.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    CredentialsScreen(),
    SharingScreen(),
    WhyScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_outlined),
            selectedIcon: Icon(Icons.verified),
            label: 'Credentials',
          ),
          NavigationDestination(
            icon: Icon(Icons.share_outlined),
            selectedIcon: Icon(Icons.share),
            label: 'Sharing',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help),
            label: 'Why',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
