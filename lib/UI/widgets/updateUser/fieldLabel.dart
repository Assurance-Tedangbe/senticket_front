import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class FieldLabel extends StatelessWidget {
  final String fldLabel;
  const FieldLabel({super.key, required this.fldLabel});

  @override
  Widget build(BuildContext context) {
    return Text(
      fldLabel,
      style: const TextStyle(color: kThirdColor, fontSize: 20),
    );
  }
}
