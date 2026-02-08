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
              totalPrice += ticket.ticketPrice;
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
                          : Colors.grey,
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
                  width: size.width * 0.7,
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
                        borderRadius: BorderRadius.circular(8),
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
                              color: kThirdColor,
                              fontSize: 15,
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
