import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';

class DebitUsernameSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const DebitUsernameSection({
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
            const Text(
              'Nom d\'utilisateur',
              style: TextStyle(color: kThirdColor, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Container(
              width: 290,
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
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: enterTextFieldColor),
                onChanged: (value) {
                  userProvider.setDebitUsername(value);
                  onChanged?.call(value);
                },
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
                  errorText: userProvider.debitUsernameError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/* class DebitUsernameSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const DebitUsernameSection({
    super.key,
    required this.controller,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Nom d\'utilisateur de l\'étudiant',
          style: TextStyle(color: kThirdColor, fontSize: 15),
        ),
        const SizedBox(height: 10),
        Container(
          width: 290,
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
            border: Border.all(color: kPrimaryColor, width: 2),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.text,
            style: const TextStyle(color: enterTextFieldColor),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 14),
              prefixIcon: const Icon(Icons.person, color: kPrimaryColor),
              hintText: 'Nom d\'utilisateur',
              hintStyle: const TextStyle(color: kPrimaryColor, fontSize: 12),
              // Affichage des erreurs de validation
              errorText: errorText,
            ),
          ),
        ),
      ],
    );
  }
} */

/* import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';

// Widget pour le champ "Nom d'utilisateur" dans la page Debiter un compte.
class DebitUsernameSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const DebitUsernameSection({
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
            const Text(
              'Nom d\'utilisateur',
              style: TextStyle(color: kThirdColor, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Container(
              width: 290,
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
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.text,
                style: TextStyle(color: enterTextFieldColor),
                onChanged: onChanged,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14),
                  prefixIcon: Icon(Icons.person, color: kPrimaryColor),
                  hintText: 'Nom d\'utilisateur',
                  hintStyle: TextStyle(color: kPrimaryColor, fontSize: 12),
                  // Affichage des erreurs de validation
                  errorText: userProvider.debitUsernameError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
 */
