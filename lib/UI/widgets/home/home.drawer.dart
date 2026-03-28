import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/home/home.drawer.header.dart';
import 'package:senticket_front/UI/widgets/home/home.drawer.item.widget.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

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
        "title": "Créer compte",
        "route": "/sign-up",
        "leadingIcon": Icons.person_add,
        "trailingIcon": Icons.arrow_forward
      },
      {
        "title": "Interface Etudiant",
        "route": "/student",
        "leadingIcon": Icons.person,
        "trailingIcon": Icons.arrow_forward
      },
      /* {
        "title": "Mise à jour profil",
        "route": "/update-profile",
        "leadingIcon": Icons.update,
        "trailingIcon": Icons.arrow_forward
      }, */
      {
        "title": "Interface Portier",
        "route": "/porter",
        "leadingIcon": Icons.person_4,
        "trailingIcon": Icons.arrow_forward
      },
     /* {
        "title": "Interface Agent",
        "route": "/agent",
        "leadingIcon": Icons.person_3_outlined,
        "trailingIcon": Icons.arrow_forward
      },*/
      {
        "title": "Portail Admin",
        "route": "/admin",
        "leadingIcon": Icons.manage_accounts,
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
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return HomeDrawerItemWidget(
                      title: menus[index]['title'],
                      leadingIcon: menus[index]['leadingIcon'],
                      trailingIcon: menus[index]['trailingIcon'],
                      onAction: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, menus[index]['route']);
                      });
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 5,
                  );
                },
                itemCount: menus.length),
          ),
        ],
      ),
    );
  }
}
