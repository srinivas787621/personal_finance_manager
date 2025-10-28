import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  final _amountCtl = TextEditingController();
  bool _isIncome = true;
  DateTime _selectedDate = DateTime.now();
  final StorageService _storage = StorageService();

  @override
  void dispose() {
    _titleCtl.dispose();
    _amountCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleCtl.text.trim();
    final amount = double.tryParse(_amountCtl.text.trim()) ?? 0.0;
    final tx = TransactionModel(
      title: title,
      amount: amount,
      isIncome: _isIncome,
      date: _selectedDate,
    );

    final list = await _storage.loadTransactions();
    list.insert(0, tx); // newest first
    await _storage.saveTransactions(list);

    // Return to previous page and indicate a change occurred
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.yMMMd().format(_selectedDate);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _titleCtl,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.note),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter title' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountCtl,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Enter amount';
                    final n = double.tryParse(s);
                    if (n == null) return 'Enter valid number';
                    if (n <= 0) return 'Amount should be > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Type:'),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Income'),
                      selected: _isIncome,
                      onSelected: (v) => setState(() => _isIncome = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Expense'),
                      selected: !_isIncome,
                      onSelected: (v) => setState(() => _isIncome = false),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(dateLabel),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    child: const Text('Save Transaction'),
                  ),
                ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
