import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/home/home.drawer.header.dart';
import 'package:senticket_front/UI/widgets/student/studentdrawer.item.dart';

import '../../../constants.dart';
import '../../pages/profil_page.dart';

class StudentDrawer extends StatelessWidget {
  const StudentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> menus = [
      {
        "title": "Accueil",
        "route": "/home",
        "leadingIcon": Icons.home,
        "trailingIcon": Icons.arrow_forward,
      },
      {
        "title": "Acheter ticket",
        "route": "/ticket",
        "leadingIcon": Icons.credit_card,
        "trailingIcon": Icons.arrow_forward,
      },
      {
        "title": "Transférer ticket",
        "route": "/transfert-ticket",
        "leadingIcon": Icons.send,
        "trailingIcon": Icons.arrow_forward,
      },
      {
        "title": "Consulter compte",
        "route": "/consult-account",
        "leadingIcon": Icons.visibility,
        "trailingIcon": Icons.arrow_forward,
      },
      /*{
        "title": "Mise à jour profil",
        "route": "/update-profile",
        "leadingIcon": Icons.update,
        "trailingIcon": Icons.arrow_forward,
      },*/
      {
        "title": "Se déconnecter",
        "route": "/log-out",
        "leadingIcon": Icons.logout,
        "trailingIcon": Icons.arrow_forward,
      },
    ];

    return Drawer(
      child: Column(
        children: [
          const HomeDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ✅ Lien profil — en haut de la liste, avant les autres items
                ListTile(
                  leading: const Icon(Icons.person, color: kPrimaryColor),
                  title: const Text('Mon profil'),
                  trailing: const Icon(
                    Icons.arrow_forward,
                    color: kPrimaryColor,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.pop(context); // ferme le drawer
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
                      StudentDrawerItem(
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
/*    return Drawer(
      child: Column(
        children: [
          const HomeDrawerHeader(),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return StudentDrawerItem(
                  title: menus[index]['title'],
                  leadingIcon: menus[index]['leadingIcon'],
                  trailingIcon: menus[index]['trailingIcon'],
                  onAction: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, menus[index]['route']);
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(height: 5);
              },
              itemCount: menus.length,
            ),
          ),
        ],
      ),
    );
  }
}*/
