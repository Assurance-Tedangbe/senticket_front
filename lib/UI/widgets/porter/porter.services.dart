import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/debitAccount.dart';
import 'package:senticket_front/UI/pages/scanqr.dart';
import 'package:senticket_front/UI/widgets/home/container.template.dart';
import 'package:senticket_front/UI/widgets/home/homebloctitle.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.template.dart';

class PorterServices extends StatelessWidget {
  const PorterServices({super.key});

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
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DebitAccount()),
                );
              },
              servicename: "Debiter compte",
              imagepath: "images/debiter.JPG",
            ),
            const SizeboxTemplate(),
            const SizeboxTemplate(),
            const SizeboxTemplate(),
            const SizeboxTemplate(),
            ContainerTemplate(
              press: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => const ScanQR()));
              },
              servicename: "Scan QR",
              imagepath: "images/scan.JPG",
            ),
            /*   ContainerTemplate(
            press: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Historic()));
            },
            servicename: "Historique",
            imagepath: "images/historic.JPG"), */
          ],
        ),
      ],
    );
  }
}
