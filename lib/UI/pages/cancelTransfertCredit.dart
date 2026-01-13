import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/cancelTrsf/cancelTrsfCreditBody/cancelTrsfCredit.body.dart';

class CancelTrsfCredit extends StatelessWidget {
  static const String _title = 'Annuler transfert crédit';
  const CancelTrsfCredit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text(_title)),
      body: const CancelTrsfCreditBody(),
    );
  }
}
