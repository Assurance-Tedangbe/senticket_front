import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/home.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/login/checksignup.btn.dart';
import 'package:senticket_front/UI/widgets/login/forgotPwdBtn.dart';
import 'package:senticket_front/UI/widgets/login/login.btn.dart';
import 'package:senticket_front/UI/widgets/login/login.username.dart';
import 'package:senticket_front/UI/widgets/login/login.passwordsection.dart';
import 'package:senticket_front/UI/widgets/login/rememberme.dart';
import 'package:senticket_front/UI/widgets/updateUser/pageIconTemplate.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

/*
  Widget principal qui organise tous les champs du formulaire de connexion.
  StatefulWidget pour gérer les TextEditingController.
*/
class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginSuccess() {
    // Navigation vers la page d'accueil
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  void _toggleRememberMe(bool? value) {
    if (value != null) {
      setState(() {
        _isRememberMe = value;
      });
      // Vous pouvez sauvegarder ce choix dans les préférences
      print('Remember me: $_isRememberMe');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const PageIconTemplate(iconData: Icons.lock_open),
            const SizedBox(height: 15),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Column(
                  children: [
                    LoginUsernameSection(
                      controller: _usernameController,
                      onChanged: (value) =>
                          userProvider.setLoginUsername(value),
                    ),
                    const SizedBox(height: 15),
                    LoginPasswordSection(
                      controller: _passwordController,
                      onChanged: (value) =>
                          userProvider.setLoginPassword(value),
                    ),
                    ForgotPwdBtn(),
                    RememberMe(
                      value: _isRememberMe,
                      onChanged: _toggleRememberMe,
                    ),
                    const SizedBox(height: 15),
                    LoginBtn(onLoginSuccess: _onLoginSuccess),
                    const CheckSignupBtn(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
