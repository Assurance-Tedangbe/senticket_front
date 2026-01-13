import 'package:flutter/material.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.credit/label.dart';
import 'package:senticket_front/UI/widgets/updateUser/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';

/*
  Widget pour le champ "Confirmation du mot de passe".
  Valide que les deux mots de passe correspondent.
*/
class ConfirmPwdSection extends StatelessWidget {
  final TextEditingController controller; // ← ICI
  final ValueChanged<String>? onChanged; // ⭐ NOUVEAU

  const ConfirmPwdSection({
    super.key,
    required this.controller, // ← ICI
    this.onChanged, // ← ICI
  });

  /* Consumer est utilisé QUAND ON A BESOIN DE "LIRE" DES DONNÉES DYNAMIQUES
     ce widgets a besoin d'accéder à des données dynamiques du Provider :
     userProvider.isPasswordVisible → Changement d'état booléen
     userProvider.passwordError → Messages d'erreur dynamiques */

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      // Consumer permet de réagir aux changements du Provider  // ← ICI
      builder: (context, userProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Label(text: 'Confirmer mot de passe'),
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
                border: Border.all(color: kPrimaryColor, width: 3),
              ),
              height: 50,
              child: TextField(
                controller: controller, // ← ICI
                keyboardType: TextInputType.visiblePassword,
                obscureText: !userProvider.isPasswordVisible, // ← ICI
                style: const TextStyle(color: enterTextFieldColor),
                onChanged: onChanged, // ⭐ UTILISÉ ICI
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 11),
                  prefixIcon: const Icon(Icons.password, color: kPrimaryColor),
                  hintText: 'Confirmer mot de passe',
                  hintStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 12,
                  ),

                  // Bouton de visibilité synchronisé avec le champ
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Change l'icône selon l'état de visibilité
                      userProvider.isPasswordVisible // ← ICI
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: kPrimaryColor,
                    ),
                    onPressed: () {
                      // Bascule l'état de visibilité via le Provider
                      userProvider.togglePasswordVisibility(); // ← ICI
                    },
                  ),
                  border: InputBorder.none,
                  // Affichage des erreurs de correspondance
                  errorText: userProvider.passwordError, // ← ICI
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
