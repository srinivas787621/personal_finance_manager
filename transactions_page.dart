import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';
import 'add_transaction_page.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
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

  Future<void> _gotoAdd() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionPage()));
    if (result == true) await _load();
  }

  Future<void> _deleteAt(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
        ],
      ),
    );
    if (confirmed == true) {
      _transactions.removeAt(index);
      await _storage.saveTransactions(_transactions);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(onPressed: _gotoAdd, icon: const Icon(Icons.add)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('No transactions yet'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _transactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final t = _transactions[index];
                    final dateLabel = DateFormat.yMMMd().format(t.date);
                    return Dismissible(
                      key: ValueKey(t.date.toIso8601String() + t.title + t.amount.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        await _deleteAt(index);
                        return false; // we handle deletion in _deleteAt
                      },
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: t.isIncome ? Colors.green : Colors.red,
                            child: Icon(t.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
                          ),
                          title: Text(t.title),
                          subtitle: Text(dateLabel),
                          trailing: Text('${t.isIncome ? '+' : '-'} ${t.amount.toStringAsFixed(2)}'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
