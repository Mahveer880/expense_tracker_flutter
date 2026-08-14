import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/currency_provider.dart';
import '../../providers/transaction_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final currencyProvider = context.watch<CurrencyProvider>();

    final currency = currencyProvider.currency;

    final income = provider.totalIncome;
    final expense = provider.totalExpense;
    final balance = provider.balance;

    return Scaffold(
      appBar: AppBar(title: const Text("Analytics"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Financial Overview",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // =========================
            // SUMMARY CARDS
            // =========================
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: "Income",
                    amount: income,
                    currency: currency,
                    icon: Icons.arrow_downward,
                    iconColor: Colors.green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _SummaryCard(
                    title: "Expense",
                    amount: expense,
                    currency: currency,
                    icon: Icons.arrow_upward,
                    iconColor: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _SummaryCard(
              title: "Balance",
              amount: balance,
              currency: currency,
              icon: Icons.account_balance_wallet,
              iconColor: balance >= 0 ? Colors.green : Colors.red,
              fullWidth: true,
            ),

            const SizedBox(height: 30),

            // =========================
            // INCOME VS EXPENSE
            // =========================
            const Text(
              "Income vs Expense",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: SizedBox(
                  height: 250,

                  child: income == 0 && expense == 0
                      ? const Center(
                          child: Text("No transaction data available"),
                        )
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 45,

                            sections: [
                              if (income > 0)
                                PieChartSectionData(
                                  value: income,
                                  title: "Income",
                                  radius: 75,
                                  color: Colors.green,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              if (expense > 0)
                                PieChartSectionData(
                                  value: expense,
                                  title: "Expense",
                                  radius: 75,
                                  color: Colors.red,
                                  titleStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Legend(color: Colors.green, text: "Income"),

                const SizedBox(width: 25),

                _Legend(color: Colors.red, text: "Expense"),
              ],
            ),

            const SizedBox(height: 35),

            // =========================
            // MONTHLY EXPENSE
            // =========================
            const Text(
              "Monthly Expenses",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),

                child: SizedBox(
                  height: 280,

                  child: provider.monthlyExpenses.isEmpty
                      ? const Center(child: Text("No monthly expense data"))
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,

                            borderData: FlBorderData(show: false),

                            gridData: const FlGridData(show: true),

                            maxY: max(
                              100,
                              provider.monthlyExpenses.values.reduce(max) + 500,
                            ),

                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),

                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),

                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,

                                  getTitlesWidget: (value, meta) {
                                    final months = provider.monthlyExpenses.keys
                                        .toList();

                                    final index = value.toInt();

                                    if (index < 0 || index >= months.length) {
                                      return const SizedBox();
                                    }

                                    final parts = months[index].split("/");

                                    return Text(
                                      parts[0],
                                      style: const TextStyle(fontSize: 11),
                                    );
                                  },
                                ),
                              ),

                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 45,
                                ),
                              ),
                            ),

                            barGroups: List.generate(
                              provider.monthlyExpenses.length,

                              (index) {
                                final value = provider.monthlyExpenses.values
                                    .elementAt(index);

                                return BarChartGroupData(
                                  x: index,

                                  barRods: [
                                    BarChartRodData(
                                      toY: value,
                                      width: 20,
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 35),

            // =========================
            // CATEGORY EXPENSES
            // =========================
            const Text(
              "Category Wise Expenses",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            if (provider.categoryExpenses.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: Text("No expense categories available")),
                ),
              )
            else
              ...provider.categoryExpenses.entries.map((entry) {
                final percentage = expense == 0 ? 0.0 : entry.value / expense;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),

                  child: Padding(
                    padding: const EdgeInsets.all(15),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Text(
                              "$currency ${entry.value.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        LinearProgressIndicator(
                          value: percentage.clamp(0.0, 1.0),
                        ),

                        const SizedBox(height: 5),

                        Align(
                          alignment: Alignment.centerRight,

                          child: Text(
                            "${(percentage * 100).toStringAsFixed(1)}%",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// SUMMARY CARD
// =====================================================

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;
  final IconData icon;
  final Color iconColor;
  final bool fullWidth;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.currency,
    required this.icon,
    required this.iconColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.15),

              child: Icon(icon, color: iconColor),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(title, style: TextStyle(color: Colors.grey.shade600)),

                  const SizedBox(height: 4),

                  Text(
                    "$currency ${amount.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 19,
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

// =====================================================
// LEGEND
// =====================================================

class _Legend extends StatelessWidget {
  final Color color;
  final String text;

  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),

        const SizedBox(width: 6),

        Text(text),
      ],
    );
  }
}
