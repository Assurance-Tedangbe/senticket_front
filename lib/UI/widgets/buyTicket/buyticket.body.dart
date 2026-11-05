import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/login.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/services/payment_service.dart';
import 'package:senticket_front/services/ticket_service.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/buyTicket/requestSection.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketASection.dart';
import 'package:senticket_front/UI/widgets/buyTicket/ticketBSection.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.template.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/provider/payment_provider.dart';

import '../payment/payment_webview_page.dart';

// Page d'achat de tickets incluant le PaymentProvider.
// Le MultiProvider permet d'avoir accès à TicketProvider ET PaymentProvider.

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
    // MultiProvider permet d'injecter plusieurs providers simultanément
    return MultiProvider(
      providers: [
        // Garder le TicketProvider existant
        ChangeNotifierProvider.value(
          value: Provider.of<TicketProvider>(context),
        ),
        // Ajouter le PaymentProvider pour les paiements PayDunya
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(PaymentApiService()),
        ),
      ],
      child: Consumer<TicketProvider>(
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
      ),
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
            'Connectez-vous pour pouvoir acheter des tickets',
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

//======== Nouveau système d'achat de tickets
/*
class BuyTicketBody extends StatelessWidget {
  const BuyTicketBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, TicketProvider, PaymentProvider>(
      builder: (context, userProvider, ticketProvider, paymentProvider, _) {
        final user = userProvider.currentUser;

        if (user == null || user.role.name.toUpperCase() != 'ETUDIANT') {
          return const Center(
            child: Text(
              'Accès réservé aux étudiants',
              style: TextStyle(color: greyBorderColor),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Titre ─────────────────────────────────────────────
              const Text(
                'Choisir vos tickets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kThirdColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sélectionnez le nombre de tickets souhaités',
                style: TextStyle(fontSize: 13, color: greyBorderColor),
              ),
              const SizedBox(height: 24),

              // ── Ticket Type A ─────────────────────────────────────
              _buildTicketStepper(
                context: context,
                label: 'Ticket Type A',
                subtitle: 'Petit-déjeuner',
                price: 100,
                color: kPrimaryColor,
                count: ticketProvider.countA,
                onIncrement: ticketProvider.incrementA,
                onDecrement: ticketProvider.decrementA,
              ),
              const SizedBox(height: 16),

              // ── Ticket Type B ─────────────────────────────────────
              _buildTicketStepper(
                context: context,
                label: 'Ticket Type B',
                subtitle: 'Déjeuner / Dîner',
                price: 150,
                color: cyanColor,
                count: ticketProvider.countB,
                onIncrement: ticketProvider.incrementB,
                onDecrement: ticketProvider.decrementB,
              ),
              const SizedBox(height: 32),

              // ── Récapitulatif ─────────────────────────────────────
              if (ticketProvider.hasSelection)
                _buildSummary(ticketProvider),

              const SizedBox(height: 24),

              // ── Bouton Payer ──────────────────────────────────────
              _buildPayButton(
                context: context,
                user: user,
                ticketProvider: ticketProvider,
                paymentProvider: paymentProvider,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketStepper({
    required BuildContext context,
    required String label,
    required String subtitle,
    required int price,
    required Color color,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: textContainerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: count > 0 ? color : greyBorderColor.withOpacity(0.3),
          width: count > 0 ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(color: boxshadowColor, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Pastille colorée
          Container(
            width: 10,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 14),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kThirdColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: kThirdColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$price FCFA / ticket',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Stepper +/-
          Row(
            children: [
              IconButton(
                onPressed: count > 0 ? onDecrement : null,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: count > 0 ? color : greyBorderColor,
                  size: 28,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: count > 0 ? color : kThirdColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: Icon(Icons.add_circle_outline, color: color, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(TicketProvider ticketProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Récapitulatif de votre commande',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kThirdColor,
            ),
          ),
          const Divider(height: 16),

          if (ticketProvider.countA > 0)
            _buildSummaryLine(
              '${ticketProvider.countA} × Ticket Type A (petit-déj.)',
              '${ticketProvider.countA * 100} FCFA',
            ),

          if (ticketProvider.countB > 0)
            _buildSummaryLine(
              '${ticketProvider.countB} × Ticket Type B (déj./dîner)',
              '${ticketProvider.countB * 150} FCFA',
            ),

          const Divider(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: kThirdColor,
                ),
              ),
              Text(
                '${ticketProvider.totalAmount.toInt()} FCFA',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: kThirdColor)),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kThirdColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(
      {required BuildContext context,
        required user,
        required TicketProvider ticketProvider,
        required PaymentProvider paymentProvider}) {

    final canPay = ticketProvider.hasSelection && !paymentProvider.isLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canPay
            ? () => _initiatePayment(
            context, user, ticketProvider, paymentProvider)
            : null,
        icon: paymentProvider.isLoading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2),
        )
            : const Icon(Icons.payment, color: Colors.white),
        label: Text(
          paymentProvider.isLoading
              ? 'Initialisation...'
              : ticketProvider.hasSelection
              ? 'Payer ${ticketProvider.totalAmount.toInt()} FCFA'
              : 'Sélectionnez des tickets',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: canPay ? kPrimaryColor : greyBorderColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _initiatePayment(
      BuildContext context,
      user,
      TicketProvider ticketProvider,
      PaymentProvider paymentProvider,
      ) async {
    await paymentProvider.initiatePayment(
      userId: user.userId!,
      countA: ticketProvider.countA,
      countB: ticketProvider.countB,
      totalAmount: ticketProvider.totalAmount,
    );

    if (!context.mounted) return;

    if (paymentProvider.paymentUrl != null) {
      // Réinitialiser la sélection avant d'ouvrir le WebView
      ticketProvider.resetSelection();

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaymentWebViewPage()),
      );
    }
  }
}*/
