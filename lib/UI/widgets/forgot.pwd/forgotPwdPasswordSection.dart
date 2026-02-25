import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/UI/widgets/customWidgets/SizeboxBtwLabelField.dart';
import 'package:senticket_front/constants.dart';

class ForgotPwdPasswordSection extends StatefulWidget {
  const ForgotPwdPasswordSection({super.key});

  @override
  State<ForgotPwdPasswordSection> createState() =>
      _ForgotPwdPasswordSectionState();
}

class _ForgotPwdPasswordSectionState extends State<ForgotPwdPasswordSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Label(text: 'Mot de passe'),
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
          child: const TextField(
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            style: TextStyle(color: enterTextFieldColor),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(top: 11),
              prefixIcon: Icon(Icons.password, color: kPrimaryColor),
              hintText: 'Mot de passe',
              hintStyle: TextStyle(color: kPrimaryColor, fontSize: 12),
              suffixIcon: Icon(Icons.visibility_off, color: kPrimaryColor),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
