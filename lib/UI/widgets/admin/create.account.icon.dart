import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/signup.dart';
import 'package:senticket_front/constants.dart';

class CreateAccountIcon extends StatelessWidget {
  const CreateAccountIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 25,
      icon: const Icon(
        Icons.person_add,
        color: kPrimaryColor,
      ),
      tooltip: 'Créer un utilisateur',
      onPressed: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const SignUpPage())),
    );
  }
}
