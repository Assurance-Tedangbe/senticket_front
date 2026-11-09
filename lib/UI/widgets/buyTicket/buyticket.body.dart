import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/login.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticket_quantity_card.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/buyTicket/request_section.dart';
import '../../../model/ticket_pricing.dart';
import '../../../provider/purchase_cart_provider.dart';
import '../home/bloctitle.dart';


class BuyTicketBody extends StatelessWidget {
  const BuyTicketBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.currentUser;
        final isLoggedIn = user != null;
        final isStudent = isLoggedIn && user.role.name.toUpperCase() == 'ETUDIANT';

        return Background(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
            child: SizedBox(
              width: size.width,
              child: isLoggedIn && isStudent
                  ? _buildOrderForm()
                  : isLoggedIn
                  ? _buildNotStudentWarning(context)
                  : _buildLoginRequired(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderForm() {
    return Consumer<PurchaseCartProvider>(
      builder: (context, cart, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BlocTitle(text: 'Choisir tickets'),
            const SizedBox(height: 4),
            const Text(
              'Tickets créés dès que le paiement est confirmé.',
              style: TextStyle(fontSize: 12, color: greyBorderColor),
            ),
            const SizedBox(height: 16),
            TicketQuantityCard(
              label: 'Ticket Type A',
              subtitle: 'Petit-déjeuner',
              unitPrice: TicketPricing.priceA,
              color: kPrimaryColor,
              count: cart.countA,
              canIncrement: cart.canIncrementA,
              onIncrement: cart.incrementA,
              onDecrement: cart.decrementA,
            ),
            const SizedBox(height: 14),
            TicketQuantityCard(
              label: 'Ticket Type B',
              subtitle: 'Déjeuner / Dîner',
              unitPrice: TicketPricing.priceB,
              color: cyanColor,
              count: cart.countB,
              canIncrement: cart.canIncrementB,
              onIncrement: cart.incrementB,
              onDecrement: cart.decrementB,
            ),
            const SizedBox(height: 24),
            const RequestSection(),
          ],
        );
      },
    );
  }

  Widget _buildNotStudentWarning(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.block, size: 80, color: kPrimaryColor),
          const SizedBox(height: 20),
          const Text('Accès réservé aux étudiants',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
          const SizedBox(height: 10),
          const Text('Seuls les ETUDIANTS peuvent acheter des tickets.',
              textAlign: TextAlign.center,
              style: TextStyle(color: greyBorderColor)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              final up = Provider.of<UserProvider>(context, listen: false);
              up.currentUser = null;
              up.resetLoginForm();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor, foregroundColor: kSecondColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.lock_person, size: 80, color: greyBorderColor),
          const SizedBox(height: 20),
          const Text('Authentification requise',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: greyBorderColor)),
          const SizedBox(height: 10),
          const Text('Connectez-vous pour pouvoir acheter des tickets',
              textAlign: TextAlign.center,
              style: TextStyle(color: greyBorderColor)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => LoginPage())),
            icon: const Icon(Icons.login),
            label: const Text('Se connecter'),
            style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor, foregroundColor: kSecondColor),
          ),
        ],
      ),
    );
  }
}

