import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');

  runApp(MyApp(initialUserId: userId));
}

class MyApp extends StatelessWidget {
  final String? initialUserId;

  const MyApp({super.key, this.initialUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alert_X',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: initialUserId != null ? MainScreen(userId: initialUserId!) : LoginScreen(),
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
    );
  }
}
