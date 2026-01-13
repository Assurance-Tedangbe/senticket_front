import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

/*
  Widget pour le champ "Nom d'utilisateur" dans la page de consultation de compte.
*/
class UsernameConsultSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const UsernameConsultSection({
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
              style: TextStyle(
                color: kThirdColor,
                fontSize: 15,
              ),
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
                border: Border.all(color: kPrimaryColor, width: 3),
              ),
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  color: enterTextFieldColor,
                ),
                onChanged: onChanged,
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
                  errorText: userProvider.consultUsernameError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/* class StudentAccountNumber extends StatefulWidget {
  const StudentAccountNumber({super.key});

  @override
  State<StudentAccountNumber> createState() => _StudentAccountNumberState();
}

class _StudentAccountNumberState extends State<StudentAccountNumber> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'N° compte étudiant',
          style: TextStyle(
            color: kThirdColor,
            fontSize: 15,
          ),
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
                    color: boxshadowColor, blurRadius: 6, offset: Offset(0, 2))
              ],
              border: Border.all(color: kPrimaryColor, width: 3)),
          child: const TextField(
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: enterTextFieldColor,
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(Icons.person, color: kPrimaryColor),
                hintText: 'N° compte etudiant',
                hintStyle: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 12,
                )),
          ),
        )
      ],
    );
  }
}
 */