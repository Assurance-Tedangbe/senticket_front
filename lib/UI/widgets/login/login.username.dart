import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/login/loginLabel.dart';
import 'package:senticket_front/UI/widgets/updateUser/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

/*
  Widget pour le champ "Nom d'utilisateur" de la page de connexion.
*/
class LoginUsernameSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const LoginUsernameSection({
    super.key,
    required this.controller, // ← ICI
    this.onChanged,
  });

/* Consumer n'est pas utilisé QUAND ON A BESOIN SEULEMENT D'ÉCRIRE DANS LE PROVIDER */

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const LoginLabel(text: 'Nom d\'utilisateur'),

            // Espacement entre le label et le champ
            const SizeBoxBtwLabelField(),

            // Container stylisé pour le champ de saisie
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
                border: Border.all(color: kPrimaryColor, width: 3),
              ),
              height: 60,
              child: TextFormField(
                controller: controller, // ← ICI
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  color: enterTextFieldColor,
                ),
                onChanged: onChanged, // ⭐ UTILISÉ ICI
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 14),
                  prefixIcon: const Icon(Icons.person, color: kPrimaryColor),
                  hintText: 'Nom d\'utilisateur',
                  hintStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 12,
                  ),
                  // Affichage des erreurs de validation
                  errorText: userProvider.loginUsernameError, // ← ICI
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
