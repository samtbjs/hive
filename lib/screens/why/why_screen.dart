import 'package:flutter/material.dart';
import '../../widgets/empty_state.dart';

/// Placeholder — Why tab. Will explain, in plain language, the reasons
/// behind an institution's decision (approved/rejected/under review) so
/// the user always understands what drove the outcome.
class WhyScreen extends StatelessWidget {
  const WhyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Why')),
      body: const EmptyState(
        icon: Icons.help_outline,
        title: 'Explainability, coming soon',
        message:
            'Plain-language reasons behind lender decisions on your '
            'applications will show up here.',
      ),
    );
  }
}
