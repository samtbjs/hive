/// Consistent 4pt-based spacing scale used across the app.
class AppSpacing {
  AppSpacing._();

  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

/// Corner-radius scale. Larger radii read as "friendly/approachable" which
/// suits the earner-facing surfaces; keep radii consistent per component type.
class AppRadius {
  AppRadius._();

  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const pill = 999.0;
}

/// Soft, low-elevation shadow tokens (used instead of Material's default
/// drop shadows, which look muddy on the warm background). Kept cheap
/// (single shadow, small blur) so it stays fast on budget devices.
class AppElevation {
  AppElevation._();

  static const cardShadowColor = 0x14141A21; // ~8% black, ARGB
}
