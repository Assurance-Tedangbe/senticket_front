import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class ResetBtn extends StatefulWidget {
  const ResetBtn({super.key});

  @override
  State<ResetBtn> createState() => _ResetBtnState();
}

class _ResetBtnState extends State<ResetBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 25),
        width: double.infinity,
        height: 100,
        child: ElevatedButton(
          onPressed: () => print('reset pressed'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            textStyle: const TextStyle(
                color: kSecondColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: const Text('Reinitialiser mot de passe'),
        ));
  }
}
