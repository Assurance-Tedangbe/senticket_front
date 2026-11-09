import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/forgot.pwd.dart';
import 'package:senticket_front/constants.dart';

class ForgotPwdBtn extends StatelessWidget {
  const ForgotPwdBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const ForgotPwd())),
        child: const Text(
          'Mot de passe oublié?',
          style: TextStyle(
              color: kPrimaryColor, fontWeight: FontWeight.w800, fontSize: 17),
        ),
      ),
    );
  }
}
