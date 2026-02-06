import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/logout.dart';
import 'package:senticket_front/UI/pages/research.dart';
import 'package:senticket_front/UI/widgets/student/student.drawer.dart';
import 'package:senticket_front/UI/widgets/student/studentInterface.body.dart';
import 'package:senticket_front/constants.dart';

class StudentInterface extends StatelessWidget {
  static const String _title = 'Interface Etudiant';
  const StudentInterface({super.key});

  // int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: const StudentDrawer(),
      appBar: AppBar(
        title: const Text(_title),
        backgroundColor: kPrimaryColor,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Rechercher des services',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ServiceResearch()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const LogOut())),
          ),
        ],
      ),
      body: const StudentBody(),
    );
  }
}
