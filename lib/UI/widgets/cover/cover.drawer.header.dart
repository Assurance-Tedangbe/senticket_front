import 'package:flutter/material.dart';

class CoverDrawerHeader extends StatefulWidget {
  const CoverDrawerHeader({super.key});

  @override
  State<CoverDrawerHeader> createState() => _CoverDrawerHeaderState();
}

class _CoverDrawerHeaderState extends State<CoverDrawerHeader> {
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.white,
            Theme.of(context).primaryColor,
          ]),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage("images/logo-senticket.png"),
              radius: 30,
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
          ],
        ));
  }
}
