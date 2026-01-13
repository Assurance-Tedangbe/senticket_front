import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.credit/label.dart';
import 'package:senticket_front/UI/widgets/updateUser/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';

/*
  Widget pour le champ "Prénom" transformé en StatelessWidget.
  L'état est maintenant géré par le UserProvider, ce qui permet :
  - Une meilleure séparation des responsabilités
  - Une gestion d'état centralisée
  - Une meilleure testabilité
*/

// L'ENFANT utilise seulement
class FirstNameSection extends StatelessWidget {
  final TextEditingController
      controller; // ← ICI : UTILISATION SEULEMENT(REÇU EN PARAMÈTRE)
  final ValueChanged<String>? onChanged; // ⭐ NOUVEAU

  const FirstNameSection({
    super.key,
    required this.controller, // ← ICI :  ← NE LE CRÉE PAS, LE REÇOIT
    this.onChanged, // ⭐ NOUVEAU
  });

  /* Consumer n'est pas utilisé QUAND ON A BESOIN SEULEMENT D'ÉCRIRE DANS LE PROVIDER */

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Label(text: 'Prénom'),

        // Espacement entre le label et le champ
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
            border:
                Border.all(color: kPrimaryColor, width: 3), // Bordure colorée
          ),
          height: 50, // Hauteur fixe
          child: TextFormField(
            controller:
                controller, // ← ICI :UTILISATION: 2. Lier le contrôleur au TextField
            keyboardType: TextInputType.text, // Type de clavier texte
            style: const TextStyle(color: enterTextFieldColor),
            onChanged: onChanged, // ⭐ UTILISÉ ICI
            /* (value) {
              // Appel au Provider pour mettre à jour l'état
              // ↓ Seulement un appel pour écrire dans le Provider
              Provider.of<UserProvider>(context, listen: false)
                  .firstname(value); // ← ICI
            }, */
            decoration: const InputDecoration(
              border: InputBorder.none, // Pas de bordure interne
              contentPadding: EdgeInsets.only(top: 11), // Padding interne
              prefixIcon: Icon(Icons.person, color: kPrimaryColor),
              hintText: 'Prénom', // Texte indicatif
              hintStyle: TextStyle(
                  color: kPrimaryColor, fontSize: 12), // Style du hint
            ),
          ),
        ),
      ],
    );
  }
}
