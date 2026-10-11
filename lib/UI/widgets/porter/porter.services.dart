import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/debitAccount.dart';
import 'package:senticket_front/UI/pages/qrcode/scanqr.dart';
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
            // ── Débiter compte (saisie manuelle) ──────────────────────
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

            // ── Scanner & Débiter (QR code direct) ────────────────────
            // Scanne le QR utilisateur ou ticket de l'étudiant
            // → navigue vers DebitAccount pré-rempli
            ContainerTemplate(
              press: () async {
                final result = await Navigator.of(context).push<ScanResult>(
                  MaterialPageRoute(
                    builder: (_) => const ScanQR(
                      operationType: ScanOperationType.debit,
                    ),
                  ),
                );
                if (result != null && context.mounted) {
                  // Naviguer vers DebitAccount
                  // Le résultat du scan est traité dans DebitBody._scanQrForDebit()
                  // via le bouton scan intégré — ici on ouvre simplement DebitAccount
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DebitAccount()),
                  );
                }
              },
              servicename: "Scanner & Débiter",
              imagepath: "images/scan.JPG",
            ),
          ],
        ),
      ],
    );
  }
}
