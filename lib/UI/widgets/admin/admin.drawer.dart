import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/admin/admindrawer.item.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> menus = [
      {
        "title": "Accueil",
        "route": "/home",
        "leadingIcon": Icons.home,
        "trailingIcon": Icons.arrow_forward,
      },
      /*       {
        "title": "Activer compte",
        "route": "/activate-account",
        "leadingIcon": Icons.account_circle,
        "trailingIcon": Icons.arrow_forward
      },
      {
        "title": "Désactiver compte",
        "route": "/deactivate-account",
        "leadingIcon": Icons.no_accounts,
        "trailingIcon": Icons.arrow_forward
      }, */
      {
        "title": "Se déconnecter",
        "route": "/log-out",
        "leadingIcon": Icons.cancel,
        "trailingIcon": Icons.arrow_forward,
      },
    ];

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return AdminDrawerItem(
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
}
