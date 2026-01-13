import 'package:flutter/material.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.credit/label.dart';
import 'package:senticket_front/UI/widgets/updateUser/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';

/*
  Widget pour le champ "Email" avec validation en temps réel.
  Utilise Consumer pour réagir aux changements d'état du Provider.
*/
class EmailSection extends StatelessWidget {
  final TextEditingController controller; // ← ICI
  final ValueChanged<String>? onChanged; // ⭐ NOUVEAU

  const EmailSection({
    super.key,
    required this.controller,
    this.onChanged, // ← ICI
  });

/* Consumer est utilisé QUAND ON A BESOIN DE "LIRE" DES DONNÉES DYNAMIQUES
   ce widget a besoin d'accéder à des données dynamiques du Provider :
   userProvider.emailError → Validation en temps réel */

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      // Consumer permet de réagir aux changements du Provider  // ← ICI
      builder: (context, userProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Label(text: 'Email'),
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
              child: TextFormField(
                controller: controller, // ← ICI
                keyboardType:
                    TextInputType.emailAddress, // Clavier optimisé pour emails
                style: const TextStyle(color: enterTextFieldColor),
                onChanged: onChanged, // ⭐ UTILISÉ ICI
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 10),
                  prefixIcon: const Icon(Icons.email, color: kPrimaryColor),
                  hintText: 'Email',
                  hintStyle: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 12,
                  ),

                  // Affichage conditionnel des erreurs de validation
                  errorText: userProvider.emailError, // ← ICI
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
