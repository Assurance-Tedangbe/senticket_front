import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class BottomIcon extends StatelessWidget {
  final IconData bottomicon;

  const BottomIcon({super.key, required this.bottomicon});

  @override
  Widget build(BuildContext context) {
    return Icon(
      bottomicon,
      color: kSecondColor,
      size: 35.0,
    );
  }
}
