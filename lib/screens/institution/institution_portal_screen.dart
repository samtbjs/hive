import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../utils/dummy_data.dart';
import '../../widgets/status_pill.dart';
import 'applicant_detail_screen.dart';

class InstitutionPortalScreen extends StatelessWidget {
  const InstitutionPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Institution Portal')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search applicant by name or ID',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: DummyData.applicants.length,
              itemBuilder: (context, index) {
                final a = DummyData.applicants[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.surfaceAlt,
                        child: Text('${a.reliabilityScore}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                      title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${a.id} · ₹${a.monthlyIncome.toStringAsFixed(0)}/mo',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      trailing: StatusPill(label: a.status),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ApplicantDetailScreen(applicant: a)),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
