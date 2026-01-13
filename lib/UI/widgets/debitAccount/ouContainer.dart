import 'package:flutter/material.dart';

class OuContainer extends StatelessWidget {
  const OuContainer({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.center,
      height: size.height * 0.05,
      width: double.infinity,
      child: const Text(
        "-----------------------OU-------------------------",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
