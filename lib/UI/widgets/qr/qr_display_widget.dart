import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/model/qr_code_model.dart';
import 'package:senticket_front/model/user_model.dart';

/// Widget qui affiche le QR code personnel d'un utilisateur.
/// Ce QR code peut être scanné par un PORTIER (pour débiter)
/// ou un autre ETUDIANT (pour recevoir un transfert).
class QrDisplayWidget extends StatelessWidget {
  final User user;
  final double size;

  const QrDisplayWidget({
    super.key,
    required this.user,
    this.size = 250,
  });

  @override
  Widget build(BuildContext context) {
    // Générer les données du QR code à partir de l'utilisateur connecté
    final qrData = QrCodeData.forUser(
      userId: user.userId!,
      username: user.username,
      role: user.role.name,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, // QR code toujours sur fond blanc
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kPrimaryColor, width: 2),
          ),
          child: QrImageView(
            data: qrData.toQrString(),
            version: QrVersions.auto,
            size: size,
            backgroundColor: Colors.white,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.username,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: kThirdColor,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: kPrimaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kPrimaryColor),
          ),
          child: Text(
            user.role.name,
            style: TextStyle(
              fontSize: 12,
              color: kPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}