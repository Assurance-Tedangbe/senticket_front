import 'package:flutter/material.dart';
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
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
          width: 320,
          height: 95,
          child: ElevatedButton(
            onPressed: userProvider.isConsultingUser ||
                    !userProvider.isConsultFormValid
                ? null
                : () async {
                    final success = await userProvider.submitConsult();
                    if (success) {
                      /* // Afficher un message de succès
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Compte trouvé avec succès !'),
                          backgroundColor: validateBtnColor,
                        ),
                      );

                      // Navigation
                      onConsultSuccess(); */
                      // Récupérer l'ID de l'utilisateur courant
                      final userId = userProvider.currentUser?.userId;
                      if (userId != null) {
                        onConsultSuccess(userId); // ← Appel avec userId
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur: ID utilisateur non trouvé'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      // Afficher l'erreur
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(userProvider.error),
                          backgroundColor: redErrorColor,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: userProvider.isConsultFormValid &&
                      !userProvider.isConsultingUser
                  ? kPrimaryColor
                  : greyBorderColor,
              shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              textStyle: const TextStyle(
                color: kSecondColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: userProvider.isConsultingUser
                ? const CircularProgressIndicator(color: kSecondColor)
                : const Text('Consulter'),
          ),
        );
      },
    );
  }
}

/* class ConsultBtn extends StatelessWidget {
  const ConsultBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      width: 320,
      height: 95,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ConsultData())),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          textStyle: const TextStyle(
              color: kSecondColor, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        child: const Text('Consulter'),
      ),
    );
  }
} */
