import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/login/login.body.dart';
import 'package:senticket_front/constants.dart';

class LoginPage extends StatelessWidget {
  static const String _title = 'Se Connecter';
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text(_title), backgroundColor: kPrimaryColor),
      body: const LoginBody(),
    );
  }
}
