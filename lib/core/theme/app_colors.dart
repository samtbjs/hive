import 'package:flutter/material.dart';

/// Centralized color palette for the Verifiable Financial Identity Dashboard.
///
/// Design intent:
/// - `primary` (deep indigo) carries authority/trust for institutions & lenders.
/// - `accentTrust` (warm gold) is reserved ONLY for verification/trust signals
///   (verified badges, credential seals, "cryptographically verified" states).
///   It should never be used as a generic accent — that dilutes its meaning.
/// - Background is a warm off-white (not stark white / not dark) so the app
///   stays legible in bright outdoor light on budget Android screens.
class AppColors {
  AppColors._();

  // Brand / primary
  static const primary = Color(0xFF1E2A5E); // deep indigo
  static const primaryLight = Color(0xFF3B4A94);
  static const primaryDark = Color(0xFF12193B);
  static const primarySoft = Color(0xFFE8EAF3); // tint for chips/backgrounds

  // Trust / verification accent — warm gold, used sparingly & deliberately
  static const accentTrust = Color(0xFFC08829);
  static const accentTrustSoft = Color(0xFFF6ECD8);

  // Semantic
  static const success = Color(0xFF1E8E6F);
  static const successSoft = Color(0xFFE1F2EC);
  static const warning = Color(0xFFDB8A2E);
  static const warningSoft = Color(0xFFFBEEDD);
  static const danger = Color(0xFFC1483A);
  static const dangerSoft = Color(0xFFF6E4E1);

  // Neutrals / surfaces
  static const background = Color(0xFFF7F5F0); // warm off-white
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF1EEE6);
  static const border = Color(0xFFE4E0D3);
  static const divider = Color(0xFFEDEAE0);

  // Text
  static const textPrimary = Color(0xFF1A1F2E);
  static const textSecondary = Color(0xFF60677A);
  static const textMuted = Color(0xFF9A9EA8);
  static const textOnPrimary = Color(0xFFF7F5F0);
  static const textOnAccent = Color(0xFF2A1F06);

  /// Shimmer base/highlight for loading states.
  static const shimmerBase = Color(0xFFEDEAE0);
  static const shimmerHighlight = Color(0xFFF9F7F2);
}
