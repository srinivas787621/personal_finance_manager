import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import 'dart:convert';

class StorageService {
  // Save login status
  Future<void> setLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
  }

  // Get login status
  Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Add new user
  Future<bool> addUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users') ?? [];
    // Check if username exists
    for (var u in users) {
      final map = jsonDecode(u);
      if (map['username'] == username) return false;
    }
    users.add(jsonEncode({'username': username, 'password': password}));
    await prefs.setStringList('users', users);
    return true;
  }

  // Validate login
  Future<bool> validateUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users') ?? [];
    for (var u in users) {
      final map = jsonDecode(u);
      if (map['username'] == username && map['password'] == password) {
        return true;
      }
    }
    return false;
  }

  // Save transactions
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final list = transactions.map((tx) => jsonEncode(tx.toJson())).toList();
    await prefs.setStringList('transactions', list);
  }

  // Load transactions
  Future<List<TransactionModel>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('transactions') ?? [];
    return list.map((e) => TransactionModel.fromJson(jsonDecode(e))).toList();
  }
}
