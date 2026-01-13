import 'package:flutter/material.dart';

class SizeboxTemplate extends StatelessWidget {
  const SizeboxTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height / 35,
    );
  }
}
