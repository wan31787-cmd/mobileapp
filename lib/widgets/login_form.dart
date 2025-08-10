import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/states/authen.dart';
import 'package:mobile/states/register.dart';
import 'package:mobile/states/main_mobile.dart'; // เพิ่มตรงนี้

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  List<dynamic> _users = []; // เก็บข้อมูล user ที่ดึงมา

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    const apiUrl = "http://localhost/api/login.php"; // เปลี่ยนเป็น URL API จริงของคุณ

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          setState(() {
            _users = data['data'];
          });
          for (var user in _users) {
            print('Username: ${user['username']}, Password: ${user['passwords']}');
          }
        } else {
          print('API error: ${data['message']}');
        }
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch error: $e');
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);

    String inputUser = _userController.text.trim();
    String inputPass = _passController.text.trim();

    bool found = false;
    for (var user in _users) {
      if (user['username'] == inputUser && user['passwords'] == inputPass) {
        // จริง ๆ ควรตรวจสอบ password ผ่าน API ฝั่ง server เพราะ password ถูก hash
        found = true;
        break;
      }
    }
    if (found) {
      // ไปหน้า main_mobile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainMobilePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบผู้ใช้')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    double maxWidth = mq.size.width >= 600 ? 420 : mq.size.width * 0.9;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('เข้าสู่ระบบ',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _userController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อผู้ใช้',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'กรุณากรอกชื่อผู้ใช้' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => v == null || v.length < 4
                      ? 'รหัสผ่านต้องไม่น้อยกว่า 4 ตัว'
                      : null,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('เข้าสู่ระบบ'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text('สมัครสมาชิก'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
