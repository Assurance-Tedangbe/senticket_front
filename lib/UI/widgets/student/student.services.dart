import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/buyTicket.dart';
import 'package:senticket_front/UI/pages/consultAccount.dart';
import 'package:senticket_front/UI/pages/historic.dart';
import 'package:senticket_front/UI/pages/scanqr.dart';
import 'package:senticket_front/UI/pages/transfert.ticket.dart';
import 'package:senticket_front/UI/widgets/cancelTrsf/PopupCancelTransferById.dart';
import 'package:senticket_front/UI/widgets/home/container.template.dart';
import 'package:senticket_front/UI/widgets/home/homebloctitle.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizeboxHeightSession.dart';
import 'package:senticket_front/UI/pages/qr_display_page.dart';


class StudentServices extends StatelessWidget {
  const StudentServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Homebloctitle(text: "Mes services")],
        ),
        const SizeboxHeightSession(),
        // ── Ligne 1 ────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ContainerTemplate(
              press: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const BuyTicket()),
                );
              },
              servicename: "Acheter ticket",
              imagepath: "images/ticket.JPG",
            ),
            ContainerTemplate(
              press: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TransfertTicket(),
                  ),
                );
              },
              servicename: "Transfert ticket",
              imagepath: "images/transfert.JPG",
            ),
            ContainerTemplate(
              press: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ConsultAccount(),
                  ),
                );
              },
              servicename: "Consulter compte",
              imagepath: "images/consult_icon.JPG",
            ),
          ],
        ),
        const SizeboxHeightSession(),
        const SizeboxHeightSession(),
        const SizeboxHeightSession(),

        // ── Ligne 2 ────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ContainerTemplate(
              press: () {
                showDialog(
                  context: context,
                  builder: (_) => const PopupCancelTransferById(),
                );
              },
              servicename: "Annuler transfert",
              imagepath: "images/annuler_transaction.JPG",
            ),

            // ← Mon QR code (remplace l'ancien Scan QR générique)
            ContainerTemplate(
              press: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const QrDisplayPage()),
              ),
              servicename: "Mon QR code",
              imagepath: "images/scan.JPG",
            ),
            ContainerTemplate(
              press: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Historic()),
                );
              },
              servicename: "Historique",
              imagepath: "images/historic.JPG",
            ),
          ],
        ),
      ],
    );
  }
}
