import 'package:flutter/material.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/UI/widgets/customWidgets/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';

/*
  Widget pour le champ "Mot de passe" avec fonctionnalité de visibilité.
  Gère dynamiquement l'affichage/masquage du mot de passe.
*/
class PasswordSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const PasswordSection({
    super.key,
    required this.controller,
    this.onChanged,
  });

  /* Besoin du Consumer:
     userProvider.isPasswordVisible → Changement d'état booléen
     userProvider.passwordError → Messages d'erreur dynamiques */
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Label(text: 'Mot de passe'),
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
              height: 50,
              child: TextFormField(
                controller: controller,
                keyboardType:
                    TextInputType.visiblePassword, // Clavier pour mot de passe
                obscureText:
                    !userProvider.isPasswordVisible, // Masque le texte si false
                style: const TextStyle(color: enterTextFieldColor),
                onChanged: onChanged,
                cursorColor: kPrimaryColor,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 11),
                  prefixIcon: const Icon(Icons.password, color: kPrimaryColor),
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
                      // Bascule l'état de visibilité via le Provider
                      userProvider.togglePasswordVisibility();
                    },
                  ),
                  border: InputBorder.none,
                  errorText: userProvider.passwordError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
