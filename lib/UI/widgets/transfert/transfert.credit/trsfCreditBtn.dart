import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class TrnasfertCreditBtn extends StatefulWidget {
  const TrnasfertCreditBtn({super.key});

  @override
  State<TrnasfertCreditBtn> createState() => _TrnasfertCreditBtnState();
}

class _TrnasfertCreditBtnState extends State<TrnasfertCreditBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      width: 320,
      height: 95,
      child: ElevatedButton(
        onPressed: () => print('validate pressed'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          textStyle: const TextStyle(
              color: kSecondColor, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        child: const Text('Valider'),
      ),
    );
  }
}
