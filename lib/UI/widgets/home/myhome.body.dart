import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/home/services.dart';
import 'package:senticket_front/UI/widgets/home/statistics.dart';

import '../../../provider/user_provider.dart';
import '../customWidgets/sizeboxHeightSession.dart';

/// Widget principal de la page d'accueil
/// Affiche les services et les statistiques globales selon le rôle de l'utilisateur
class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    // Récupérer le rôle de l'utilisateur (converti en majuscules pour éviter les erreurs de casse)
    final userRole = currentUser?.role.name.toUpperCase() ?? '';

    // Seul ADMIN a accès aux statistiques globales
    final showGlobalStats = userRole == 'ADMIN';

    // Vérifier si l'utilisateur est authentifié
    final isAuthenticated = currentUser != null;

    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 0, 2.0, 0),
        child: SizedBox(
          height: size.height,
          width: size.width,
          child:  Column(
            children: [
              Services(),
            // Afficher les statistiques globales seulement pour ADMIN
            if (showGlobalStats && isAuthenticated) ...[
                const SizeboxHeightSession(),
                const SizeboxHeightSession(),
                const Statistics(),
            ],
           ],
          ),
        ),
      ),
    );
  }
}
