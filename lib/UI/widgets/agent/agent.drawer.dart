import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/agent/agentdrawer.item.dart';

class AgentDrawer extends StatelessWidget {
  const AgentDrawer({super.key});

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
        "title": "Activer compte",
        "route": "/activate-account",
        "leadingIcon": Icons.account_circle,
        "trailingIcon": Icons.arrow_forward
      },
      {
        "title": "Créditer compte",
        "route": "/credit-account",
        "leadingIcon": Icons.attach_money,
        "trailingIcon": Icons.arrow_forward
      },
      {
        "title": "Annuler recharge",
        "route": "/cancel-recharge",
        "leadingIcon": Icons.cancel,
        "trailingIcon": Icons.arrow_forward
      },
      {
        "title": "Se déconnecter",
        "route": "/log-out",
        "leadingIcon": Icons.cancel,
        "trailingIcon": Icons.arrow_forward
      }
    ];

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return AgentDrawerItem(
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
