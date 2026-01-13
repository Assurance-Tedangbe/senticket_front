import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

/*
  Widget pour le bouton de connexion.
  Dynamiquement activé/désactivé selon la validation du formulaire.
*/
class LoginBtn extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const LoginBtn({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 25),
          width: double.infinity,
          height: 100,
          child: ElevatedButton(
            onPressed:
                userProvider.isLoggingIn || !userProvider.isLoginFormValid
                    ? null // Désactivé si validation échoue
                    : () async {
                        final success = await userProvider.submitLogin();
                        if (success) {
                          // Afficher un message de succès
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Connexion réussie !'),
                              backgroundColor: validateBtnColor,
                            ),
                          );

                          // Navigation ou callback
                          onLoginSuccess();
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
              backgroundColor:
                  userProvider.isLoginFormValid && !userProvider.isLoggingIn
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
            child: userProvider.isLoggingIn
                ? const CircularProgressIndicator(color: kSecondColor)
                : const Text('Se connecter'),
          ),
        );
      },
    );
  }
}
