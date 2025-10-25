import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PingPage(),
    );
  }
}

class PingPage extends StatefulWidget {
  @override
  _PingPageState createState() => _PingPageState();
}

class _PingPageState extends State<PingPage> {
  String result = "";

  Future<void> checkServer() async {
    try {
      var url = Uri.parse("http://178.63.171.244:5000/ping"); // آدرس سرور خودت
      var res = await http.get(url);
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        setState(() {
          result = "✅ اتصال برقرار شد: ${data['status']}";
        });
      } else {
        setState(() {
          result = "❌ خطا در پاسخ سرور: ${res.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        result = "❌ خطا در اتصال: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تست اتصال")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: checkServer,
              child: Text("بررسی اتصال به سرور"),
            ),
            SizedBox(height: 20),
            Text(result, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
