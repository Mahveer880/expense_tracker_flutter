import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetProvider extends ChangeNotifier {
  double _monthlyBudget = 0;
  double _annualBudget = 0;

  double get monthlyBudget => _monthlyBudget;
  double get annualBudget => _annualBudget;

  BudgetProvider() {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();

    _monthlyBudget = prefs.getDouble('monthly_budget') ?? 0;
    _annualBudget = prefs.getDouble('annual_budget') ?? 0;

    notifyListeners();
  }

  Future<void> setMonthlyBudget(double value) async {
    _monthlyBudget = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('monthly_budget', value);

    notifyListeners();
  }

  Future<void> setAnnualBudget(double value) async {
    _annualBudget = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('annual_budget', value);

    notifyListeners();
  }
}
