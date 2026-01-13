import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/coverPage.dart';
import 'package:senticket_front/UI/pages/debitAccount.dart';
import 'package:senticket_front/UI/pages/scanqr.dart';

class NavigationBarPorter extends StatelessWidget {
  const NavigationBarPorter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            enableFeedback: false,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => CoverPage())),
            tooltip: 'Accueil',
            icon: const Icon(
              Icons.home,
              color: Colors.white,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => DebitAccount())),
            tooltip: 'Débiter un compte',
            icon: const Icon(
              Icons.money_off,
              color: Colors.white,
              size: 35,
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ScanQR())),
            tooltip: 'Scanner code QR',
            icon: const Icon(
              Icons.scanner,
              color: Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
