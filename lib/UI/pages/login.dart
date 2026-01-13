import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/login/login.body.dart';

class LoginPage extends StatelessWidget {
  static const String _title = 'Se Connecter';
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text(_title)),
        body: const LoginBody());
  }
}
