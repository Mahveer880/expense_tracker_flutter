import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/transaction_provider.dart';
import 'dart:math';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Balance : Rs ${provider.balance}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text("Income : Rs ${provider.totalIncome}"),

            Text("Expense : Rs ${provider.totalExpense}"),

            const SizedBox(height: 30),

            const SizedBox(height: 30),

            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: provider.totalIncome,
                      color: Colors.green,
                      title: "Income",
                      radius: 70,
                    ),
                    PieChartSectionData(
                      value: provider.totalExpense,
                      color: Colors.red,
                      title: "Expense",
                      radius: 70,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Monthly Expense Chart",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,

                  maxY: max(
                    100,
                    provider.monthlyExpenses.values.isEmpty
                        ? 100
                        : provider.monthlyExpenses.values.reduce(max) + 1000,
                  ),

                  borderData: FlBorderData(show: false),

                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,

                        getTitlesWidget: (value, meta) {
                          final months = provider.monthlyExpenses.keys.toList();

                          if (value.toInt() >= months.length) {
                            return const SizedBox();
                          }

                          return Text(months[value.toInt()].split("/")[0]);
                        },
                      ),
                    ),
                  ),

                  barGroups: List.generate(provider.monthlyExpenses.length, (
                    index,
                  ) {
                    final value = provider.monthlyExpenses.values.elementAt(
                      index,
                    );

                    return BarChartGroupData(
                      x: index,

                      barRods: [
                        BarChartRodData(
                          toY: value,
                          width: 20,
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.red,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Category Wise Expenses",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.categoryExpenses.length,
              itemBuilder: (context, index) {
                final key = provider.categoryExpenses.keys.elementAt(index);
                final value = provider.categoryExpenses[key]!;

                return Card(
                  child: ListTile(
                    title: Text(key),
                    trailing: Text(
                      "Rs. ${value.toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: const [
                    CircleAvatar(radius: 6, backgroundColor: Colors.green),
                    SizedBox(width: 6),
                    Text("Income"),
                  ],
                ),
                Row(
                  children: const [
                    CircleAvatar(radius: 6, backgroundColor: Colors.red),
                    SizedBox(width: 6),
                    Text("Expense"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
