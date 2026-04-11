import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/enums/transaction_type.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

class PopupCancelTransferById extends StatefulWidget {
  const PopupCancelTransferById({super.key});

  @override
  State<PopupCancelTransferById> createState() =>
      _PopupCancelTransferByIdState();
}

class _PopupCancelTransferByIdState extends State<PopupCancelTransferById> {
  final TextEditingController _transactionIdController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _transactionIdController.dispose();
    super.dispose();
  }

  Future<void> _handleValidate() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

    final idText = _transactionIdController.text.trim();
    if (idText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un ID de transaction'),
          backgroundColor: redErrorColor,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    final transactionId = int.tryParse(idText);
    if (transactionId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID invalide')));
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    // Utiliser la nouvelle méthode
    final history = await ticketProvider.getTransactionHistoryById(
      transactionId,
    );

    setState(() => _isLoading = false);

    if (history == null) {
      // cas IDTransaction non existant
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('transaction non valide'),
            backgroundColor: redErrorColor,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Vérifier que c'est bien une transaction de type TRANSFER
    if (history.transactionType != TransactionType.transfer) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cette transaction n\'est pas un transfert'),
            backgroundColor: redErrorColor,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Vérifier si déjà annulé
    if (history.transferCanceled == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ce transfert a déjà été annulé'),
            backgroundColor: redErrorColor,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Vérifier que l'utilisateur connecté est le sender du transfert
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    if (currentUser == null || currentUser.userId != history.senderDTO?.id) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Non autorisé'),
            backgroundColor: redErrorColor,
          ),
        );
        Navigator.pop(context);
      }
      // Réinitialiser le champ
      _transactionIdController.clear();
      return;
    }

    // Afficher la confirmation avec les détails
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Confirmer l\'annulation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Destinataire : ${history.recipientDTO?.username ?? 'Inconnu'}',
              ),
              Text('Nombre de tickets : ${history.ticketsCount}'),
              Text(
                'Date : ${history.date.toLocal().toString().split('.').first}',
              ),
              Text('ID transaction : ${history.id}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(backgroundColor: cyanColor),
              child: const Text(
                'Quitter',
                style: TextStyle(color: kThirdColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final request = CancelTransferTicketsRequestDTO(
                  cancelTransferDTO: CancelTransferDTO(
                    transactionId: history.id,
                    originalSenderDTO: OriginalSenderDTO(
                      senderId: history.senderDTO!.id,
                      senderUsername: history.senderDTO!.username,
                    ),
                    currentOwnerDTO: RecipientDTO(
                      recipientId: history.recipientDTO!.id,
                      recipientUsername: history.recipientDTO!.username,
                    ),
                  ),
                  ticketIdsToCancel: history.ticketIds,
                );

                final success = await ticketProvider.cancelTransfer(request);

                if (success && context.mounted) {
                  Navigator.pop(context); // fermer la confirmation
                  Navigator.pop(context); // fermer le popup de saisie
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transfert annulé avec succès'),
                      backgroundColor: validateBtnColor,
                      duration: Duration(seconds: 5),
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ticketProvider.error),
                      backgroundColor: redErrorColor,
                      duration: Duration(seconds: 5),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              child: const Text(
                'Confirmer',
                style: TextStyle(color: kSecondColor),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Annuler un transfert'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Label(text: 'Entrez l\'ID de la transaction à annuler'),
          const SizedBox(height: 10),
          Container(
            width: 300,
            height: 50,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: kSecondColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: boxshadowColor,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
              border: Border.all(color: kPrimaryColor, width: 1),
            ),
            child: TextField(
              controller: _transactionIdController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: enterTextFieldColor),
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 14, left: 10),
                hintText: 'ID transaction',
                hintStyle: const TextStyle(color: kPrimaryColor, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(backgroundColor: cyanColor),
              child: const Text(
                'Quitter',
                style: TextStyle(color: kThirdColor),
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleValidate,
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Annuler',
                      style: TextStyle(color: kSecondColor),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
