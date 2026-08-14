import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'services/google_auth_service.dart';

import 'providers/transaction_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/budget_provider.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =========================
  // HIVE INITIALIZATION
  // =========================

  await Hive.initFlutter();

  await Hive.openBox('transactions');
  await Hive.openBox('users');
  await Hive.openBox('session');

  // =========================
  // NOTIFICATION INITIALIZATION
  // =========================

  await NotificationService.init();

  await GoogleAuthService.initialize();

  // =========================
  // RUN APP
  // =========================

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        ChangeNotifierProvider(create: (_) => CurrencyProvider()),

        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],

      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Expense Tracker Pro',

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode: context.watch<ThemeProvider>().themeMode,

      home: const SplashScreen(),
    );
  }
}
