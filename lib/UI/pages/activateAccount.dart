import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/activateAccount.body.dart';

class ActivateAccount extends StatelessWidget {
  static const String _title = 'Activer son compte';
  const ActivateAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text(_title)),
        body: const ActivateAccountBody());
  }
}
