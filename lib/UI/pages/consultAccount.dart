import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/consult.account/consultAccount.body.dart';

class ConsultAccount extends StatelessWidget {
  static const String _title = 'Consulter son compte';
  const ConsultAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text(_title)),
        body: const ConsultBody());
  }
}
