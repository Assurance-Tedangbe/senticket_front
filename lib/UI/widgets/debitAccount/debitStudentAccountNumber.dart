import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class DebitStdAccNumber extends StatefulWidget {
  const DebitStdAccNumber({super.key});

  @override
  State<DebitStdAccNumber> createState() => _DebitStdAccNumberState();
}

class _DebitStdAccNumberState extends State<DebitStdAccNumber> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'N° compte étudiant',
          style: TextStyle(
            color: kThirdColor,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 290,
          height: 50,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: kSecondColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                    color: boxshadowColor, blurRadius: 6, offset: Offset(0, 2))
              ],
              border: Border.all(color: kPrimaryColor, width: 3)),
          child: const TextField(
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: enterTextFieldColor,
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(Icons.person, color: kPrimaryColor),
                hintText: 'N° compte etudiant',
                hintStyle: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 12,
                )),
          ),
        )
      ],
    );
  }
}
