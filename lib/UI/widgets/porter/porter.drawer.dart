import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/home/home.drawer.header.dart';
import 'package:senticket_front/UI/widgets/porter/porterdrawer.item.dart';

import '../../../constants.dart';
import '../../pages/profil_page.dart';

class PortierDrawer extends StatelessWidget {
  const PortierDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> menus = [
      {
        "title": "Accueil",
        "route": "/home",
        "leadingIcon": Icons.home,
        "trailingIcon": Icons.arrow_forward
      },
      {
        "title": "Débiter compte",
        "route": "/debit-account",
        "leadingIcon": Icons.money_off,
        "trailingIcon": Icons.arrow_forward
      },
      {
        "title": "Se déconnecter",
        "route": "/log-out",
        "leadingIcon": Icons.logout,
        "trailingIcon": Icons.arrow_forward
      }
    ];

    return Drawer(
      child: Column(
        children: [
          const HomeDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ✅ Lien profil
                ListTile(
                  leading: const Icon(Icons.person, color: kPrimaryColor),
                  title: const Text('Mon profil', style: TextStyle(fontSize: 22)),
                  trailing: const Icon(
                    Icons.arrow_forward,
                    color: kPrimaryColor,
                    size: 25,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ProfilePage()),
                    );
                  },
                ),
                const Divider(height: 5),

                // Items existants
                ...List.generate(menus.length, (index) {
                  return Column(
                    children: [
                      PortierDrawerItem(
                        title: menus[index]['title'],
                        leadingIcon: menus[index]['leadingIcon'],
                        trailingIcon: menus[index]['trailingIcon'],
                        onAction: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                              context, menus[index]['route']);
                        },
                      ),
                      if (index < menus.length - 1)
                        const Divider(height: 5),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
