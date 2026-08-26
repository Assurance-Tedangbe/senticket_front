import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/cover/cover.drawer.header.dart';
import 'package:senticket_front/UI/widgets/cover/cover.drawer.item.widget.dart';

class CoverDrawer extends StatelessWidget {
  const CoverDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    List<dynamic> menus = [
     /* {
        "title": "Accueil",
        "route": "/home",
        "leadingIcon": Icons.home,
        "trailingIcon": Icons.arrow_forward
      },*/
      {
        "title": "Créer compte",
        "route": "/sign-up",
        "leadingIcon": Icons.person_add,
        "trailingIcon": Icons.arrow_forward
      },
    ];
    return Drawer(
      child: Column(
        children: [
          const CoverDrawerHeader(),
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return CoverDrawerItemWidget(
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
