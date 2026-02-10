import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class TransfertTicketBtn extends StatefulWidget {
  const TransfertTicketBtn({super.key});

  @override
  State<TransfertTicketBtn> createState() => _TransfertTicketBtnState();
}

class _TransfertTicketBtnState extends State<TransfertTicketBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      width: 330,
      height: 95,
      child: ElevatedButton(
        onPressed: () => print('pressed'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(
            color: kSecondColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text(
          'Transférer ticket(s)',
          style: TextStyle(
            color: kSecondColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
