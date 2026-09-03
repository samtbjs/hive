import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  final String label;

  const StatusPill({super.key, required this.label});

  Color get _color {
    switch (label.toLowerCase()) {
      case 'verified':
      case 'approved':
      case 'connected':
        return AppColors.primary;
      case 'pending':
      case 'review':
        return AppColors.warning;
      case 'rejected':
      case 'expired':
      case 'not connected':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
