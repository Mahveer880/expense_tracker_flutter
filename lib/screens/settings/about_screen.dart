import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.account_balance_wallet, size: 50),
            ),

            SizedBox(height: 20),

            Text(
              "Expense Tracker Pro",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),

            SizedBox(height: 30),

            Text(
              "Expense Tracker Pro helps you manage your income, expenses, budgets and analytics easily.\n\nBuilt with Flutter.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
