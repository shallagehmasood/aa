import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  bool _isLoading = false;

  // تابع جدا برای تمیزتر شدن کد
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final api = ApiService();

      try {
        final valid = await api.authenticate(_userIdController.text);
        if (valid) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', _userIdController.text);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  MainScreen(userId: _userIdController.text),
            ),
          );
        } else {
          Fluttertoast.showToast(msg: '❌ کاربر مجاز نیست');
        }
      } catch (e) {
        Fluttertoast.showToast(msg: '⚠️ خطا در ارتباط با سرور');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // رفع مشکل بالا آمدن کیبورد
      appBar: AppBar(
        title: const Text('ورود'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView( // رفع اسکرول و بریدگی صفحه
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Text(
                  'لطفاً شناسه کاربری خود را وارد کنید',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),

                // فیلد ورود شناسه
                TextFormField(
                  controller: _userIdController,
                  textDirection: TextDirection.ltr,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفاً شناسه را وارد کنید';
                    } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                      return 'شناسه باید فقط عددی باشد';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // دکمه ورود
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'تأیید',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
