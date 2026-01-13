import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/logout.body.dart';

class LogOut extends StatelessWidget {
  static const String _title = 'Se Déconnecter';
  const LogOut({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text(_title)),
        body: const LogOutBody());
  }
}
