import 'package:flutter/material.dart';
import 'package:mobile/widgets/login_form.dart';

class AuthenPage extends StatelessWidget {
  const AuthenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: const LoginForm(),
          ),
        ),
      ),
    );
  }
}
