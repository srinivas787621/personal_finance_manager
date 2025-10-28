import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final StorageService _storage = StorageService();
  List<TransactionModel> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _transactions = await _storage.loadTransactions();
    setState(() => _loading = false);
  }

  double get income => _transactions.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
  double get expense => _transactions.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);
  double get balance => income - expense;

  String percentString() {
    final tot = income + expense;
    if (tot == 0) return '—';
    final p = (expense / tot) * 100;
    return '${p.toStringAsFixed(1)}% spent';
  }

  List<TransactionModel> topExpenses(int n) {
    final ex = _transactions.where((t) => !t.isIncome).toList();
    ex.sort((a, b) => b.amount.compareTo(a.amount));
    return ex.take(n).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      title: const Text('Balance'),
                      subtitle: Text(balance.toStringAsFixed(2), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text('Income: ${income.toStringAsFixed(2)}'), Text('Expense: ${expense.toStringAsFixed(2)}')],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      title: const Text('Quick Analysis'),
                      subtitle: Text(percentString()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Align(alignment: Alignment.centerLeft, child: Text('Top Expenses', style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  Expanded(
                    child: topExpenses(5).isEmpty
                        ? const Center(child: Text('No expenses yet'))
                        : ListView.builder(
                            itemCount: topExpenses(5).length,
                            itemBuilder: (context, index) {
                              final t = topExpenses(5)[index];
                              return ListTile(
                                leading: CircleAvatar(backgroundColor: Colors.red, child: const Icon(Icons.money_off, color: Colors.white)),
                                title: Text(t.title),
                                subtitle: Text(t.date.toLocal().toString().split(' ')[0]),
                                trailing: Text('- ${t.amount.toStringAsFixed(2)}'),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
