import 'package:flutter/material.dart';
import 'package:senticket_front/constants.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation<Color>(boxshadowColor),
    );
  }
}
