import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/login.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/services/ticket_service.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/buyTicket/requestSection.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketASection.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketBSection.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.template.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

class BuyTicketBody extends StatefulWidget {
  const BuyTicketBody({super.key});

  @override
  State<BuyTicketBody> createState() => _BuyTicketBodyState();
}

class _BuyTicketBodyState extends State<BuyTicketBody> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        final isLoggedIn = user != null;
        final isStudent = isLoggedIn ? user.role.name == 'ETUDIANT' : false;

        return ChangeNotifierProvider(
          create: (context) => TicketProvider(TicketApiService()),
          child: Background(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
                child: SizedBox(
                  width: size.width,
                  child: Column(
                    children: [
                      // Interface d'achat (seulement si étudiant connecté)
                      if (isLoggedIn && isStudent)
                        _buildTicketInterface(context)
                      else if (isLoggedIn && !isStudent)
                        _buildNotStudentWarning()
                      else
                        _buildLoginRequired(),

                      /* const SizeboxTemplate(),
                      // En-tête d'authentification
                      _buildAuthHeader(
                        context,
                        userProvider,
                        isLoggedIn,
                        isStudent,
                      ), */
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketInterface(BuildContext context) {
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        return Column(
          children: [
            if (ticketProvider.error.isNotEmpty)
              _buildErrorDisplay(ticketProvider),
            const TicketASection(),
            const SizeboxTemplate(),
            const SizeboxTemplate(),
            const TicketBSection(),
            const SizeboxTemplate(),
            const RequestSection(),
          ],
        );
      },
    );
  }

  Widget _buildNotStudentWarning() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.block, size: 80, color: kPrimaryColor),
          const SizedBox(height: 20),
          const Text(
            'Accès réservé aux étudiants',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Seuls les ETUDIANTS peuvent acheter des tickets.',
            textAlign: TextAlign.center,
            style: TextStyle(color: greyBorderColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              userProvider.currentUser = null;
              userProvider.resetLoginForm();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: kSecondColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.lock_person, size: 80, color: greyBorderColor),
          const SizedBox(height: 20),
          const Text(
            'Authentification requise',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: greyBorderColor,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Connectez-vous pour acheter des tickets',
            textAlign: TextAlign.center,
            style: TextStyle(color: greyBorderColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
            icon: const Icon(Icons.login),
            label: const Text('Se connecter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: kSecondColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(TicketProvider ticketProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: kPrimaryColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: kPrimaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ticketProvider.error,
                style: const TextStyle(color: kPrimaryColor),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: () => ticketProvider.clearError(),
            ),
          ],
        ),
      ),
    );
  }
}

/* Widget _buildAuthHeader(
  BuildContext context,
  UserProvider userProvider,
  bool isLoggedIn,
  bool isStudent,
) {
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLoggedIn
                    ? ' ${userProvider.currentUser!.username} connecté (${userProvider.currentUser!.role.name})'
                    : '',
                style: TextStyle(
                  color: isLoggedIn
                      ? (isStudent ? kThirdColor : kPrimaryColor)
                      : greyBorderColor,
                ),
              ),
            ],
          ),
        ),
        if (isLoggedIn)
          IconButton(
            onPressed: () {
              userProvider.currentUser = null;
              userProvider.resetLoginForm();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Déconnexion réussie'),
                  backgroundColor: kPrimaryColor,
                ),
              );
            },
            icon: const Icon(Icons.logout, color: kPrimaryColor),
            tooltip: 'Se déconnecter',
          ),
      ],
    ),
  );
}
 */
