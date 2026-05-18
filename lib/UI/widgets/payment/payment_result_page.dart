import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/enums/payment_state.dart';
import 'package:senticket_front/provider/payment_provider.dart';
import 'package:senticket_front/provider/ticket_provider.dart';

//****************** PAGE DE RÉSULTAT DU PAIEMENT ******************
//
// Affichée après la fermeture du WebView PayDunya.
// Gère deux phases :
//   1. POLLING ACTIF : Affiche un spinner "Vérification en cours..."
//   2. ÉTAT TERMINAL : Affiche succès, annulation ou erreur
//
// Intégration avec TicketProvider :
//   En cas de succès, recharge les tickets (forceRefresh: true)
//   pour que l'UI reflète immédiatement les nouveaux tickets de l'étudiant.
class PaymentResultPage extends StatefulWidget {
  const PaymentResultPage({super.key});

  @override
  State<PaymentResultPage> createState() => _PaymentResultPageState();
}

class _PaymentResultPageState extends State<PaymentResultPage> {
  bool _hasReloadedTickets = false; // Évite les rechargements multiples

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        // Quand le paiement est confirmé, recharger les tickets automatiquement
        if (provider.isSuccess && !_hasReloadedTickets) {
          _hasReloadedTickets = true;

          // Utiliser addPostFrameCallback pour éviter les setState pendant le build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _reloadTicketsAfterSuccess(context);
          });
        }

        return PopScope(
          // Empêcher le retour arrière pendant le polling
          // (l'utilisateur doit attendre la confirmation)
          canPop: !provider.isPolling,
          child: Scaffold(
            backgroundColor: kSecondColor,
            appBar: AppBar(
              title: const Text('Résultat du paiement'),
              backgroundColor: kPrimaryColor,
              foregroundColor: kSecondColor,
              // Pas de bouton retour pendant le polling
              automaticallyImplyLeading: !provider.isPolling,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildContent(context, provider),
              ),
            ),
          ),
        );
      },
    );
  }

  // Recharge les tickets depuis le backend après un paiement réussi
  // Appelée une seule fois grâce au flag _hasReloadedTickets
  Future<void> _reloadTicketsAfterSuccess(BuildContext context) async {
    try {
      // Accède au TicketProvider pour forcer le rechargement du cache
      // Le backend a déjà attribué les tickets via le webhook
      final ticketProvider = Provider.of<TicketProvider>(
        context,
        listen: false,
      );
      await ticketProvider.loadAllTickets(forceRefresh: true);
      print('[PaymentResult] Tickets rechargés après paiement réussi');
    } catch (e) {
      print('[PaymentResult] Erreur rechargement tickets: $e');
      // Ne pas faire échouer l'affichage du succès si le rechargement échoue
    }
  }

  // Construit le contenu selon l'état actuel du PaymentProvider
  Widget _buildContent(BuildContext context, PaymentProvider provider) {
    switch (provider.state) {
      case PaymentState.polling:
        return _buildPollingView(provider);
      case PaymentState.success:
        return _buildSuccessView(context, provider);
      case PaymentState.cancelled:
        return _buildCancelledView(context, provider);
      case PaymentState.failed:
        return _buildFailedView(context, provider);
      default:
        // Cas par défaut : afficher le polling (ne devrait pas arriver sur cette page)
        return _buildPollingView(provider);
    }
  }

  // ===== VUE POLLING =====
  // Affichée pendant la vérification périodique du statut
  Widget _buildPollingView(PaymentProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spinner animé
          const SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              color: kPrimaryColor,
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Vérification du paiement...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kThirdColor,
            ),
          ),
          const SizedBox(height: 12),
          // Compteur de tentatives pour informer l'utilisateur
          Text(
            'Tentative ${provider.pollingAttempts} sur 60',
            style: const TextStyle(fontSize: 14, color: greyBorderColor),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
            ),
            child: const Column(
              children: [
                Icon(Icons.info_outline, color: kPrimaryColor, size: 20),
                SizedBox(height: 8),
                Text(
                  'Votre paiement est en cours de confirmation.\n'
                  'Ne fermez pas l\'application.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: greyBorderColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== VUE SUCCÈS =====
  // Affichée quand PaymentStatus.completed est reçu
  Widget _buildSuccessView(BuildContext context, PaymentProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cercle vert avec icône de validation
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: validateBtnColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: validateBtnColor,
              size: 80,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Paiement réussi !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: validateBtnColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Vos tickets ont été ajoutés à votre compte.',
            style: TextStyle(fontSize: 16, color: greyBorderColor),
            textAlign: TextAlign.center,
          ),
          // Afficher le token de transaction pour référence
          if (provider.transactionId != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: greyBorderColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Réf: ${provider.transactionId}',
                style: const TextStyle(
                  fontSize: 11,
                  color: greyBorderColor,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
          const SizedBox(height: 40),
          // Bouton retour à l'accueil
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Réinitialiser le provider avant de quitter
                provider.reset();
                // Retourner à la page principale (pop jusqu'à la première route)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text(
                'Retour à l\'accueil',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: validateBtnColor,
                foregroundColor: kSecondColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bouton pour acheter d'autres tickets
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                provider.reset();
                // Retourner à la page d'achat (pop de result + pop de la page actuelle)
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kPrimaryColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Acheter d\'autres tickets',
                style: TextStyle(fontSize: 16, color: kPrimaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== VUE ANNULATION =====
  Widget _buildCancelledView(BuildContext context, PaymentProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cyanColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cancel, color: cyanColor, size: 80),
          ),
          const SizedBox(height: 28),
          const Text(
            'Paiement annulé',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cyanColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Vous avez annulé le paiement.\n'
            'Vos tickets n\'ont pas été achetés.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: greyBorderColor),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                provider.reset();
                Navigator.of(context).pop(); // Retour à BuyTicket
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Réessayer', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: kSecondColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== VUE ÉCHEC =====
  Widget _buildFailedView(BuildContext context, PaymentProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: redErrorColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error, color: redErrorColor, size: 80),
          ),
          const SizedBox(height: 28),
          const Text(
            'Paiement échoué',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: redErrorColor,
            ),
          ),
          const SizedBox(height: 16),
          // Afficher le message d'erreur du provider (comme TicketProvider.error)
          if (provider.error.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: redErrorColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: redErrorColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                provider.error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: redErrorColor),
              ),
            ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                provider.reset();
                Navigator.of(context).pop(); // Retour à BuyTicket
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: redErrorColor,
                foregroundColor: kSecondColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
