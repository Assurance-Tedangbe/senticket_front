import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/admin/porter.mgmt.dart/manage.porter.body.dart';

class ManagePorter extends StatelessWidget {
  static const String _title = 'Gestionnaire des comptes Portiers';
  const ManagePorter({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar:
            AppBar(title: const Text(_title, style: TextStyle(fontSize: 19.5))),
        body: const ManagePorterBody());
  }
}
