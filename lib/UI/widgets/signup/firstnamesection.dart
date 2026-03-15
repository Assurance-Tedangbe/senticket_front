import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/UI/widgets/customWidgets/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';

// L'ENFANT utilise seulement
class FirstNameSection extends StatelessWidget {
  final TextEditingController
  controller; // ← UTILISATION SEULEMENT(REÇU EN PARAMÈTRE)
  final ValueChanged<String>? onChanged;

  const FirstNameSection({
    super.key,
    required this.controller, // ← NE LE CRÉE PAS, LE REÇOIT
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Label(text: 'Prénom'),
        const SizeBoxBtwLabelField(),
        // Container qui englobe le TextField pour le style
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: kSecondColor, // Couleur de fond
            borderRadius: BorderRadius.circular(10), // Bords arrondis
            boxShadow: const [
              // Ombre pour l'effet de relief
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
            controller: controller, // Lier le contrôleur au TextField
            keyboardType: TextInputType.text,
            style: const TextStyle(color: enterTextFieldColor),
            onChanged: onChanged,
            cursorColor: kPrimaryColor,
            decoration: const InputDecoration(
              border: InputBorder.none, // Pas de bordure interne
              contentPadding: EdgeInsets.only(top: 11), // Padding interne
              prefixIcon: Icon(Icons.person, color: kPrimaryColor),
              hintText: 'Prénom', // Texte indicatif
              hintStyle: TextStyle(
                color: kPrimaryColor,
                fontSize: 12,
              ), // Style du hint
            ),
          ),
        ),
      ],
    );
  }
}
