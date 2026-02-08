import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/customCircularProgressIndicator.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/constants.dart';

/*
  Widget pour le bouton de création de compte.
  Dynamiquement activé/désactivé selon la validation du formulaire.
*/
class SignupBtn extends StatelessWidget {
  final VoidCallback onSignupSuccess; // ← ICI

  const SignupBtn({
    super.key,
    required this.onSignupSuccess, // ← ICI
  });

  /* Consumer est utilisé QUAND ON A BESOIN DE "LIRE" DES DONNÉES DYNAMIQUES
     Ces widget a besoin d'accéder à des données dynamiques du Provider  */

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      // ← ICI
      builder: (context, userProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 25),
          width: double.infinity,
          height: 90,
          child: ElevatedButton(
            /* Le bouton est désactivé si :
                1. Une création est déjà en cours
                2. Le formulaire n'est pas valide  */
            // ← ICI
            onPressed: userProvider.isCreatingUser || !userProvider.isFormValid
                ? null
                : () async {
                    final success = await userProvider.submitSignup(); // ← ICI
                    if (success) {
                      // Afficher un message de succès
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Compte créé avec succès !'),
                          backgroundColor: validateBtnColor,
                        ),
                      );

                      // Réinitialiser le formulaire
                      userProvider.resetForm(); // ← ICI

                      // Navigation ou callback
                      onSignupSuccess(); // ← ICI
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
              // Change la couleur selon l'état de validation
              backgroundColor: // ← ICI
              userProvider.isFormValid && !userProvider.isCreatingUser
                  ? kPrimaryColor
                  : greyBorderColor,
              shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              textStyle: const TextStyle(
                color: kSecondColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child:
                userProvider
                    .isCreatingUser // ← ICI
                ? // Affiche un indicateur de chargement pendant la création
                  const CustomCircularProgressIndicator()
                : const Text('Créer un compte'),
          ),
        );
      },
    );
  }
}
