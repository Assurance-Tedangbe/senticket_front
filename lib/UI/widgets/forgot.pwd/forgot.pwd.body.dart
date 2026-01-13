import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/forgot.pwd/gotoreset.pwd.btn.dart';
import 'package:senticket_front/UI/widgets/login/login.username.dart';

class ForgotPwdBody extends StatelessWidget {
  const ForgotPwdBody({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: size.height * 0.2),
          // LoginUsernameSection(),
          const GoToResetPwdBtn(),
        ],
      ),
    );
  }
}
