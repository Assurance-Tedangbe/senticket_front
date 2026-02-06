import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/logout.dart';
import 'package:senticket_front/UI/pages/research.dart';
import 'package:senticket_front/UI/widgets/admin/admin.drawer.dart';
import 'package:senticket_front/UI/widgets/admin/adminInterface.body.dart';
import 'package:senticket_front/constants.dart';

class AdminInterface extends StatelessWidget {
  static const String _title = 'Interface Administrateur';
  const AdminInterface({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: const AdminDrawer(),
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
      body: const AdminBody(),
    );
  }
}
