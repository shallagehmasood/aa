import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatelessWidget {
  final _userIdController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ورود')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'لطفاً شناسه کاربری خود را وارد کنید',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _userIdController,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'مثال: 123456789',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final userId = _userIdController.text.trim();
                  if (userId.isEmpty) {
                    Fluttertoast.showToast(msg: 'لطفاً شناسه را وارد کنید');
                    return;
                  }

                  final api = ApiService();
                  final valid = await api.authenticate(userId);

                  if (valid) {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('user_id', userId);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => MainScreen(userId: userId)),
                    );
                  } else {
                    Fluttertoast.showToast(msg: '❌ کاربر مجاز نیست');
                  }
                },
                child: const Text('تایید'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
