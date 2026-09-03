import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';

/// Placeholder — Sharing tab. Will let the user grant/revoke consent for
/// institutions to view specific slices of their verified financial
/// profile, with full control over scope and duration.
class SharingScreen extends StatelessWidget {
  const SharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sharing')),
      body: const EmptyState(
        icon: Icons.share_outlined,
        title: 'Sharing controls, coming soon',
        message:
            'Grant or revoke lender and institution access to your '
            'verified profile, with full control over what\u2019s shared.',
      ),
    );
  }
}
