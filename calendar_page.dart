import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';
import 'add_transaction_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final StorageService _storage = StorageService();
  List<TransactionModel> _all = [];
  DateTime _selected = DateTime.now();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    _all = await _storage.loadTransactions();
    setState(() => _loading = false);
  }

  List<TransactionModel> get _forSelected {
    return _all.where((t) =>
      t.date.year == _selected.year &&
      t.date.month == _selected.month &&
      t.date.day == _selected.day
    ).toList();
  }

  Future<void> _pickDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (dt != null) setState(() => _selected = dt);
  }

  Future<void> _gotoAdd() async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionPage()));
    if (res == true) await _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final label = DateFormat.yMMMd().format(_selected);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(onPressed: _gotoAdd, icon: const Icon(Icons.add)),
          IconButton(onPressed: _pickDate, icon: const Icon(Icons.calendar_today)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () => setState(() => _selected = _selected.subtract(const Duration(days: 1))),
                          icon: const Icon(Icons.chevron_left)),
                      Expanded(child: Center(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                      IconButton(
                          onPressed: () => setState(() => _selected = _selected.add(const Duration(days: 1))),
                          icon: const Icon(Icons.chevron_right)),
                    ],
                  ),
                ),
                Expanded(
                  child: _forSelected.isEmpty
                      ? const Center(child: Text('No transactions on this date'))
                      : ListView.builder(
                          itemCount: _forSelected.length,
                          itemBuilder: (context, index) {
                            final t = _forSelected[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: t.isIncome ? Colors.green : Colors.red,
                                  child: Icon(t.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
                                ),
                                title: Text(t.title),
                                trailing: Text('${t.isIncome ? '+' : '-'} ${t.amount.toStringAsFixed(2)}'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
