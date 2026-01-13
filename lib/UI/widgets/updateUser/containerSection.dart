import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class ContainerSection extends StatelessWidget {
  const ContainerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: kSecondColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
          ],
          border: Border.all(color: kPrimaryColor, width: 3)),
      height: 60,
    );
  }
}
