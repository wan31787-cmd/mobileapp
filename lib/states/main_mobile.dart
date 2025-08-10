import 'package:flutter/material.dart';
import 'package:mobile/states/authen.dart';  // import หน้า login

class MainMobilePage extends StatelessWidget {
  const MainMobilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าหลัก'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ออกจากระบบ',
            onPressed: () {
              // กลับไปหน้า login
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthenPage()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'ยินดีต้อนรับเข้าสู่แอป',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
