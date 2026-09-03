import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';

/// Placeholder — Credentials tab. Will list tamper-proof earnings
/// credentials the user has been issued, with share/verify actions.
class CredentialsScreen extends StatelessWidget {
  const CredentialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Credentials')),
      body: const EmptyState(
        icon: Icons.verified_outlined,
        title: 'Credentials, coming soon',
        message:
            'Tamper-proof earnings and payment-history credentials you can '
            'issue and manage will show up here.',
      ),
    );
  }
}
