import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/income_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../credentials/credentials_screen.dart';
import '../sharing/sharing_screen.dart';
import '../why/why_screen.dart';
import '../settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  IncomeProvider? _incomeProvider;
  bool _pollingInitialized = false;

  static const _screens = [
    DashboardScreen(),
    CredentialsScreen(),
    SharingScreen(),
    WhyScreen(),
    SettingsScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _incomeProvider ??= context.read<IncomeProvider>();
    if (!_pollingInitialized) {
      _pollingInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _incomeProvider?.setDashboardVisible(true);
      });
    }
  }

  void _selectTab(int index) {
    if (_index == index) return;
    setState(() => _index = index);
    _incomeProvider?.setDashboardVisible(index == 0);
  }

  @override
  void dispose() {
    _incomeProvider?.setDashboardVisible(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.space_dashboard_outlined), selectedIcon: const Icon(Icons.space_dashboard), label: context.tr('dashboard')),
          NavigationDestination(icon: const Icon(Icons.verified_outlined), selectedIcon: const Icon(Icons.verified), label: context.tr('credentials')),
          NavigationDestination(icon: const Icon(Icons.share_outlined), selectedIcon: const Icon(Icons.share), label: context.tr('sharing')),
          NavigationDestination(icon: const Icon(Icons.help_outline), selectedIcon: const Icon(Icons.help), label: context.tr('why')),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: context.tr('settings')),
        ],
      ),
    );
  }
}
