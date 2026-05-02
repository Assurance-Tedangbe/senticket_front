// Page affichée après un paiement réussi.
// L'utilisateur y est redirigé via deep linking après le callback PayDunya.

import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class PaymentSuccessPage extends StatelessWidget {
  /// ID de la transaction PayDunya (reçu via deep linking)
  final String? transactionId;

  const PaymentSuccessPage({super.key, this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement réussi'),
        backgroundColor: kPrimaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône de succès
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 20),

            // Message de succès
            const Text(
              'Paiement effectué avec succès !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            const Text(
              'Vos tickets ont été ajoutés à votre compte.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Afficher l'ID de transaction (optionnel)
            if (transactionId != null)
              Text(
                'Transaction ID: $transactionId',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 30),

            // Bouton pour retourner à l'accueil
            ElevatedButton(
              onPressed: () {
                // Retourner à la page d'accueil
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text(
                'Retour à l\'accueil',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
