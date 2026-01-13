import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/signup.dart';
import 'package:senticket_front/constants.dart';

class CheckSignupBtn extends StatefulWidget {
  const CheckSignupBtn({super.key});

  @override
  State<CheckSignupBtn> createState() => _CheckSignupBtnState();
}

class _CheckSignupBtnState extends State<CheckSignupBtn> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => SignUpPage())),
      child: RichText(
        text: const TextSpan(children: [
          TextSpan(
              text: "N'avez vous pas de compte?",
              style: TextStyle(
                  color: kThirdColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          TextSpan(
              text: "  S'inscrire",
              style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }
}
