import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';

class SenderPasswordTrsfTicket extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const SenderPasswordTrsfTicket({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Label(text: 'Votre mot de passe'),
            const SizedBox(height: 10),
            Container(
              width: 300,
              height: 50,
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
              child: TextField(
                controller: controller,
                obscureText:
                    !userProvider.isPasswordVisible, // Masque le texte si false
                onChanged: (value) {
                  userProvider.setSenderPassword(value);
                  onChanged?.call(value);
                },
                cursorColor: kPrimaryColor,
                keyboardType: TextInputType.visiblePassword,
                style: const TextStyle(color: enterTextFieldColor),
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
                      userProvider.isPasswordVisible
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
                  // Affichage des erreurs de validation
                  errorText: userProvider.senderPasswordError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
