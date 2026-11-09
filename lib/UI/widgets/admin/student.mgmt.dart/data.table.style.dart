import 'package:flutter/material.dart';

class DataTableStyle extends StatelessWidget {
  final String datafromBack;
  const DataTableStyle({super.key, required this.datafromBack});

  @override
  Widget build(BuildContext context) {
    return Text(datafromBack,
        style: const TextStyle(fontSize: 33, fontWeight: FontWeight.w500));
  }
}
