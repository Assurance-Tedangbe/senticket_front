import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/buy_ticket.dart';
import 'package:senticket_front/UI/pages/consult_account.dart';
import 'package:senticket_front/UI/pages/debit_account.dart';
import 'package:senticket_front/UI/pages/historic.dart';
import 'package:senticket_front/UI/pages/qrcode/scanqr.dart';
import 'package:senticket_front/UI/pages/transfert.ticket.dart';
import 'package:senticket_front/UI/widgets/cancelTrsf/popup_cancel_transfer_by_id.dart';
import 'package:senticket_front/UI/widgets/home/container.template.dart';
import 'package:senticket_front/UI/widgets/home/homebloctitle.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.height.session.dart';
import 'package:senticket_front/UI/widgets/home/statistics.dart';

class Services extends StatelessWidget {
  const Services({super.key});

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
                  MaterialPageRoute(builder: (context) => const DebitAccount()),
                );
              },
              servicename: "Débiter compte",
              imagepath: "images/debiter.JPG",
            ),
            ContainerTemplate(
              press: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => const ScanQR()));
              },
              servicename: "Scan QR",
              imagepath: "images/scan.JPG",
            ),
          ],
        ),
        const SizeboxHeightSession(),
        const SizeboxHeightSession(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
                showDialog(
                  context: context,
                  builder: (_) => const PopupCancelTransferById(),
                );
              },
              servicename: "Annuler transfert",
              imagepath: "images/annuler_transaction.JPG",
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Statistics(),
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
