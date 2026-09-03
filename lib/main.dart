import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_notifications_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/consent_provider.dart';
import 'providers/credentials_provider.dart';
import 'providers/decisions_provider.dart';
import 'providers/financial_reliability_provider.dart';
import 'providers/income_provider.dart';
import 'providers/institution_provider.dart';
import 'providers/language_provider.dart';
import 'providers/obligations_provider.dart';
import 'screens/shell/app_shell.dart';

void main() {
  runApp(const VfidApp());
}

class VfidApp extends StatelessWidget {
  const VfidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AppNotificationsProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()..loadAll()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()),
        ChangeNotifierProvider(create: (_) => ObligationsProvider()..loadObligations()),
        ChangeNotifierProvider(create: (_) => CredentialsProvider()),
        ChangeNotifierProvider(create: (_) => ConsentProvider()),
        ChangeNotifierProvider(create: (_) => DecisionsProvider()),
        ChangeNotifierProvider(create: (_) => InstitutionProvider()),
        ChangeNotifierProxyProvider2<IncomeProvider, ObligationsProvider, FinancialReliabilityProvider>(
          create: (_) => FinancialReliabilityProvider(),
          update: (_, income, obligations, reliability) {
            reliability!.updateInputs(
              transactions: income.transactions,
              recurringObligations: obligations.monthlyRecurringObligations,
              onTimePaymentRate: obligations.onTimePaymentRate,
              usingDemoIncome: income.isUsingDemoData,
            );
            return reliability;
          },
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    return LanguageScope(
      language: language,
      child: MaterialApp(
        title: 'Verifiable Financial Identity',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        locale: Locale(language.code),
        home: const AppShell(),
      ),
    );
  }
}
