import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/customWidgets/customCircularProgressIndicator.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

class BuyTicketBtn extends StatelessWidget {
  final VoidCallback onSuccess;

  const BuyTicketBtn({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Consumer<TicketProvider>(
          builder: (context, ticketProvider, child) {
            final selectedTickets = ticketProvider.selectedTickets;
            final selectedCount = selectedTickets.length;
            final isProcessing = ticketProvider.isPurchasingTickets;

            // Vérifier si l'utilisateur est connecté
            final isLoggedIn = userProvider.currentUser != null;
            final isStudent = isLoggedIn
                ? userProvider.currentUser!.role.name.toUpperCase() ==
                      'ETUDIANT'
                : false;

            double totalPrice = 0;
            for (var ticket in selectedTickets) {
              totalPrice += ticket.price;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Afficher l'état de connexion
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLoggedIn
                          ? (isStudent
                                ? ticketSectionColor
                                : ticketSectionColor)
                          : greyBorderColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                if (selectedCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$selectedCount ticket(s) sélectionné(s)',
                          style: const TextStyle(
                            color: kThirdColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Total: ${totalPrice.toStringAsFixed(2)} FCFA',
                          style: const TextStyle(
                            color: kThirdColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: size.width * 0.8,
                  height: size.height / 14.0,
                  child: ElevatedButton(
                    onPressed:
                        (isProcessing ||
                            selectedCount == 0 ||
                            !isLoggedIn ||
                            !isStudent)
                        ? null
                        : () async {
                            final success = await ticketProvider
                                .purchaseTicketsWithContext(context);

                            if (success) {
                              final userName =
                                  userProvider.currentUser?.username ??
                                  'l\'utilisateur';

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$selectedCount ticket(s) acheté(s) avec succès par $userName',
                                  ),
                                  backgroundColor: validateBtnColor,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                              onSuccess();
                            } else if (ticketProvider.error.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ticketProvider.error),
                                  backgroundColor: redErrorColor,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isProcessing
                          ? greyBorderColor
                          : (selectedCount == 0 || !isLoggedIn || !isStudent)
                          ? greyBorderColor
                          : kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CustomCircularProgressIndicator(),
                          )
                        : Text(
                            !isLoggedIn
                                ? 'Connectez-vous'
                                : !isStudent
                                ? 'Non permis'
                                : 'Acheter ticket(s) ',
                            style: TextStyle(
                              color: kSecondColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                // Message d'information
                if (!isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Connectez-vous en tant qu\'étudiant pour acheter',
                      style: TextStyle(color: kPrimaryColor, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (!isStudent)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Seuls les étudiants peuvent acheter des tickets',
                      style: TextStyle(color: kPrimaryColor, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/*
// Bouton d'achat de tickets utilisant PayDunya (solution deep)
// Au lieu d'appeler directement purchaseTickets(), il initie un paiement
// PayDunya et redirige l'utilisateur vers la page de paiement.

class BuyTicketBtn extends StatelessWidget {
  /// Callback appelé après le succès du paiement
  final VoidCallback onSuccess;

  const BuyTicketBtn({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Consumer<TicketProvider>(
          builder: (context, ticketProvider, child) {
            return Consumer<PaymentProvider>(
              builder: (context, paymentProvider, child) {
                // Récupérer les tickets sélectionnés
                final selectedTickets = ticketProvider.selectedTickets;
                final selectedCount = selectedTickets.length;

                // Indicateur de chargement (achat en cours ou paiement en cours)
                final isProcessing =
                    ticketProvider.isPurchasingTickets ||
                    paymentProvider.isLoading;

                // Vérifier si l'utilisateur est connecté et étudiant
                final isLoggedIn = userProvider.currentUser != null;
                final isStudent = isLoggedIn
                    ? userProvider.currentUser!.role.name.toUpperCase() ==
                          'ETUDIANT'
                    : false;

                // Calculer le montant total et compter les types de tickets
                double totalPrice = 0;
                int countA = 0;
                int countB = 0;
                List<int> selectedTicketIds = [];

                for (var ticket in selectedTickets) {
                  totalPrice += ticket.price;
                  selectedTicketIds.add(ticket.id!);
                  if (ticket.type == TicketType.a) {
                    countA++;
                  } else {
                    countB++;
                  }
                }

                /**
                 * Gère le paiement avec PayDunya
                 * 1. Crée la requête d'initiation
                 * 2. Appelle le provider pour initier le paiement
                 * 3. Ouvre l'URL PayDunya dans le navigateur
                 */
                Future<void> _handlePayDunyaPayment() async {
                  // 1. Créer la requête d'initiation
                  final request = PaymentInitiationDTO(
                    userId: userProvider.currentUser!.userId!,
                    selectedTicketIds: selectedTicketIds,
                    totalAmount: totalPrice,
                    countA: countA,
                    countB: countB,
                  );

                  // 2. Initier le paiement
                  final paymentUrl = await paymentProvider.initiatePayment(
                    request,
                  );

                  // 3. Ouvrir l'URL PayDunya dans le navigateur
                  if (paymentUrl != null &&
                      await canLaunchUrl(Uri.parse(paymentUrl))) {
                    await launchUrl(
                      Uri.parse(paymentUrl),
                      mode: LaunchMode.externalApplication,
                    );
                    // Le callback onSuccess sera appelé après le retour de PayDunya
                    // via le deep linking dans la page de succès
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          paymentProvider.error.isNotEmpty
                              ? paymentProvider.error
                              : 'Impossible d\'ouvrir la page de paiement',
                        ),
                        backgroundColor: redErrorColor,
                      ),
                    );
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Affichage du résumé de la sélection
                    if (selectedCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '$selectedCount ticket(s) sélectionné(s)',
                              style: const TextStyle(
                                color: kThirdColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Total: ${totalPrice.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                color: kThirdColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Bouton de paiement PayDunya
                    SizedBox(
                      width: size.width * 0.8,
                      height: size.height / 14.0,
                      child: ElevatedButton(
                        // Le bouton est désactivé si:
                        // - Un traitement est en cours
                        // - Aucun ticket sélectionné
                        // - Utilisateur non connecté
                        // - Utilisateur non étudiant
                        onPressed:
                            (isProcessing ||
                                selectedCount == 0 ||
                                !isLoggedIn ||
                                !isStudent)
                            ? null
                            : _handlePayDunyaPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isProcessing
                              ? greyBorderColor
                              : (selectedCount == 0 ||
                                    !isLoggedIn ||
                                    !isStudent)
                              ? greyBorderColor
                              : kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                !isLoggedIn
                                    ? 'Connectez-vous'
                                    : !isStudent
                                    ? 'Non permis'
                                    : 'Payer ${totalPrice.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(
                                  color: kSecondColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    // Messages d'information
                    if (!isLoggedIn)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Connectez-vous en tant qu\'étudiant pour acheter',
                          style: TextStyle(color: kPrimaryColor, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else if (!isStudent)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Seuls les étudiants peuvent acheter des tickets',
                          style: TextStyle(color: kPrimaryColor, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
*/

/* Impl. sans dynamisation
class BuyTicketBtn extends StatefulWidget {
  const BuyTicketBtn({super.key});

  @override
  State<BuyTicketBtn> createState() => _BuyTicketBtnState();
}

class _BuyTicketBtnState extends State<BuyTicketBtn> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.3,
      height: size.height / 14.0,
      child: ElevatedButton(
        onPressed: () => print('buy pressed'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          textStyle: const TextStyle(
              color: kSecondColor, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        child: const Text('Acheter'),
      ),
    );
  }
} */
