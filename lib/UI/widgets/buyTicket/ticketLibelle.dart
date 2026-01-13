import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class TicketLibelle extends StatelessWidget {
  final String libelle;
  const TicketLibelle({super.key, required this.libelle});

  @override
  Widget build(BuildContext context) {
    return Text(
      libelle,
      style: const TextStyle(
        color: kThirdColor,
        fontSize: 12,
      ),
    );
  }
}
