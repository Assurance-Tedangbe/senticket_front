import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/login/loginLabel.dart';
import 'package:senticket_front/UI/widgets/customWidgets/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

/*
  Widget pour le champ "Mot de passe" de la page de connexion.
  Avec fonctionnalité de visibilité/masquage.
*/
class LoginPasswordSection extends StatelessWidget {
  final TextEditingController controller; // ← ICI
  final ValueChanged<String>? onChanged; // ⭐ UTILISÉ ICI

  const LoginPasswordSection({
    super.key,
    required this.controller,
    this.onChanged,
  });

  /* Consumer est utilisé QUAND ON A BESOIN DE "LIRE" DES DONNÉES DYNAMIQUES
     ce widgets a besoin d'accéder à des données dynamiques du Provider :
     userProvider.isPasswordVisible → Changement d'état booléen
     userProvider.passwordError → Messages d'erreur dynamiques */

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      // Consumer permet de réagir aux changements du Provider // ← ICI
      builder: (context, userProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const LoginLabel(text: 'Mot de passe'),
            const SizeBoxBtwLabelField(),
            Container(
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: kSecondColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: boxshadowColor,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color: kPrimaryColor, width: 1),
              ),
              height: 60,
              child: TextFormField(
                controller: controller, // ← ICI
                keyboardType: TextInputType.visiblePassword,
                obscureText: !userProvider.isPasswordVisible,
                style: const TextStyle(color: enterTextFieldColor),
                onChanged: onChanged,
                cursorColor: kPrimaryColor,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 14),
                  prefixIcon: const Icon(Icons.lock, color: kPrimaryColor),
                  hintText: 'Mot de passe',
                  hintStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 12,
                  ),

                  // Bouton pour afficher/masquer le mot de passe
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Change l'icône selon l'état de visibilité
                      userProvider
                              .isPasswordVisible // ← ICI
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: kPrimaryColor,
                    ),
                    onPressed: () {
                      userProvider.togglePasswordVisibility(); // ← ICI
                    },
                  ),
                  border: InputBorder.none,
                  // Affichage des erreurs de validation
                  // errorText: userProvider.loginPasswordError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
