import 'package:flutter/material.dart';

class CurrencyProvider extends ChangeNotifier {
  String _currency = "Rs.";

  String get currency => _currency;

  void changeCurrency(String value) {
    _currency = value;
    notifyListeners();
  }
}
