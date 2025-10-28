import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  final isLoggedIn = await storage.getLoginStatus();

  runApp(PersonalFinanceApp(isLoggedIn: isLoggedIn));
}

class PersonalFinanceApp extends StatelessWidget {
  final bool isLoggedIn;
  const PersonalFinanceApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Finance Manager',
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
