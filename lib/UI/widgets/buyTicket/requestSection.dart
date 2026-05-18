import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/enums/ticket_type.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/payment_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/UI/widgets/payment/payment_webview_page.dart';
import 'package:senticket_front/UI/widgets/payment/payment_result_page.dart';

// REQUEST SECTION - SECTION BOUTON D'ACHAT
//
// Widget existant MODIFIÉ pour intégrer le flux de paiement PayDunya.
//
// Changements par rapport à l'ancienne version :
//   - Remplace purchaseTicketsWithContext() (achat direct)
//   - par initiatePayment() de PaymentProvider (paiement PayDunya)
//
// Flux :
//   1. Utilisateur sélectionne tickets dans TicketASection / TicketBSection
//   2. Clique sur "Confirmer l'achat" dans RequestSection
//   3. PaymentProvider.initiatePayment() → appel backend
//   4. Navigation vers PaymentWebViewPage (WebView PayDunya)
//   5. Navigation vers PaymentResultPage (polling + résultat)
//   6. En cas de succès : TicketProvider.loadAllTickets(forceRefresh: true)
class RequestSection extends StatelessWidget {
  const RequestSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TicketProvider, PaymentProvider>(
      // Consumer2 allows a widget to listen to changes from two separate providers
      // and rebuild only when either of those specific values changes
      // Consumer2 écoute deux providers simultanément
      // TicketProvider : pour connaître les tickets sélectionnés
      // PaymentProvider : pour gérer l'état du paiement
      builder: (context, ticketProvider, paymentProvider, child) {
        final selectedTickets = ticketProvider.selectedTickets;
        final isLoading = paymentProvider.isLoading;

        // Calculer le montant total à afficher sur le bouton
        final totalAmount = selectedTickets.fold<double>(
          0.0,
          (sum, ticket) => sum + ticket.price,
        );

        // Compter les types de tickets sélectionnés
        final countA = selectedTickets
            .where((t) => t.type.toBackend == 'A')
            .length;
        final countB = selectedTickets
            .where((t) => t.type.toBackend == 'B')
            .length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== RÉSUMÉ DE LA SÉLECTION =====
            if (selectedTickets.isNotEmpty) ...[
              _buildSelectionSummary(countA, countB, totalAmount),
              const SizedBox(height: 12),
            ],

            // ===== AFFICHAGE DES ERREURS (comme dans TicketProvider) =====
            if (paymentProvider.error.isNotEmpty)
              _buildErrorDisplay(paymentProvider),

            // ===== BOUTON PRINCIPAL D'ACHAT =====
            _buildPaymentButton(
              context,
              ticketProvider,
              paymentProvider,
              selectedTickets,
              totalAmount,
              countA,
              countB,
              isLoading,
            ),

            // ===== INDICATION DES MOYENS DE PAIEMENT =====
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, size: 14, color: greyBorderColor),
                SizedBox(width: 4),
                Text(
                  'Paiement sécurisé via Wave ou Orange Money',
                  style: TextStyle(fontSize: 11, color: greyBorderColor),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Résumé des tickets sélectionnés (Type A et Type B avec montants)
  Widget _buildSelectionSummary(int countA, int countB, double total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text(
            'Récapitulatif de votre commande',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: kThirdColor,
              fontSize: 13,
            ),
          ),
          const Divider(height: 12),
          if (countA > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$countA × Ticket Type A (petit-déj.)',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  '${countA * 100} FCFA',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          if (countA > 0 && countB > 0) const SizedBox(height: 4),
          if (countB > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$countB × Ticket Type B (déj./dîner)',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  '${countB * 150} FCFA',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kThirdColor,
                ),
              ),
              Text(
                '${total.toInt()} FCFA',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Affichage d'erreur (même style que dans BuyTicketBody._buildErrorDisplay)
  Widget _buildErrorDisplay(PaymentProvider provider) {
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
            child: Text(
              provider.error,
              style: const TextStyle(color: redErrorColor, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: redErrorColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => provider.clearError(),
          ),
        ],
      ),
    );
  }

  // Bouton principal de paiement avec indicateur de chargement
  Widget _buildPaymentButton(
    BuildContext context,
    TicketProvider ticketProvider,
    PaymentProvider paymentProvider,
    List selectedTickets,
    double totalAmount,
    int countA,
    int countB,
    bool isLoading,
  ) {
    // Le bouton est désactivé si : chargement en cours OU aucun ticket sélectionné
    final isDisabled = isLoading || selectedTickets.isEmpty;

    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isDisabled
            ? null
            : () => _handlePayment(
                context,
                ticketProvider,
                paymentProvider,
                selectedTickets,
                totalAmount,
                countA,
                countB,
              ),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: kSecondColor,
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(Icons.payment, size: 22),
        label: Text(
          isLoading
              ? 'Connexion à PayDunya...'
              : selectedTickets.isEmpty
              ? 'Sélectionnez des tickets'
              : 'Payer ${totalAmount.toInt()} FCFA',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? greyBorderColor : validateBtnColor,
          foregroundColor: kSecondColor,
          disabledBackgroundColor: greyBorderColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // GESTION DU PAIEMENT PAYDUNYA
  //
  // Orchestre le flux complet :
  //   1. Récupère l'utilisateur connecté (UserProvider)
  //   2. Initie le paiement (PaymentProvider → backend)
  //   3. Ouvre le WebView (PaymentWebViewPage)
  //   4. Ouvre la page de résultat (PaymentResultPage + polling)
  //   5. En cas de succès : recharge les tickets
  Future<void> _handlePayment(
    BuildContext context,
    TicketProvider ticketProvider,
    PaymentProvider paymentProvider,
    List selectedTickets,
    double totalAmount,
    int countA,
    int countB,
  ) async {
    // 1. Récupérer l'utilisateur connecté
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    if (user == null || user.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur : Vous devez être connecté pour payer.'),
          backgroundColor: redErrorColor,
        ),
      );
      return;
    }

    // Vérification supplémentaire : seuls les ETUDIANT peuvent acheter
    if (user.role.name.toUpperCase() != 'ETUDIANT') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seuls les étudiants peuvent acheter des tickets.'),
          backgroundColor: redErrorColor,
        ),
      );
      return;
    }

    // 2. Extraire les IDs des tickets sélectionnés
    final ticketIds = selectedTickets.map<int>((t) => t.id as int).toList();

    // 3. Initier le paiement auprès du backend
    await paymentProvider.initiatePayment(
      userId: user.userId!,
      selectedTicketIds: ticketIds,
      totalAmount: totalAmount,
      countA: countA,
      countB: countB,
    );

    // Vérifier que le context est encore valide après l'appel async
    if (!context.mounted) return;

    // Vérifier que l'initiation a bien réussi (URL disponible)
    if (paymentProvider.paymentUrl == null ||
        paymentProvider.paymentUrl!.isEmpty) {
      // L'erreur est déjà gérée dans le provider et affichée dans l'UI
      return;
    }

    // 4. Ouvrir le WebView PayDunya
    // L'utilisateur va interagir avec la page de paiement (Wave ou Orange Money)
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: paymentProvider, // Partager le même provider avec le WebView
          child: PaymentWebViewPage(paymentUrl: paymentProvider.paymentUrl!),
        ),
      ),
    );

    // Vérifier le context après le WebView
    if (!context.mounted) return;

    // 5. Ouvrir la page de résultat (polling automatique via le provider)
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            // Partager PaymentProvider (contient le token de la transaction)
            ChangeNotifierProvider.value(value: paymentProvider),
            // Partager TicketProvider (pour recharger les tickets après succès)
            ChangeNotifierProvider.value(value: ticketProvider),
          ],
          child: const PaymentResultPage(),
        ),
      ),
    );

    // 6. Après retour de PaymentResultPage : nettoyer les sélections si succès
    if (!context.mounted) return;
    if (paymentProvider.isSuccess) {
      ticketProvider.clearAllSelections();
      paymentProvider.reset();
    }
  }
}

/* Implémentation précédente (achat direct sans PayDunya)
class RequestSection extends StatefulWidget {
  const RequestSection({super.key});

  @override
  State<RequestSection> createState() => _RequestSectionState();
}

class _RequestSectionState extends State<RequestSection> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
    });

    // Désélectionner tous les tickets
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    ticketProvider.clearAllSelections();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BuyTicketBtn(
                  onSuccess: () {
                    _clearForm();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
 */
