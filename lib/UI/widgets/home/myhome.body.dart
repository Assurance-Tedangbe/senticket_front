import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/home/services.dart';
import 'package:senticket_front/UI/widgets/home/statistics.dart';

import '../../../provider/user_provider.dart';
import '../customWidgets/sizeboxHeightSession.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    final userRole = currentUser?.role.name.toUpperCase() ?? '';

    // Déterminer si l'utilisateur a accès aux statistiques globales
    final showGlobalStats = userRole == 'ADMIN' || userRole == 'PORTIER';

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
            // Afficher les statistiques globales seulement pour ADMIN ou PORTIER
            if (showGlobalStats) ...[
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
