import 'package:flutter/material.dart';

class SizeboxHeight extends StatelessWidget {
  const SizeboxHeight({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 30,
    );
  }
}
