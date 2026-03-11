import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

class PopupCancelTransfer extends StatelessWidget {
  final TransfertHistoryDTO transferHistoryDTO;

  const PopupCancelTransfer({super.key, required this.transferHistoryDTO});

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
          Text('ID transaction : ${transferHistoryDTO.transferHistoryId}'),
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
                transactionId: transferHistoryDTO.transferHistoryId,
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

/* 
class PopupCancelTransfer extends StatelessWidget {
  final TransfertHistoryDTO history;

  const PopupCancelTransfer({Key? key, required this.history})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    return AlertDialog(
      title: const Text('Annuler le transfert'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Destinataire : ${history.recipientDTO.username}'),
          Text('Nombre de tickets : ${history.ticketIds.length}'),
          Text('ID transaction : ${history.transferHistoryId}'),
          const SizedBox(height: 10),
          const Text('Voulez-vous annuler ce transfert ?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Quitter'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Vérifier que l'utilisateur courant est le sender d'origine
            if (currentUser == null ||
                currentUser.userId != history.senderDTO.userId) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Vous ne pouvez annuler que vos propres transferts',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
              Navigator.pop(context);
              return;
            }

            final success = await ticketProvider.cancelTransfer(
              transactionId: history.transferHistoryId,
              originalSenderDTO: SenderDTO(
                senderId: history.senderDTO.userId,
                senderUsername: history.senderDTO.username,
                senderPassword:
                    ticketProvider.lastSenderDTO?.senderPassword ?? '',
              ),
              currentOwnerDTO: RecipientDTO(
                recipientId: history.recipientDTO.userId,
                recipientUsername: history.recipientDTO.username,
              ),
              ticketIdsToCancel: history.ticketIds,
            );

            if (success && context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transfert annulé avec succès'),
                  backgroundColor: validateBtnColor,
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
          style: ElevatedButton.styleFrom(backgroundColor: redErrorColor),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
} */

/* /* genères moi un widget popupCancelTransfertTicket qui affiche une popup pour annuler un transfert de ticket avec les informations suivantes: le nom du destiantaire, le nombre de tickets transférés et l'id de la transaction, et aussi deux boutons "Quitter" et "Annuler" */
import 'package:flutter/material.dart';

class PopupCancelTransfertTicket extends StatelessWidget {
  final String recipientUsername;
  final int numberOfTickets;
  final String transactionId;

  const PopupCancelTransfertTicket({
    Key? key,
    required this.recipientUsername,
    required this.numberOfTickets,
    required this.transactionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Annuler le transfert de ticket'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Destinataire: $recipientUsername'),
          Text('Nombre de tickets transférés: $numberOfTickets'),
          Text('ID de la transaction: $transactionId'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Quitter'),
        ),
        ElevatedButton(
          onPressed: () {
            // Logique pour annuler le transfert de ticket
            Navigator.of(context).pop();
          },
          child: Text('Annuler'),
        ),
      ],
    );
  }
}
 */
