import 'package:flutter/material.dart';

class BlocTitle extends StatelessWidget {
  final String text;
  const BlocTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    );
  }
}
