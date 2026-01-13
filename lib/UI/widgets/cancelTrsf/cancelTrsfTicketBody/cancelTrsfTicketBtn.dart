import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class CancelTrsfTicketBtn extends StatefulWidget {
  const CancelTrsfTicketBtn({super.key});

  @override
  State<CancelTrsfTicketBtn> createState() => _CancelTrsfTicketBtnState();
}

class _CancelTrsfTicketBtnState extends State<CancelTrsfTicketBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      width: 320,
      height: 95,
      child: ElevatedButton(
        onPressed: () => print('cancel pressed'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          textStyle: const TextStyle(
              color: kSecondColor, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        child: const Text('Annuler transfert'),
      ),
    );
  }
}
