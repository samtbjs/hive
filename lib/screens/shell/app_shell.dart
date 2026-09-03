import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/income_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../credentials/credentials_screen.dart';
import '../sharing/sharing_screen.dart';
import '../why/why_screen.dart';
import '../settings/settings_screen.dart';

/// Hosts the bottom navigation bar and swaps between the 5 primary tabs.
/// Dashboard income polling is explicitly started/stopped here because the
/// IndexedStack keeps every tab mounted even when it is not visible.
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
