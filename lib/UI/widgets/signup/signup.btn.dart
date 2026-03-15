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
  final VoidCallback onSignupSuccess;

  const SignupBtn({
    super.key,
    required this.onSignupSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 25),
          width: double.infinity,
          height: 90,
          child: ElevatedButton(
            onPressed: userProvider.isCreatingUser || !userProvider.isFormValid
                ? null
                : () async {
                    final success = await userProvider.submitSignup();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Compte créé avec succès !'),
                          backgroundColor: validateBtnColor,
                        ),
                      );

                      userProvider.resetForm();

                      // Navigation ou callback
                      onSignupSuccess();
                    } else {
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
                    .isCreatingUser
                ? // Affiche un indicateur de chargement pendant la création
                  const CustomCircularProgressIndicator()
                : const Text('Créer un compte', style: TextStyle(color: kSecondColor)),
          ),
        );
      },
    );
  }
}
