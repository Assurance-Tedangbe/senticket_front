import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/historic/historic.body.dart';

class Historic extends StatelessWidget {
  static const String _title = 'Historique';
  const Historic({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text(_title)),
      body: HistoricBody(),
    );
  }
}
