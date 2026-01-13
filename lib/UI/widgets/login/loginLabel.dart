import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class LoginLabel extends StatelessWidget {
  final String text;
  const LoginLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: kThirdColor,
        fontSize: 17,
      ),
    );
  }
}
