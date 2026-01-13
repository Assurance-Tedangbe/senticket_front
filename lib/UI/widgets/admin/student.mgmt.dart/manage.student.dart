import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/admin/student.mgmt.dart/manage.student.body.dart';

class ManageStudent extends StatelessWidget {
  static const String _title = 'Gestionnaire des comptes Etudiants';
  const ManageStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar:
            AppBar(title: const Text(_title, style: TextStyle(fontSize: 19.5))),
        body: const ManageStudentsBody());
  }
}
