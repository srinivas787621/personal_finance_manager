import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';
import 'add_transaction_page.dart';
import 'wallet_page.dart';
import 'calendar_page.dart';
import 'transactions_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StorageService _storage = StorageService();
  List<TransactionModel> _transactions = [];
  double _totalBalance = 0;
  int _selectedIndex = 0;
  bool _isDarkMode = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final loggedIn = await _storage.getLoginStatus();
    if (!loggedIn) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      setState(() {
        _isLoggedIn = true;
      });
      _loadTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    final list = await _storage.loadTransactions();
    double balance = 0;
    for (var tx in list) {
      balance += tx.isIncome ? tx.amount : -tx.amount;
    }
    setState(() {
      _transactions = list;
      _totalBalance = balance;
    });
  }

  void _logout() async {
    await _storage.setLoginStatus(false);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _onNavItemTapped(int index) async {
    if (!_isLoggedIn) return;

    setState(() => _selectedIndex = index);
    switch (index) {
      case 1:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TransactionsPage()),
        );
        break;
      case 2:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WalletPage()),
        );
        break;
      case 3:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarPage()),
        );
        break;
    }
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;
    final bgColor = isDark ? Colors.black : Colors.grey[100];
    final cardColor = isDark ? Colors.teal[800] : Colors.teal[300];
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryText = isDark ? Colors.grey[300] : Colors.grey[700];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Finance Manager',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.teal,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.yellow[600] : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? Colors.tealAccent : Colors.white,
                foregroundColor: isDark ? Colors.black : Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () {
                if (_isLoggedIn) {
                  _logout();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ).then((_) => _checkLogin());
                }
              },
              child: Text(_isLoggedIn ? 'Logout' : 'Login'),
            ),
          ),
        ],
      ),
      floatingActionButton: _isLoggedIn
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddTransactionPage()),
                );
                if (result == true) _loadTransactions();
              },
              backgroundColor: isDark ? Colors.teal[700] : Colors.teal,
              child: const Icon(Icons.add),
              tooltip: 'Add Transaction',
            )
          : null,
      backgroundColor: bgColor,
      body: _isLoggedIn
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              color: bgColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    color: cardColor,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Balance',
                              style: TextStyle(color: textColor, fontSize: 18)),
                          Text(
                            '₹${_totalBalance.toStringAsFixed(2)}',
                            style: TextStyle(
                                color: textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildTile(
                          context,
                          icon: Icons.list,
                          label: 'Transactions',
                          color: isDark ? Colors.teal[900]! : Colors.teal[100]!,
                          iconColor: isDark ? Colors.tealAccent : Colors.teal,
                          textColor: textColor,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const TransactionsPage())),
                        ),
                        _buildTile(
                          context,
                          icon: Icons.calendar_today,
                          label: 'Calendar',
                          color:
                              isDark ? Colors.orange[900]! : Colors.orange[100]!,
                          iconColor: isDark ? Colors.orangeAccent : Colors.orange,
                          textColor: textColor,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CalendarPage())),
                        ),
                        _buildTile(
                          context,
                          icon: Icons.account_balance_wallet,
                          label: 'Wallet',
                          color: isDark ? Colors.green[900]! : Colors.green[100]!,
                          iconColor: isDark ? Colors.lightGreenAccent : Colors.green,
                          textColor: textColor,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const WalletPage())),
                        ),
                        _buildTile(
                          context,
                          icon: Icons.add_circle,
                          label: 'Add Transaction',
                          color: isDark ? Colors.purple[900]! : Colors.purple[100]!,
                          iconColor: isDark ? Colors.purpleAccent : Colors.purple,
                          textColor: textColor,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AddTransactionPage()),
                            );
                            if (result == true) _loadTransactions();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: _isLoggedIn
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onNavItemTapped,
              selectedItemColor: isDark ? Colors.tealAccent : Colors.teal,
              unselectedItemColor: secondaryText,
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.list), label: 'Transactions'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today), label: 'Calendar'),
              ],
            )
          : null,
    );
  }

  Widget _buildTile(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required Color iconColor,
      required Color textColor,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
