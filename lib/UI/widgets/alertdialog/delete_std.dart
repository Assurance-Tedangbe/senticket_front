import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/admin/student.mgmt.dart/manage.student.dart';

class DeleteStd extends StatefulWidget {
  const DeleteStd({super.key});

  @override
  State<DeleteStd> createState() => _DeleteStdState();
}

class _DeleteStdState extends State<DeleteStd> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Suppression compte Etudiant'),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Etes-vous sûr de vouloir supprimer ce compte'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('ANNULER'),
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ManageStudent())),
        ),
        TextButton(
          child: const Text('OUI'),
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ManageStudent())),
        ),
      ],
    );
  }
}
