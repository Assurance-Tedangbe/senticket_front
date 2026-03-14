import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

class PopupCancelTransfer extends StatelessWidget {
  final TransfertHistoryDTO transferHistoryDTO;
  final VoidCallback? onCancelSuccess;

  const PopupCancelTransfer({super.key,
    required this.transferHistoryDTO,
    this.onCancelSuccess});

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    // Extraire les IDs des tickets depuis la chaîne
    final ticketIds = _parseTicketIds(transferHistoryDTO.ticketIdsTransfered);
    final numberOfTickets = ticketIds.length;

    return AlertDialog(
      title: const Text('Annuler le transfert'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Destinataire : ${transferHistoryDTO.recipientDTO.username}'),
          Text('Nombre de tickets : $numberOfTickets'),
          Text('ID transaction : ${transferHistoryDTO.id}'),
          const SizedBox(height: 10),
          const Text('Voulez-vous annuler ce transfert ?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: cyanColor),
          child: const Text('Quitter', style: TextStyle(color: kThirdColor)),
        ),
        ElevatedButton(
          onPressed: () async {
            // Vérifier que l'utilisateur est bien l'expéditeur original
            if (currentUser == null ||
                currentUser.userId != transferHistoryDTO.senderDTO.id) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Non autorisé'),
                  backgroundColor: redErrorColor,
                  duration: Duration(seconds: 5),
                ),
              );
              Navigator.pop(context);
              return;
            }

            // Construire la requête d'annulation
            final request = CancelTransferTicketsRequestDTO(
              cancelTransferDTO: CancelTransferDTO(
                transactionId: transferHistoryDTO.id,
                originalSenderDTO: OriginalSenderDTO(
                  senderId: transferHistoryDTO.senderDTO.id,
                  senderUsername: transferHistoryDTO.senderDTO.username,
                ),
                currentOwnerDTO: RecipientDTO(
                  recipientId: transferHistoryDTO.recipientDTO.id,
                  recipientUsername: transferHistoryDTO.recipientDTO.username,
                ),
              ),
              ticketIdsToCancel: ticketIds,
            );

            final success = await ticketProvider.cancelTransfer(request);

            if (success && context.mounted) {
              Navigator.pop(context);
              onCancelSuccess?.call(); // Appeler le callback de succès
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transfert annulé'),
                  backgroundColor: validateBtnColor,
                  duration: Duration(seconds: 5),
                ),
              );
            } else if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ticketProvider.error),
                  backgroundColor: redErrorColor,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          child: const Text('Annuler', style: TextStyle(color: kSecondColor)),
        ),
      ],
    );
  }

  List<int> _parseTicketIds(String ticketIdsStr) {
    String cleaned = ticketIdsStr.replaceAll('[', '').replaceAll(']', '');
    if (cleaned.isEmpty) return [];
    return cleaned.split(',').map((s) => int.parse(s.trim())).toList();
  }
}

