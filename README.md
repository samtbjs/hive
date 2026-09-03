# Hive — UI Scaffold

Frontend-only Flutter scaffold for the "Verifiable Financial Identity for
Informal & Thin-File Earners" idea. Nothing here calls a real backend —
all data comes from `lib/utils/dummy_data.dart` so you can wire up real
APIs later without touching widget code.

## Run it

```bash
flutter pub get
flutter run
```

## Structure

```
lib/
  main.dart                     entry point, dark theme, starts at splash
  theme/app_theme.dart          colors, spacing, ThemeData
  models/models.dart            plain data classes (IncomeSource, CredentialItem, etc.)
  utils/dummy_data.dart         all mock/fake data — swap for API calls later
  widgets/                      shared UI pieces (stat card, bar chart, status pill, section header)
  screens/
    splash_screen.dart          branding splash
    root_screen.dart            bottom-nav shell, 5 tabs
    dashboard/                  income trend, reliability metrics, cash flow (feature 9)
    income/                     multi-source income aggregation (feature 1)
    credentials/                verifiable credentials list (feature 3)
    consent/                    per-institution access toggles (features 4 & 5)
    profile/                    portable identity summary, entry point to institution portal
    institution/                bank/lender side: applicant list (feature 10),
                                 explainable decision + thin-file assessment (features 7 & 8)
```

## Notes

- No charting package dependency — `SimpleBarChart` is hand-rolled so there's
  nothing extra to pub-get if you're offline. Swap for `fl_chart` if you want
  animations/tooltips later.
- Buttons like "Connect", "Generate credential", "Confirm decision" just show
  a SnackBar or do nothing — hook up real logic when the backend exists.
- Consent toggles mutate the in-memory dummy list only (no persistence).
