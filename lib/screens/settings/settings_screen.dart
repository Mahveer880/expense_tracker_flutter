import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/login_screen.dart';
import '../../providers/theme_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/backup_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();
    final budgetProvider = context.watch<BudgetProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),

      body: ListView(
        children: [
          // ======================================================
          // APPEARANCE
          // ======================================================
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              "Appearance",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            subtitle: const Text("Change app appearance"),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              context.read<ThemeProvider>().toggleTheme(value);
            },
          ),

          const Divider(),

          // ======================================================
          // CURRENCY
          // ======================================================
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text("Currency"),
            subtitle: Text("Current currency: ${currencyProvider.currency}"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              _showCurrencyDialog(context);
            },
          ),

          const Divider(),

          // ======================================================
          // BUDGET
          // ======================================================
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              "Budget",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // -------------------------
          // Monthly Budget
          // -------------------------
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text("Monthly Budget"),
            subtitle: Text(
              budgetProvider.monthlyBudget == 0
                  ? "Not Set"
                  : "${currencyProvider.currency} "
                        "${budgetProvider.monthlyBudget.toStringAsFixed(0)}",
            ),
            trailing: const Icon(Icons.edit),
            onTap: () {
              _showBudgetDialog(context, isMonthly: true);
            },
          ),

          // -------------------------
          // Annual Budget
          // -------------------------
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text("Annual Budget"),
            subtitle: Text(
              budgetProvider.annualBudget == 0
                  ? "Not Set"
                  : "${currencyProvider.currency} "
                        "${budgetProvider.annualBudget.toStringAsFixed(0)}",
            ),
            trailing: const Icon(Icons.edit),
            onTap: () {
              _showBudgetDialog(context, isMonthly: false);
            },
          ),

          const Divider(),

          // ======================================================
          // NOTIFICATIONS
          // ======================================================
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              "Notifications",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Test Notification"),
            subtitle: const Text("Test expense tracker notification"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () async {
              await NotificationService.showTestNotification();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Test notification sent")),
              );
            },
          ),

          const Divider(),

          // ======================================================
          // DATA
          // ======================================================
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              "Data",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // -------------------------
          // Backup
          // -------------------------
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text("Backup Data"),
            subtitle: const Text("Create a backup of your transactions"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () async {
              final success = await BackupService.backupData();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? "Backup created successfully" : "Backup failed",
                  ),
                ),
              );
            },
          ),

          // -------------------------
          // Restore
          // -------------------------
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text("Restore Data"),
            subtitle: const Text("Restore your saved transactions"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () async {
              final success = await BackupService.restoreData();

              if (!context.mounted) return;

              if (success) {
                context.read<TransactionProvider>().loadTransactions();
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? "Data restored successfully"
                        : "Restore cancelled or failed",
                  ),
                ),
              );
            },
          ),

          const Divider(),

          // ======================================================
          // ABOUT
          // ======================================================
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About"),
            subtitle: const Text("About Expense Tracker Pro"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),

          const Divider(),

          // ======================================================
          // LOGOUT
          // ======================================================
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Sign out from this account"),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );

              if (confirm != true) return;

              await AuthService.logout();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENCY DIALOG
  // ============================================================

  void _showCurrencyDialog(BuildContext context) {
    final currencyProvider = context.read<CurrencyProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Select Currency"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _currencyOption(dialogContext, currencyProvider, "Rs."),
              _currencyOption(dialogContext, currencyProvider, "\$"),
              _currencyOption(dialogContext, currencyProvider, "€"),
              _currencyOption(dialogContext, currencyProvider, "£"),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // CURRENCY OPTION
  // ============================================================

  Widget _currencyOption(
    BuildContext dialogContext,
    CurrencyProvider provider,
    String currency,
  ) {
    return ListTile(
      title: Text(currency),
      trailing: provider.currency == currency
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        provider.changeCurrency(currency);

        if (dialogContext.mounted) {
          Navigator.pop(dialogContext);
        }
      },
    );
  }

  // ============================================================
  // BUDGET DIALOG
  // ============================================================

  void _showBudgetDialog(BuildContext context, {required bool isMonthly}) {
    final budgetProvider = context.read<BudgetProvider>();

    final currencyProvider = context.read<CurrencyProvider>();

    final currentValue = isMonthly
        ? budgetProvider.monthlyBudget
        : budgetProvider.annualBudget;

    final controller = TextEditingController(
      text: currentValue == 0 ? "" : currentValue.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isMonthly ? "Set Monthly Budget" : "Set Annual Budget"),

          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: "Budget",
              prefixText: "${currencyProvider.currency} ",
              border: const OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                final value = double.tryParse(controller.text);

                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid budget"),
                    ),
                  );
                  return;
                }

                if (isMonthly) {
                  await budgetProvider.setMonthlyBudget(value);
                } else {
                  await budgetProvider.setAnnualBudget(value);
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
