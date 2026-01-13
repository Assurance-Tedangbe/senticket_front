import 'package:flutter/material.dart';

class HomeDrawerHeader extends StatefulWidget {
  const HomeDrawerHeader({super.key});

  @override
  State<HomeDrawerHeader> createState() => _HomeDrawerHeaderState();
}

class _HomeDrawerHeaderState extends State<HomeDrawerHeader> {
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
              backgroundImage: AssetImage("images/restaurantlogo.png"),
              radius: 30,
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
          ],
        ));
  }
}