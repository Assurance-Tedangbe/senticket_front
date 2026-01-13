import 'package:flutter/material.dart';

class ImageAsset extends StatelessWidget {
  final String iconpath;
  const ImageAsset({super.key, required this.iconpath});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Image.asset(iconpath,
        width: size.width / 20.0, height: size.height / 20.0);
  }
}
