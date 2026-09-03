import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_state_provider.dart';
import 'screens/shell/app_shell.dart';

void main() {
  runApp(const VfidApp());
}

/// Root widget. MultiProvider is set up here so future feature providers
/// (income, credentials, sharing, etc.) can be added alongside
/// [AppStateProvider] without touching anything downstream.
class VfidApp extends StatelessWidget {
  const VfidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()..loadAll()),
      ],
      child: MaterialApp(
        title: 'Verifiable Financial Identity',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        home: const AppShell(),
      ),
    );
  }
}
