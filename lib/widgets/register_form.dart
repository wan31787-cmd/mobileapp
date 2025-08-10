import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;

  Future<bool> registerUser(String username, String password) async {
    const String apiUrl = "http://localhost/api/insert_user.php";

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // สมมติ API ส่ง { "success": true } หรือ { "success": false, "message": "..." }
        if (data['success'] == true) {
          return true;
        } else {
          // แจ้ง error จาก API
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'เกิดข้อผิดพลาด')),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      return false;
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    bool success = await registerUser(
      _userController.text.trim(),
      _passController.text,
    );

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('สมัครสมาชิกสำเร็จ')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _userController,
            decoration: const InputDecoration(
              labelText: 'ชื่อผู้ใช้',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.isEmpty ? 'กรุณากรอกชื่อผู้ใช้' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'รหัสผ่าน',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.length < 4 ? 'รหัสผ่านต้องไม่น้อยกว่า 4 ตัว' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'ยืนยันรหัสผ่าน',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v != _passController.text ? 'รหัสผ่านไม่ตรงกัน' : null,
          ),
          const SizedBox(height: 20),
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
                  : const Text('สมัครสมาชิก'),
            ),
          ),
        ],
      ),
    );
  }
}
