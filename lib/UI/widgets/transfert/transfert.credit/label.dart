import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class Label extends StatelessWidget {
  final String text;
  const Label({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: kThirdColor,
        fontSize: 13,
      ),
    );
  }
}
