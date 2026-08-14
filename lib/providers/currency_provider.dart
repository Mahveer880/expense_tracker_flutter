import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  String _currency = "Rs.";

  String get currency => _currency;

  CurrencyProvider() {
    loadCurrency();
  }

  // =========================
  // LOAD SAVED CURRENCY
  // =========================

  Future<void> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();

    _currency = prefs.getString('currency') ?? "Rs.";

    notifyListeners();
  }

  // =========================
  // CHANGE CURRENCY
  // =========================

  Future<void> changeCurrency(String value) async {
    _currency = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('currency', value);

    notifyListeners();
  }
}
