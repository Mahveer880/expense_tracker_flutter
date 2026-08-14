import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/buttons/primary_button.dart';
import '../../widgets/textfields/custom_text_field.dart';

import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;
  final int? index;

  const AddTransactionScreen({super.key, this.transaction, this.index});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isIncome = true;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;

  final List<String> incomeCategories = [
    'Salary',
    'Business',
    'Freelance',
    'Gift',
    'Family Fund',
    'Other',
  ];

  final List<String> expenseCategories = [
    'Food',
    'Shopping',
    'Fuel',
    'Bills',
    'Transport',
    'Medical',
    'Family Fund',
    'Other',
  ];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      final transaction = widget.transaction!;

      isIncome = transaction.type == "Income";

      amountController.text = transaction.amount.toString();

      descriptionController.text = transaction.description;

      selectedCategory = transaction.category;

      selectedDate = transaction.date;
    }
  }

  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? "Add Transaction" : "Edit Transaction",
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  "Transaction Type",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isIncome
                              ? Colors.green
                              : Colors.grey.shade300,

                          foregroundColor: isIncome
                              ? Colors.white
                              : Colors.black,
                        ),

                        onPressed: () {
                          setState(() {
                            isIncome = true;
                            selectedCategory = null;
                          });
                        },

                        child: const Text("Income"),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !isIncome
                              ? Colors.red
                              : Colors.grey.shade300,

                          foregroundColor: !isIncome
                              ? Colors.white
                              : Colors.black,
                        ),

                        onPressed: () {
                          setState(() {
                            isIncome = false;
                            selectedCategory = null;
                          });
                        },

                        child: const Text("Expense"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                CustomTextField(
                  controller: amountController,

                  hintText: "Enter Amount",

                  prefixIcon: Icons.currency_rupee,

                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter amount";
                    }

                    final amount = double.tryParse(value);

                    if (amount == null) {
                      return "Enter a valid number";
                    }

                    if (amount <= 0) {
                      return "Amount must be greater than 0";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  items: (isIncome ? incomeCategories : expenseCategories)
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Please select a category";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat("dd MMM yyyy").format(selectedDate)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: pickDate,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  controller: descriptionController,
                  hintText: "Description",
                  prefixIcon: Icons.description,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter description";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                PrimaryButton(
                  text: widget.transaction == null
                      ? "Save Transaction"
                      : "Update Transaction",

                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final currentUser = AuthService.getCurrentUser();

                      if (currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please login first")),
                        );
                        return;
                      }

                      final transaction = TransactionModel(
                        id:
                            widget.transaction?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),

                        userId: currentUser.id,

                        type: isIncome ? "Income" : "Expense",

                        category: selectedCategory!,

                        amount: double.tryParse(amountController.text) ?? 0,

                        description: descriptionController.text,

                        date: selectedDate,
                      );

                      if (widget.transaction == null) {
                        await context
                            .read<TransactionProvider>()
                            .addTransaction(transaction);

                        if (transaction.type == "Expense") {
                          await NotificationService.showExpenseNotification(
                            amount: transaction.amount,
                            category: transaction.category,
                          );
                        } else {
                          await NotificationService.showIncomeNotification(
                            amount: transaction.amount,
                            category: transaction.category,
                          );
                        }
                      } else {
                        await context
                            .read<TransactionProvider>()
                            .updateTransaction(widget.index!, transaction);
                      }

                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
