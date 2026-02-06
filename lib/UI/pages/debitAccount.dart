import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/debitAccount/debitAccount.body.dart';
import 'package:senticket_front/constants.dart';

class DebitAccount extends StatelessWidget {
  static const String _title = 'Débiter un compte';
  const DebitAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text(_title), backgroundColor: kPrimaryColor),
      body: const DebitBody(),
    );
  }
}
