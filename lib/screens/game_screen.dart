import 'package:flutter/material.dart';
import 'game_screen.dart';

class SetupScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  SetupScreen({required this.onToggleTheme, required this.isDark});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int pairCount = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تنظیمات بازی')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('تعداد جفت کارت‌ها:', style: TextStyle(fontSize: 18)),
          Slider(
            value: pairCount.toDouble(),
            min: 6,
            max: 15,
            divisions: 9,
            label: '$pairCount',
            onChanged: (value) {
              setState(() => pairCount = value.toInt());
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(pairCount: pairCount),
                ),
              );
            },
            child: Text('🎮 شروع بازی'),
          ),
          TextButton(
            onPressed: widget.onToggleTheme,
            child: Text(widget.isDark ? '🌞 حالت روشن' : '🌙 حالت تاریک'),
          ),
        ],
      ),
    );
  }
}
