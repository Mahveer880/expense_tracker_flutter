import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/login_screen.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/backup_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../providers/budget_provider.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final budgetProvider = context.watch<BudgetProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              context.read<ThemeProvider>().toggleTheme(value);
            },
          ),

          const Divider(),

          const ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text("Currency"),
            trailing: Icon(Icons.arrow_forward_ios, size: 18),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text("Monthly Budget"),
            subtitle: Text(
              budgetProvider.budget == 0
                  ? "Not Set"
                  : "Rs. ${budgetProvider.budget.toStringAsFixed(0)}",
            ),
            trailing: const Icon(Icons.edit),
            onTap: () {
              final controller = TextEditingController(
                text: budgetProvider.budget == 0
                    ? ""
                    : budgetProvider.budget.toStringAsFixed(0),
              );

              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Set Monthly Budget"),
                    content: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Budget",
                        prefixText: "Rs. ",
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final value = double.tryParse(controller.text);

                          if (value != null) {
                            await context.read<BudgetProvider>().setBudget(
                              value,
                            );
                          }

                          Navigator.pop(context);
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const Divider(),

          const ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text("Currency"),
            trailing: Icon(Icons.arrow_forward_ios, size: 18),
          ),

          const Divider(),

          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notifications"),
            trailing: Icon(Icons.arrow_forward_ios, size: 18),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text("Backup Data"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () async {
              await BackupService.backupData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Backup created successfully")),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text("Restore Data"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () async {
              await BackupService.restoreData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data restored successfully")),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Test Notification"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () async {
              await NotificationService.showTestNotification();
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () async {
              await AuthService.logout();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
