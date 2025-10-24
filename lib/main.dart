import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- ثابت‌ها ---
const PAIRS = [
  "EURUSD", "GBPUSD", "USDJPY", "USDCHF", "AUDUSD", "AUDJPY", "CADJPY", "EURJPY",
  "BTCUSD", "USDCAD", "GBPJPY", "ADAUSD", "BRENT", "XAUUSD", "XAGUSD", "ETHUSD",
  "DowJones30", "Nasdaq100",
];
const MODES = {
  "A1": "هیدن اول",
  "A2": "همه هیدن ها",
  "B": "دایورجنس نبودن نقطه 2 در مکدی دیفالت اول 1",
  "C": "دایورجنس نبودن نقطه 2 در مکدی چهار برابر",
  "D": "زده شدن سقف یا کف جدید نسبت به 52 کندل قبل",
  "E": "عدم تناسب در نقطه 3 بین مکدی دیفالت و مووینگ 60",
  "F": "از 2 تا 3 اصلاح مناسبی داشته باشد",
  "G": "دایورجنس نبودن نقطه 2 در مکدی دیفالت لول 2",
};
const SESSIONS = {
  "TOKYO": "سشن توکیو \u200E( 03:00-10:00)",
  "LONDON": "سشن لندن \u200E(19:00 - 22:00)",
  "NEWYORK": "سشن نیویورک \u200E(15:00 - 00:00)",
  "SYDNEY": "سشن سیدنی \u200E(01:00 - 10:00)",
};
const TIMEFRAMES = [
  "M1", "M2", "M3", "M4", "M5", "M6", "M10", "M12", "M15", "M20", "M30",
  "H1", "H2", "H3", "H4", "H6", "H8", "H12", "D1", "W1"
];
const SIGNALS = ["BUY", "SELL", "BUYSELL"];

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First Hidden Settings',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UserIdPage(),
    );
  }
}

// ==================== صفحه ورود User ID ====================
class UserIdPage extends StatefulWidget {
  @override
  _UserIdPageState createState() => _UserIdPageState();
}

class _UserIdPageState extends State<UserIdPage> {
  final TextEditingController _controller = TextEditingController();
  String statusMessage = "";
  bool isLoading = false;

  Future<bool> checkWhitelist(String userId) async {
    setState(() {
      isLoading = true;
      statusMessage = "";
    });
    try {
      // کدگذاری userId به URL
      var encodedUserId = Uri.encodeComponent(userId);
      var url = Uri.parse("http://178.63.171.244:5000/check_whitelist?user_id=$encodedUserId");

      // ارسال درخواست به سرور
      var res = await http.get(url);

      // بررسی پاسخ سرور
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        return data["authorized"] == true;
      }
      return false;
    } catch (e) {
      setState(() {
        statusMessage = "❌ خطا در ارتباط با سرور";
      });
      return false;
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ورود کاربر")),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "User ID خود را وارد کنید",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      bool ok = await checkWhitelist(_controller.text.trim());
                      if (ok) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => HomePage(userId: _controller.text.trim())),
                        );
                      } else {
                        setState(() {
                          statusMessage = "❌ دسترسی غیرمجاز";
                        });
                      }
                    },
              child: Text(isLoading ? "در حال بررسی..." : "ورود"),
            ),
            SizedBox(height: 20),
            if (statusMessage.isNotEmpty)
              Text(statusMessage, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }
}

// ==================== صفحه اصلی ====================
class HomePage extends StatefulWidget {
  final String userId;
  HomePage({required this.userId});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, bool> selectedModes = {};
  Map<String, bool> selectedSessions = {};
  Map<String, Map<String, bool>> selectedPairs = {};
  Map<String, String> selectedSignals = {};
  bool isLoading = false;
  String statusMessage = "";

  @override
  void initState() {
    super.initState();
    MODES.keys.forEach((m) => selectedModes[m] = false);
    SESSIONS.keys.forEach((s) => selectedSessions[s] = false);
    PAIRS.forEach((p) {
      selectedPairs[p] = {};
      TIMEFRAMES.forEach((t) {
        selectedPairs[p]![t] = false;
      });
      selectedSignals[p] = "BUYSELL";
    });
  }

  Future<void> sendSettings() async {
    setState(() {
      isLoading = true;
      statusMessage = "";
    });
    try {
      var url = Uri.parse("http://178.63.171.244:5000/save_settings");
      var body = jsonEncode({
        "chat_id": widget.userId,
        "modes": selectedModes,
        "sessions": selectedSessions,
        "pairs": selectedPairs,
        "signals": selectedSignals
      });

      // ارسال درخواست POST به سرور
      var res = await http.post(
        url,
        body: body,
        headers: {
          "Content-Type": "application/json", // تعیین نوع محتویات درخواست
        },
      );

      // بررسی پاسخ سرور
      if (res.statusCode == 200) {
        setState(() {
          statusMessage = "✅ تنظیمات با موفقیت ذخیره شد";
        });
      } else if (res.statusCode == 403) {
        setState(() {
          statusMessage = "❌ دسترسی غیرمجاز";
        });
      } else {
        setState(() {
          statusMessage = "❌ خطا: ${res.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "❌ خطا در ارتباط با سرور";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تنظیمات First Hidden")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- مودها ----------
            Text("مودها", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MODES.keys.map((m) {
                return FilterChip(
                  label: Text(MODES[m]!),
                  selected: selectedModes[m]!,
                  onSelected: (val) {
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
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // ---------- وضعیت ارسال ----------
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: sendSettings,
                    child: Text("ذخیره تنظیمات"),
                  ),
            SizedBox(height: 16),
            if (statusMessage.isNotEmpty)
              Text(statusMessage, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
