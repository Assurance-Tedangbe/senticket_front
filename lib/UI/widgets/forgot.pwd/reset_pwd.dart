import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/forgot.pwd/forgot_pwd_confirm_pwd_section.dart';
import 'package:senticket_front/UI/widgets/forgot.pwd/forgot_pwd_password_section.dart';
import 'package:senticket_front/UI/widgets/forgot.pwd/reset_btn.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.height.dart';
import 'package:senticket_front/constants.dart';

class ResetPwd extends StatefulWidget {
  const ResetPwd({super.key});

  @override
  State<ResetPwd> createState() => _ResetPwdState();
}

class _ResetPwdState extends State<ResetPwd> {
  static const String _title = 'Réinitialisation mot de passe';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text(_title)),
      body: const Padding(
        padding: EdgeInsets.only(left: 32.0, right: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.lock_reset, color: kPrimaryColor, size: 70),
            SizeboxHeight(),
            ForgotPwdPasswordSection(),
            SizeboxHeight(),
            ForgotPwdConfirmPwdSection(),
            SizeboxHeight(),
            ResetBtn(),
          ],
        ),
      ),
    );
  }
}
