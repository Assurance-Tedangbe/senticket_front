import 'package:flutter/material.dart';

class HeadTableStyle extends StatelessWidget {
  final String data;
  const HeadTableStyle({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
    );
  }
}
