import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.credit/label.dart';
import 'package:senticket_front/constants.dart';

class PasswordTrsfCreditSection extends StatefulWidget {
  const PasswordTrsfCreditSection({super.key});

  @override
  State<PasswordTrsfCreditSection> createState() =>
      _PasswordTrsfCreditSectionState();
}

class _PasswordTrsfCreditSectionState extends State<PasswordTrsfCreditSection> {
  @override
  Widget build(BuildContext context) {
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
                    color: boxshadowColor, blurRadius: 6, offset: Offset(0, 2))
              ],
              border: Border.all(color: kPrimaryColor, width: 3)),
          child: const TextField(
            // keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            style: TextStyle(
              color: enterTextFieldColor,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(top: 14),
              prefixIcon: Icon(Icons.lock, color: kPrimaryColor),
              hintText: 'Mot de passe',
              hintStyle: TextStyle(
                color: kPrimaryColor,
                fontSize: 12,
              ),
              suffixIcon: Icon(
                Icons.visibility_off,
                color: kPrimaryColor,
              ),
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }
}
