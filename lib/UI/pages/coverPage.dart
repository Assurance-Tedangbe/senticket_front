import 'package:flutter/material.dart';

import '../widgets/cover/cover.body.dart';
import '../widgets/cover/cover.drawer.dart';

class CoverPage extends StatelessWidget {
  static const String _title = 'SenTicket';
  const CoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        drawer: const CoverDrawer(),
        appBar: AppBar(title: const Text(_title)),
        body: const CoverBody());
  }
}
