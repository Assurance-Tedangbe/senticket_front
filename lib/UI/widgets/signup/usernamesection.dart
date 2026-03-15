import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/UI/widgets/customWidgets/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';

class UsernameSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const UsernameSection({
    super.key,
    required this.controller,
    this.onChanged,
  });


  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        builder: (context, userProvider, child)
    {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Label(text: "Nom d'utilisateur"),
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
              keyboardType: TextInputType.text,
              style: const TextStyle(color: enterTextFieldColor),
              onChanged: onChanged,
              cursorColor: kPrimaryColor,
              decoration:  InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 11),
                prefixIcon: Icon(Icons.person, color: kPrimaryColor),
                hintText: 'Nom d\'utilisateur',
                hintStyle: TextStyle(color: kPrimaryColor, fontSize: 12),

                errorText: userProvider.usernameError,
              ),
            ),
          ),
        ],
      );
    });
  }
}
