import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetProvider extends ChangeNotifier {
  double _budget = 0;

  double get budget => _budget;

  BudgetProvider() {
    loadBudget();
  }

  Future<void> loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    _budget = prefs.getDouble('monthly_budget') ?? 0;
    notifyListeners();
  }

  Future<void> setBudget(double value) async {
    _budget = value;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_budget', value);

    notifyListeners();
  }
}
