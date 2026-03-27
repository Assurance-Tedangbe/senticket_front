import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizeboxHeightSession.dart';
import 'package:senticket_front/UI/widgets/student/statistics.student.dart';
import 'package:senticket_front/UI/widgets/student/student.services.dart';
import 'package:senticket_front/provider/user_provider.dart';

/// Widget principal de la page étudiant
/// Affiche les services étudiants et les statistiques personnelles
class StudentBody extends StatelessWidget {
  const StudentBody({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    // Vérifier si l'utilisateur est connecté et a le rôle ETUDIANT
    final isAuthenticatedStudent = currentUser != null &&
        currentUser.role.name.toUpperCase() == 'ETUDIANT';

    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 0, 2.0, 0),
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: const Column(
            children: [
              StudentServices(),
              SizeboxHeightSession(),
              SizeboxHeightSession(),

              // Widget des statistiques étudiantes, affichage conditionnée
              // Si l'utilisateur  connecté n'est pas étudiant, les valeurs seront 0
              StatisticsStudent(),
            ],
          ),
        ),
      ),
    );
  }
}
