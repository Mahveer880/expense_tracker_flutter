import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

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

          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notifications"),
            trailing: Icon(Icons.arrow_forward_ios, size: 18),
          ),

          const Divider(),

          const ListTile(
            leading: Icon(Icons.info),
            title: Text("About"),
            trailing: Icon(Icons.arrow_forward_ios, size: 18),
          ),
        ],
      ),
    );
  }
}
