import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/payment_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/UI/widgets/payment/payment_webview_page.dart';
import 'package:senticket_front/UI/widgets/payment/payment_result_page.dart';
import '../../../model/ticket_pricing.dart';
import '../../../provider/purchase_cart_provider.dart';

// REQUEST SECTION - SECTION BOUTON D'ACHAT
// Widget existant MODIFIÉ pour intégrer le flux de paiement PayDunya.
// Changements par rapport à l'ancienne version :
//   - Remplace purchaseTicketsWithContext() (achat direct)
//   - par initiatePayment() de PaymentProvider (paiement PayDunya)
// Flux :
//   1. Utilisateur sélectionne tickets
//   2. Clique sur "Confirmer l'achat" dans RequestSection
//   3. PaymentProvider.initiatePayment() → appel backend
//   4. Navigation vers PaymentWebViewPage (WebView PayDunya)
//   5. Navigation vers PaymentResultPage (polling + résultat)
//   6. En cas de succès : TicketProvider.loadAllTickets(forceRefresh: true)


class RequestSection extends StatelessWidget {
  const RequestSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PurchaseCartProvider, PaymentProvider>(
      builder: (context, cart, payment, _) {
        final isLoading = payment.isLoading;
        final isDisabled = isLoading || cart.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!cart.isEmpty) ...[
              _buildSummary(cart),
              const SizedBox(height: 12),
            ],
            if (payment.error.isNotEmpty) _buildError(payment),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isDisabled ? null : () => _handlePayment(context),
                icon: isLoading
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: kSecondColor, strokeWidth: 2.5))
                    : const Icon(Icons.payment, size: 22),
                label: Text(
                  isLoading
                      ? 'Connexion à PayDunya...'
                      : cart.isEmpty
                      ? 'Choisissez des tickets'
                      : 'Payer ${cart.totalAmount.toInt()} FCFA',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDisabled ? greyBorderColor : blueOfImages,
                  foregroundColor: kSecondColor,
                  disabledBackgroundColor: greyBorderColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, size: 14, color: greyBorderColor),
                SizedBox(width: 4),
                Text('Paiement sécurisé via Wave ou Orange Money',
                    style: TextStyle(fontSize: 11, color: greyBorderColor)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummary(PurchaseCartProvider cart) {
    Widget line(String label, String amount) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(amount,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text('Récapitulatif de votre commande',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: kThirdColor, fontSize: 13)),
          const Divider(height: 12),
          if (cart.countA > 0)
            line('${cart.countA} × Ticket A (petit-déj.)',
                '${(cart.countA * TicketPricing.priceA).toInt()} FCFA'),
          if (cart.countB > 0)
            line('${cart.countB} × Ticket B (déj./dîner)',
                '${(cart.countB * TicketPricing.priceB).toInt()} FCFA'),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold, color: kThirdColor)),
              Text('${cart.totalAmount.toInt()} FCFA',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                      fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(PaymentProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: redErrorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: redErrorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: redErrorColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(provider.error,
                  style: const TextStyle(color: redErrorColor, fontSize: 13))),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: redErrorColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: provider.clearError,
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment(BuildContext context) async {
    final cart = context.read<PurchaseCartProvider>();
    final payment = context.read<PaymentProvider>();
    final ticketProvider = context.read<TicketProvider>(); // provider global
    final user = context.read<UserProvider>().currentUser;

    if (user == null || user.userId == null) {
      _snack(context, 'Vous devez être connecté pour payer.');
      return;
    }
    if (user.role.name.toUpperCase() != 'ETUDIANT') {
      _snack(context, 'Seuls les étudiants peuvent acheter des tickets.');
      return;
    }

    // 1. Initier le paiement : plus aucun ID de ticket, uniquement des quantités
    await payment.initiatePayment(
      userId: user.userId!,
      countA: cart.countA,
      countB: cart.countB,
      totalAmount: cart.totalAmount,
    );
    if (!context.mounted) return;

    final url = payment.paymentUrl;
    if (url == null || url.isEmpty) return; // erreur déjà affichée

    // 2. WebView PayDunya
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: payment,
        child: PaymentWebViewPage(paymentUrl: url),
      ),
    ));
    if (!context.mounted) return;

    // 3. Page de résultat (polling)
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: payment),
          ChangeNotifierProvider.value(value: ticketProvider),
        ],
        child: const PaymentResultPage(),
      ),
    ));
    if (!context.mounted) return;

    // 4. Succès : vider le panier
    if (payment.isSuccess) {
      cart.clear();
      payment.reset();
    }
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: redErrorColor),
    );
  }
}

