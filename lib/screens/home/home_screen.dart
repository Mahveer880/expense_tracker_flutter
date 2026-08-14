import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/transaction_provider.dart';
import '../../widgets/cards/balance_card.dart';
import '../../widgets/cards/expense_card.dart';
import '../transaction/add_transaction_screen.dart';
import '../../widgets/common/search_bar.dart';
import '../../widgets/common/category_filter.dart';
import '../../widgets/common/date_filter.dart';
import '../../providers/currency_provider.dart';
import '../../services/pdf_services.dart';
import '../../services/auth_service.dart';
import '../settings/settings_screen.dart';
import '../analytics/analytics_screen.dart';
import '../budget/budget_screen.dart';

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
  String selectedType = "All";

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good night";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final currentUser = AuthService.getCurrentUser();

    final filteredTransactions = provider.transactions.where((transaction) {
      // =========================
      // SEARCH FILTER
      // =========================

      final matchesSearch =
          transaction.category.toLowerCase().contains(searchText) ||
          transaction.description.toLowerCase().contains(searchText) ||
          transaction.type.toLowerCase().contains(searchText) ||
          transaction.amount.toString().contains(searchText);

      // =========================
      // TYPE FILTER
      // =========================

      final matchesType =
          selectedType == "All" || transaction.type == selectedType;

      // =========================
      // CATEGORY FILTER
      // =========================

      final matchesCategory =
          selectedCategory == "All" || transaction.category == selectedCategory;

      // =========================
      // DATE FILTER
      // =========================

      final matchesStartDate =
          startDate == null ||
          !transaction.date.isBefore(
            DateTime(startDate!.year, startDate!.month, startDate!.day),
          );

      final matchesEndDate =
          endDate == null ||
          !transaction.date.isAfter(
            DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59),
          );

      return matchesSearch &&
          matchesType &&
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
              await PdfService.generatePdf(
                currency: context.read<CurrencyProvider>().currency,
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: "Analytics",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: "Budget",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetScreen()),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: "Settings",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
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

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AnalyticsScreen(),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Icon(Icons.analytics_rounded, size: 40),
                              SizedBox(height: 10),
                              Text(
                                "Analytics",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "View spending",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Card(
                      elevation: 3,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BudgetScreen(),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 40,
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Budget",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Manage budget",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

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
                  const Text(
                    "Type:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: "All", child: Text("All")),
                        DropdownMenuItem(
                          value: "Income",
                          child: Text("Income"),
                        ),
                        DropdownMenuItem(
                          value: "Expense",
                          child: Text("Expense"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedType = value ?? "All";
                        });
                      },
                    ),
                  ),
                ],
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

              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      searchController.clear();
                      searchText = "";
                      selectedCategory = "All";
                      selectedType = "All";
                      startDate = null;
                      endDate = null;
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text("Clear Filters"),
                ),
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

                        final originalIndex = provider.transactions.indexWhere(
                          (t) => t.id == transaction.id,
                        );

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
                                                      index: originalIndex,
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

                                            if (confirm == true &&
                                                originalIndex != -1) {
                                              await context
                                                  .read<TransactionProvider>()
                                                  .deleteTransaction(
                                                    originalIndex,
                                                  );
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
