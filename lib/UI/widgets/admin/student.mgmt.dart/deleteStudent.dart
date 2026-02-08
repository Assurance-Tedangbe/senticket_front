import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/admin/student.mgmt.dart/manage.student.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.template.dart';
import 'package:senticket_front/UI/widgets/updateUser/pageIconTemplate.dart';
import 'package:senticket_front/constants.dart';

class DeleteStudent extends StatefulWidget {
  const DeleteStudent({super.key});

  @override
  State<DeleteStudent> createState() => _DeleteStudentState();
}

class _DeleteStudentState extends State<DeleteStudent> {
  Future<void> _showDeleteStudentDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
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
                MaterialPageRoute(builder: (context) => const ManageStudent()),
              ),
            ),
            TextButton(
              child: const Text('OUI'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ManageStudent()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget logoutBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25),
      height: 100,
      width: 170,
      child: ElevatedButton(
        onPressed: _showDeleteStudentDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          textStyle: const TextStyle(
            color: kSecondColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text('Supprimer'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const PageIconTemplate(iconData: Icons.delete_outline),
          const SizeboxTemplate(),
          logoutBtn(),
        ],
      ),
    );
  }
}
