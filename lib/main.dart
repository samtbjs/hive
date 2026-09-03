import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_state_provider.dart';
import 'providers/income_provider.dart';
import 'screens/shell/app_shell.dart';

void main() {
  runApp(const VfidApp());
}

/// Root widget. Feature-specific providers live alongside [AppStateProvider]
/// so each tab can manage its own API state without bloating the app-root
/// provider.
class VfidApp extends StatelessWidget {
  const VfidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()..loadAll()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()),
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
