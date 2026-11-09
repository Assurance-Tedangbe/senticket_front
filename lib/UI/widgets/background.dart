import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  const Background({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              "images/logo-senticket.png",
              width: size.width * 0.08,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              "images/logo-senticket.png",
              width: size.width * 0.08,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              "images/logo-senticket.png",
              width: size.width * 0.08,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              "images/logo-senticket.png",
              width: size.width * 0.08,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
