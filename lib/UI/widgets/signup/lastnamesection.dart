import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/UI/widgets/customWidgets/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';

class LastNameSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const LastNameSection({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Label(text: 'Nom'),
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
            border: Border.all(color: kPrimaryColor, width: 1),
          ),
          height: 50,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.text, // Clavier standard
            style: const TextStyle(color: enterTextFieldColor),
            onChanged: onChanged,
            cursorColor: kPrimaryColor,
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
