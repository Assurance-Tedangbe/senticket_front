import 'package:flutter/material.dart';

class SizeboxHeightSession extends StatelessWidget {
  const SizeboxHeightSession({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height / 50,
    );
  }
}
