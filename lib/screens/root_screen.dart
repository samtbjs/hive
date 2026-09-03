import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'income/income_screen.dart';
import 'credentials/credentials_screen.dart';
import 'consent/consent_screen.dart';
import 'profile/profile_screen.dart';

/// Holds the bottom navigation bar and swaps between the 5 main tabs.
/// Institution portal is reached separately from the Profile tab, since
/// it represents a different persona (bank/lender) rather than a tab
/// for the earner themselves.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    IncomeScreen(),
    CredentialsScreen(),
    ConsentScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Income'),
          NavigationDestination(icon: Icon(Icons.verified_outlined), selectedIcon: Icon(Icons.verified), label: 'Credentials'),
          NavigationDestination(icon: Icon(Icons.privacy_tip_outlined), selectedIcon: Icon(Icons.privacy_tip), label: 'Consent'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
