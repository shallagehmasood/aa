import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

// --- ثابت‌ها ---
const PAIRS = [
  "EURUSD",
  "GBPUSD",
  "USDJPY",
  "USDCHF",
  "AUDUSD",
  "AUDJPY",
  "CADJPY",
  "EURJPY",
  "BTCUSD",
  "USDCAD",
  "GBPJPY",
  "ADAUSD",
  "BRENT",
  "XAUUSD",
  "XAGUSD",
  "ETHUSD",
  "DowJones30",
  "Nasdaq100",
];

const MODES = ["A1", "A2", "B", "C", "D", "E", "F", "G"];
const TIMEFRAMES = [
  "M1",
  "M2",
  "M3",
  "M4",
  "M5",
  "M6",
  "M10",
  "M12",
  "M15",
  "M20",
  "M30",
  "H1",
  "H2",
  "H3",
  "H4",
  "H6",
  "H8",
  "H12",
  "D1",
  "W1",
];
const SESSIONS = ["TOKYO", "LONDON", "NEWYORK", "SYDNEY"];
const SIGNALS = ["BUY", "SELL", "BUYSELL"];

// --- اپ ---
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First Hidden Settings',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String chatId =
      "YOUR_CHAT_ID"; // می‌توانید یک شناسه یکتا برای کاربر تعریف کنید
  Map<String, bool> selectedModes = {};
  Map<String, bool> selectedSessions = {};
  Map<String, bool> selectedPairs = {};
  Map<String, bool> selectedTimeframes = {};
  String selectedSignal = "BUYSELL";
  bool isLoading = false;
  String statusMessage = "";

  @override
  void initState() {
    super.initState();
    // مقداردهی اولیه همه حالت‌ها
    MODES.forEach((m) => selectedModes[m] = false);
    SESSIONS.forEach((s) => selectedSessions[s] = false);
    PAIRS.forEach((p) => selectedPairs[p] = false);
    TIMEFRAMES.forEach((t) => selectedTimeframes[t] = false);
  }

  Future<void> sendSettings() async {
    setState(() {
      isLoading = true;
      statusMessage = "";
    });

    var url = Uri.parse('http://178.63.171.244:5000/save_settings');
    var body = jsonEncode({
      "chat_id": chatId,
      "pairs": selectedPairs,
      "modes": selectedModes,
      "sessions": selectedSessions,
    });

    try {
      var response = await http.post(
        url,
        body: body,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        setState(() {
          statusMessage = "✅ تنظیمات با موفقیت ذخیره شد";
        });
      } else if (response.statusCode == 403) {
        setState(() {
          statusMessage = "❌ دسترسی غیرمجاز. با آیدی Masood_Fx ارتباط بگیرید";
        });
      } else {
        setState(() {
          statusMessage = "❌ خطا در ارسال تنظیمات: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "❌ خطا در ارتباط با سرور: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildChip(String label, bool selected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Colors.green[300],
      checkmarkColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("First Hidden Settings")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- مودها ---
            Text(
              "مودها",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: MODES
                  .map(
                    (m) => buildChip(m, selectedModes[m]!, (val) {
                      setState(() {
                        if (m == "A1") {
                          selectedModes["A1"] = val;
                          if (val) selectedModes["A2"] = false;
                        } else if (m == "A2") {
                          selectedModes["A2"] = val;
                          if (val) selectedModes["A1"] = false;
                        } else {
                          selectedModes[m] = val;
                        }
                      });
                    }),
                  )
                  .toList(),
            ),
            SizedBox(height: 20),

            // --- سشن‌ها ---
            Text(
              "سشن‌ها",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: SESSIONS
                  .map(
                    (s) => buildChip(s, selectedSessions[s]!, (val) {
                      setState(() {
                        selectedSessions[s] = val;
                      });
                    }),
                  )
                  .toList(),
            ),
            SizedBox(height: 20),

            // --- جفت ارزها ---
            Text(
              "جفت ارزها",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: PAIRS
                  .map(
                    (p) => buildChip(p, selectedPairs[p]!, (val) {
                      setState(() {
                        selectedPairs[p] = val;
                      });
                    }),
                  )
                  .toList(),
            ),
            SizedBox(height: 20),

            // --- سیگنال ---
            Text(
              "سیگنال",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: SIGNALS
                  .map(
                    (sig) => ChoiceChip(
                      label: Text(sig),
                      selected: selectedSignal == sig,
                      onSelected: (val) {
                        setState(() {
                          selectedSignal = sig;
                        });
                      },
                      selectedColor: Colors.blue[300],
                    ),
                  )
                  .toList(),
            ),

            SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : sendSettings,
                child: Text(isLoading ? "در حال ارسال..." : "ذخیره تنظیمات"),
              ),
            ),
            SizedBox(height: 20),
            if (statusMessage.isNotEmpty)
              Center(
                child: Text(statusMessage, style: TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }
}
