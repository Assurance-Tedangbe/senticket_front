import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class InfoContainer extends StatelessWidget {
  const InfoContainer({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.center,
      height: size.height * 0.09,
      width: size.width * 0.9,
      decoration: BoxDecoration(
        color: textContainerColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: boxshadowColor, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          "Pour débiter le compte d'un étudiant, vous avez le choix entre scanner son code QR et entrer son n° de compte",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
