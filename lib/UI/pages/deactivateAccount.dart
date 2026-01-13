import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/deactivateAccount.body.dart';

class DeactivateAccount extends StatelessWidget {
  static const String _title = 'Désactiver son compte';
  const DeactivateAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text(_title)),
        body: const DeactivateAccountBody());
  }
}
