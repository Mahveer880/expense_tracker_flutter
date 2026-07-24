import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/transaction_provider.dart';
import '../../widgets/cards/balance_card.dart';
import '../../widgets/cards/expense_card.dart';
import '../transaction/add_transaction_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/category_filter.dart';
import '../../widgets/common/date_filter.dart';
import '../../providers/currency_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final TextEditingController searchController = TextEditingController();

String searchText = "";
String selectedCategory = "All";

DateTime? startDate;
DateTime? endDate;

final List<String> categories = [
  "All",
  "Salary",
  "Business",
  "Freelance",
  "Gift",
  "Food",
  "Shopping",
  "Fuel",
  "Bills",
  "Transport",
  "Medical",
  "Entertainment",
  "Family & Friends",
  "Education",
  "Travel",
  "Investment",
  "Family Fund",
  "Other",
];

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final filteredTransactions = provider.transactions.where((transaction) {
      // Search Filter
      final matchesSearch =
          transaction.category.toLowerCase().contains(searchText) ||
          transaction.description.toLowerCase().contains(searchText);

      // Category Filter
      final matchesCategory =
          selectedCategory == "All" || transaction.category == selectedCategory;

      // Date Filter
      final matchesStartDate =
          startDate == null || !transaction.date.isBefore(startDate!);

      final matchesEndDate =
          endDate == null || !transaction.date.isAfter(endDate!);

      return matchesSearch &&
          matchesCategory &&
          matchesStartDate &&
          matchesEndDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "👋 Good Morning",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),

              const SizedBox(height: 8),

              const Text(
                "Mahveer",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              BalanceCard(balance: provider.balance),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ExpenseCard(
                      title: "Income",
                      amount: provider.totalIncome,
                      icon: Icons.arrow_downward,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: ExpenseCard(
                      title: "Expense",
                      amount: provider.totalExpense,
                      icon: Icons.arrow_upward,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              SearchBarWidget(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
              ),

              const SizedBox(height: 15),

              CategoryFilter(
                selectedCategory: selectedCategory,
                categories: categories,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  DateFilter(
                    title: "Start Date",
                    selectedDate: startDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                        });
                      }
                    },
                  ),

                  const SizedBox(width: 10),

                  DateFilter(
                    title: "End Date",
                    selectedDate: endDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search Transactions",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
              ),

              const SizedBox(height: 15),

              provider.transactions.isEmpty
                  ? const Card(
                      child: ListTile(
                        leading: Icon(Icons.receipt_long),
                        title: Text("No transactions yet"),
                        subtitle: Text("Add your first transaction"),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Icon(
                                transaction.type == "Income"
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                              ),
                            ),

                            title: Text(transaction.category),

                            subtitle: Text(transaction.description),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${context.watch<CurrencyProvider>().currency} ${transaction.amount}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddTransactionScreen(
                                              transaction: transaction,
                                              index: index,
                                            ),
                                      ),
                                    );
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text(
                                            "Delete Transaction",
                                          ),
                                          content: const Text(
                                            "Are you sure you want to delete this transaction?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirm == true) {
                                      await context
                                          .read<TransactionProvider>()
                                          .deleteTransaction(index);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
