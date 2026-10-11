import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/pages/logout.dart';
import 'package:senticket_front/UI/pages/research.dart';
import 'package:senticket_front/UI/widgets/student/student.drawer.dart';
import 'package:senticket_front/UI/widgets/student/studentInterface.body.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/main.dart';

import '../../provider/ticket_provider.dart';
import '../../provider/user_provider.dart';

class StudentInterface extends StatefulWidget {
  const StudentInterface({super.key});

  @override
  State<StudentInterface> createState() => _StudentInterfaceState();
}

class _StudentInterfaceState extends State<StudentInterface> with RouteAware {
  static const String _title = 'Interface Etudiant';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // S'abonner aux événements de navigation
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Se désabonner pour éviter les memory leaks
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Appelé quand on REVIENT sur cette page (pop d'une sous-page)
  /// Exemple : retour de BuyTicket, TransfertTicket, DebitAccount, etc.
  @override
  void didPopNext() {
    _refreshStatistics();
  }

  /// Recharge les statistiques depuis le backend
  void _refreshStatistics() {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final userId = userProvider.currentUser?.userId;

    if (userId != null) {
      ticketProvider.loadTicketStatistics(userId: userId);
      print('[StudentInterface] Statistiques rechargées après retour');
    }
  }

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
            icon: const Icon(Icons.search, color: kThirdColor),
            tooltip: 'Rechercher des services',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ServiceResearch()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: kThirdColor),
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
