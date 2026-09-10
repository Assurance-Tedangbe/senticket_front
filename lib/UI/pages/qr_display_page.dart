import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/qr/qr_display_widget.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';

/// Page affichant le QR code personnel de l'utilisateur connecté.
/// Accessible depuis le menu étudiant ET portier.
///
/// Usage :
///   ETUDIANT → montre ce QR à un PORTIER pour se faire débiter
///   ETUDIANT → montre ce QR à un autre ETUDIANT pour recevoir un transfert
///   PORTIER  → montre ce QR (usage futur éventuel)
class QrDisplayPage extends StatelessWidget {
  const QrDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon QR code'),
        backgroundColor: kPrimaryColor,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.currentUser;

          if (user == null) {
            return const Center(
              child: Text(
                'Vous devez être connecté',
                style: TextStyle(color: kThirdColor),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                // Instructions contextuelles selon le rôle
                _buildInstructions(user.role.name),

                const SizedBox(height: 32),

                // QR code centré
                Center(
                  child: QrDisplayWidget(user: user, size: 260),
                ),

                const SizedBox(height: 32),

                // Note d'information
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: kPrimaryColor, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Ce QR code identifie votre compte. '
                              'Ne le partagez qu\'avec des personnes de confiance.',
                          style: TextStyle(fontSize: 12, color: kThirdColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructions(String role) {
    final instructions = role.toUpperCase() == 'ETUDIANT'
        ? [
      '📲 Montrez ce QR au portier pour débiter vos tickets.',
      '🔄 Un autre étudiant peut scanner ce QR pour vous transférer des tickets.',
    ]
        : [
      '📲 Votre QR code personnel.',
    ];

    return Column(
      children: instructions
          .map((text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: kThirdColor,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ))
          .toList(),
    );
  }
}