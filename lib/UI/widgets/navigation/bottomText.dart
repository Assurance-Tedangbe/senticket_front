import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class TextAsTooltip extends StatelessWidget {
  final String text;

  const TextAsTooltip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11.0, color: kSecondColor),
    );
  }
}
