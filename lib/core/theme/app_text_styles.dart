import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography scale for the app. Uses the platform default font family
/// (no external font package dependency) but enforces a strict, deliberate
/// set of weights/sizes so screens stop reading as "default Material text".
class AppTextStyles {
  AppTextStyles._();

  static const _base = TextStyle(
    color: AppColors.textPrimary,
    fontFamily: 'Roboto',
    height: 1.3,
    letterSpacing: -0.1,
  );

  /// Big hero numbers — e.g. reliability score, headline currency figures.
  static final displayNumber = _base.copyWith(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static final headline = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static final title = _base.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );

  static final subtitle = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static final body = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static final bodyStrong = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static final bodySmall = _base.copyWith(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static final label = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  static final caption = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  /// Used for currency / metric values inside cards.
  static final numericMd = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  static final button = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
  );
}
