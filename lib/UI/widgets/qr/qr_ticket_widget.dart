import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/model/qr_code_model.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/model/user_model.dart';

import '../../../enums/ticket_type.dart';

/// Affiche le QR code d'un ticket spécifique.
/// Le portier scanne ce QR → débit direct sans sélection manuelle.
class QrTicketWidget extends StatelessWidget {
  final Ticket ticket;
  final User owner;

  const QrTicketWidget({
    super.key,
    required this.ticket,
    required this.owner,
  });

  @override
  Widget build(BuildContext context) {
    final qrData = QrCodeData.forTicket(
      ticketId: ticket.id!,
      ticketTypeLabel: ticket.type.toBackend,
      userId: owner.userId!,
      username: owner.username,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'QR Ticket ${ticket.type.toBackend}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: kThirdColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ID #${ticket.id}',
              style: TextStyle(
                fontSize: 13,
                color: kPrimaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kPrimaryColor, width: 2),
              ),
              child: QrImageView(
                data: qrData.toQrString(),
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Montrez ce QR au portier pour débiter ce ticket directement',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: kThirdColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Fermer',
                style: TextStyle(color: kPrimaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}