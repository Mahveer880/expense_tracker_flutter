import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/transaction_provider.dart';
import '../../widgets/cards/balance_card.dart';
import '../../widgets/cards/expense_card.dart';
import '../transaction/add_transaction_screen.dart';
import '../settings/settings_screen.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/category_filter.dart';
import '../../widgets/common/date_filter.dart';
import '../../providers/currency_provider.dart';
import '../../services/pdf_services.dart';
import '../../services/auth_service.dart';
import '../../providers/budget_provider.dart';

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
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final budgetProvider = context.watch<BudgetProvider>();

    final currentUser = AuthService.getCurrentUser();

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
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Export PDF",
            onPressed: () async {
              await PdfService.generatePdf();
            },
          ),

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
              Text(
                "👋 ${getGreeting()}",
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),

              const SizedBox(height: 8),

              Text(
                currentUser?.name ?? "Guest",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              BalanceCard(balance: provider.balance),

              const SizedBox(height: 20),

              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "💰 Monthly Budget",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Budget: Rs. ${budgetProvider.budget.toStringAsFixed(0)}",
                      ),

                      Text(
                        "Spent: Rs. ${provider.totalExpense.toStringAsFixed(0)}",
                      ),

                      Text(
                        "Remaining: Rs. ${(budgetProvider.budget - provider.totalExpense).toStringAsFixed(0)}",
                      ),

                      const SizedBox(height: 10),

                      LinearProgressIndicator(
                        value: budgetProvider.budget == 0
                            ? 0
                            : (provider.totalExpense / budgetProvider.budget)
                                  .clamp(0.0, 1.0),
                      ),

                      if (budgetProvider.budget > 0 &&
                          provider.totalExpense > budgetProvider.budget)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "⚠ Budget Exceeded",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

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
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: transaction.type == "Income"
                                      ? Colors.green.withOpacity(0.15)
                                      : Colors.red.withOpacity(0.15),
                                  child: Icon(
                                    transaction.type == "Income"
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: transaction.type == "Income"
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction.category,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        transaction.description,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        DateFormat(
                                          "dd MMM yyyy",
                                        ).format(transaction.date),
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${context.watch<CurrencyProvider>().currency} ${transaction.amount.toStringAsFixed(0)}",
                                      style: TextStyle(
                                        color: transaction.type == "Income"
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
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
                                              builder: (_) => AlertDialog(
                                                title: const Text(
                                                  "Delete Transaction",
                                                ),
                                                content: const Text(
                                                  "Are you sure you want to delete this transaction?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                  ],
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
