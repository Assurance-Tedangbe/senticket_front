import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.credit/label.dart';
import 'package:senticket_front/UI/widgets/updateUser/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';

class LastNameSection extends StatelessWidget {
  final TextEditingController controller; // ← ICI
  final ValueChanged<String>? onChanged; // ⭐ NOUVEAU

  const LastNameSection(
      {super.key, required this.controller, this.onChanged // ← ICI
      });

  /* Consumer n'est pas utilisé QUAND ON A BESOIN SEULEMENT D'ÉCRIRE DANS LE PROVIDER */

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Label(text: 'Nom'),

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
          height: 50,
          child: TextFormField(
            controller: controller, // ← ICI
            keyboardType: TextInputType.text, // Clavier standard
            style: const TextStyle(color: enterTextFieldColor),
            onChanged: onChanged, // ⭐ UTILISÉ ICI
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 11),
              prefixIcon: Icon(Icons.person, color: kPrimaryColor),
              hintText: 'Nom',
              hintStyle: TextStyle(color: kPrimaryColor, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
