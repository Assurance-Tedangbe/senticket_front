import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/custom.circular.progress.indicator.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

/*
  Widget pour le bouton de consultation de compte.
  Dynamiquement activé/désactivé selon la validation du formulaire.
*/
class ConsultBtn extends StatelessWidget {
  // final VoidCallback onConsultSuccess;
  final void Function(int userId) onConsultSuccess; // ← Correction ici

  const ConsultBtn({
    super.key,
    required this.onConsultSuccess, // ← Correction ici
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
          // width: 335,
          // height: 95,
          width: size.width,
          height: size.height / 8.0,
          child: ElevatedButton(
            onPressed:
                userProvider.isConsultingUser ||
                    !userProvider.isConsultFormValid
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await userProvider.submitConsult();
                    if (success) {
                      // Récupérer l'ID de l'utilisateur courant
                      final userId = userProvider.currentUser?.userId;
                      if (userId != null) {
                        onConsultSuccess(userId); // ← Appel avec userId
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Erreur: ID utilisateur non trouvé'),
                            backgroundColor: redErrorColor,
                          ),
                        );
                      }
                    } else {
                      // Afficher l'erreur
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(userProvider.error),
                          backgroundColor: redErrorColor,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  userProvider.isConsultFormValid &&
                      !userProvider.isConsultingUser
                  ? kPrimaryColor
                  : greyBorderColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              textStyle: const TextStyle(
                color: kSecondColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: userProvider.isConsultingUser
                ? const CustomCircularProgressIndicator()
                : const Text(
                    'Consulter',
                    style: TextStyle(
                      color: kSecondColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

