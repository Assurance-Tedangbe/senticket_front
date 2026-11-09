import 'package:flutter/material.dart';

class SizeBoxBtwLabelField extends StatelessWidget {
  const SizeBoxBtwLabelField({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(height: size.height / 100
        // or  height: size.height * 0.01
        );
  }
}
