import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? false;
  runApp(MemoryGameApp(isDark: isDark));
}

class MemoryGameApp extends StatefulWidget {
  final bool isDark;
  MemoryGameApp({required this.isDark});

  @override
  State<MemoryGameApp> createState() => _MemoryGameAppState();
}

class _MemoryGameAppState extends State<MemoryGameApp> {
  late bool isDark;

  @override
  void initState() {
    super.initState();
    isDark = widget.isDark;
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDark = !isDark);
    await prefs.setBool('isDark', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بازی حافظه فوتبالی',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: SetupScreen(onToggleTheme: toggleTheme, isDark: isDark),
    );
  }
}
