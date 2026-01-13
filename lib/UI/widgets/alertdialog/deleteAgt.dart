import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/adminInterface.dart';
import 'package:senticket_front/UI/widgets/admin/agent.mgmt.dart/manage.agent.dart';

class DeleteAgt extends StatefulWidget {
  const DeleteAgt({super.key});

  @override
  State<DeleteAgt> createState() => _DeleteAgtState();
}

class _DeleteAgtState extends State<DeleteAgt> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Suppression compte Agent'),
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
              MaterialPageRoute(builder: (context) => const ManageAgent())),
        ),
        TextButton(
          child: const Text('OUI'),
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ManageAgent())),
        ),
      ],
    );
  }
}
