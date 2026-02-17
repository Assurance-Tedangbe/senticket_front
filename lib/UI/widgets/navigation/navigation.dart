import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:senticket_front/UI/pages/adminInterface.dart';
import 'package:senticket_front/UI/pages/home.dart';
import 'package:senticket_front/UI/pages/porterInterface.dart';
import 'package:senticket_front/UI/pages/studentInterface.dart';
import 'package:senticket_front/UI/widgets/navigation/bottomIcon.dart';
import 'package:senticket_front/UI/widgets/navigation/bottomText.dart';
import 'package:senticket_front/constants.dart';
//import 'package:senticket_front/UI/pages/agentInterface.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityProvider(
      child: SafeArea(
        child: Scaffold(
          /*  appBar: index == 2
            ? AppBar(): null,*/
          body: selectedContent(index: index),
          bottomNavigationBar:
              //index == 3
              //     ? null :
              CurvedNavigationBar(
                letIndexChange: (value) => true,
                index: index,
                onTap: (selectedIndex) {
                  setState(() {
                    index = selectedIndex;
                  });
                },
                backgroundColor: navigationBackgroundColor,
                color: kPrimaryColor,
                items: const [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BottomIcon(bottomicon: Icons.home),
                      TextAsTooltip(text: "Accueil"),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BottomIcon(bottomicon: Icons.person),
                      TextAsTooltip(text: "Interface Etudiant"),
                    ],
                  ),
                  /* Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                          BottomIcon(bottomicon: Icons.person_3_outlined),
                          TextAsTooltip(text: "Interface Agent")
                    ],
                   ), */
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BottomIcon(bottomicon: Icons.person_4),
                      TextAsTooltip(text: "Interface Portier"),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BottomIcon(bottomicon: Icons.manage_accounts),
                      TextAsTooltip(text: "Portail Admin"),
                    ],
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget selectedContent({required int index}) {
    Widget widget = const Home();
    switch (index) {
      case 0:
        widget = const Home();
        break;
      case 1:
        widget = const StudentInterface();
        break;
      /*  case 2:
        widget = const AgentInterface();
        break; */
      case 2:
        widget = const PorterInterface();
        break;
      case 3:
        widget = const AdminInterface();
        break;
    }
    return widget;
  }
}
