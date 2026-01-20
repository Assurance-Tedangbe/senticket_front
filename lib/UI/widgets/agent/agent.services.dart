import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/historic.dart';
import 'package:senticket_front/UI/pages/scanqr.dart';
import 'package:senticket_front/UI/widgets/home/container.template.dart';
import 'package:senticket_front/UI/widgets/home/homebloctitle.dart';
import 'package:senticket_front/UI/widgets/home/sizebox.template.dart';

class AgentServices extends StatelessWidget {
  const AgentServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Homebloctitle(text: "Mes services")],
        ),
        const SizeboxTemplate(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ContainerTemplate(
              press: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => const ScanQR()));
              },
              servicename: "Scan QR",
              imagepath: "images/scan.JPG",
            ),
            /*  ContainerTemplate(
              press: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreditAccount(),
                  ),
                );
              },
              servicename: "Créditer compte",
              imagepath: "images/crediter.JPG",
            ), */
            const SizeboxTemplate(),
            const SizeboxTemplate(),
            const SizeboxTemplate(),
            const SizeboxTemplate(),
            ContainerTemplate(
              press: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Historic()),
                );
              },
              servicename: "Historique",
              imagepath: "images/historic.JPG",
            ),

            /*  ContainerTemplate(
              press: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CancelRecharge(),
                  ),
                );
              },
              servicename: "Annuler recharge",
              imagepath: "images/annuler_transaction.JPG",
            ),
            ContainerTemplate(
              press: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ActivateAccount()),
                );
              },
              servicename: "Activer compte",
              imagepath: "images/activate_icon.JPG",
            ), */
          ],
        ),
      ],
    );
  }
}
