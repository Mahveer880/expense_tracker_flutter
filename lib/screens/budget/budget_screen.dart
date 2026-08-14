import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/currency_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();

    final currency = currencyProvider.currency;

    final monthlyBudget = budgetProvider.monthlyBudget;
    final monthlySpent = transactionProvider.currentMonthExpense;
    final monthlyRemaining = monthlyBudget - monthlySpent;

    final annualBudget = budgetProvider.annualBudget;
    final annualSpent = transactionProvider.currentYearExpense;
    final annualRemaining = annualBudget - annualSpent;

    final monthlyProgress = monthlyBudget <= 0
        ? 0.0
        : (monthlySpent / monthlyBudget).clamp(0.0, 1.0);

    final annualProgress = annualBudget <= 0
        ? 0.0
        : (annualSpent / annualBudget).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text("Budget"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Manage Your Budget",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Track your monthly and yearly spending.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),

            const SizedBox(height: 25),

            // =========================
            // MONTHLY BUDGET
            // =========================
            _BudgetCard(
              title: "Monthly Budget",
              icon: Icons.calendar_month,
              budget: monthlyBudget,
              spent: monthlySpent,
              remaining: monthlyRemaining,
              progress: monthlyProgress,
              currency: currency,
              onEdit: () {
                _showBudgetDialog(
                  context,
                  title: "Set Monthly Budget",
                  currentValue: monthlyBudget,
                  onSave: (value) async {
                    await context.read<BudgetProvider>().setMonthlyBudget(
                      value,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // =========================
            // ANNUAL BUDGET
            // =========================
            _BudgetCard(
              title: "Annual Budget",
              icon: Icons.calendar_today,
              budget: annualBudget,
              spent: annualSpent,
              remaining: annualRemaining,
              progress: annualProgress,
              currency: currency,
              onEdit: () {
                _showBudgetDialog(
                  context,
                  title: "Set Annual Budget",
                  currentValue: annualBudget,
                  onSave: (value) async {
                    await context.read<BudgetProvider>().setAnnualBudget(value);
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            // =========================
            // QUICK SUMMARY
            // =========================
            const Text(
              "Budget Summary",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: "This Month",
                    amount: monthlySpent,
                    currency: currency,
                    icon: Icons.trending_down,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _SummaryCard(
                    title: "This Year",
                    amount: annualSpent,
                    currency: currency,
                    icon: Icons.bar_chart,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // BUDGET DIALOG
  // =========================

  void _showBudgetDialog(
    BuildContext context, {
    required String title,
    required double currentValue,
    required Future<void> Function(double value) onSave,
  }) {
    final controller = TextEditingController(
      text: currentValue == 0 ? "" : currentValue.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),

          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Budget Amount",
              prefixText: "Rs. ",
              border: OutlineInputBorder(),
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

                await onSave(value);

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

// ======================================================
// BUDGET CARD
// ======================================================

class _BudgetCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final double budget;
  final double spent;
  final double remaining;
  final double progress;
  final String currency;
  final VoidCallback onEdit;

  const _BudgetCard({
    required this.title,
    required this.icon,
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.progress,
    required this.currency,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final exceeded = budget > 0 && spent > budget;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(icon)),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  tooltip: "Edit Budget",
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text("Budget", style: TextStyle(color: Colors.grey.shade600)),

            Text(
              "$currency ${budget.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Spent: $currency ${spent.toStringAsFixed(0)}"),

                Text(
                  "Remaining: $currency ${remaining.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: remaining < 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              borderRadius: BorderRadius.circular(10),
            ),

            if (budget == 0)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  "No budget set yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            if (exceeded)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red),

                    SizedBox(width: 6),

                    Text(
                      "Budget Exceeded!",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// SUMMARY CARD
// ======================================================

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.currency,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Icon(icon),

            const SizedBox(height: 12),

            Text(title, style: TextStyle(color: Colors.grey.shade600)),

            const SizedBox(height: 5),

            Text(
              "$currency ${amount.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
