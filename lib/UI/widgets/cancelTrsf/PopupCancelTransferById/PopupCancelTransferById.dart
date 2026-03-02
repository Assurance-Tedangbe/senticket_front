import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/constants.dart';
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
    final idText = _transactionIdController.text.trim();
    if (idText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un ID de transaction'),
          // backgroundColor: redErrorColor,
        ),
      );
      return;
    }
    final transactionId = int.tryParse(idText);
    if (transactionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID invalide'),
          // backgroundColor: redErrorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final history = await ticketProvider.getTransferHistoryById(transactionId);

    setState(() => _isLoading = false);

    if (history == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ticketProvider.error),
            backgroundColor: redErrorColor,
          ),
        );
      }
      return;
    }

    // Vérifier que l'utilisateur connecté est le sender du transfert
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    if (currentUser == null || currentUser.userId != history.senderDTO.userId) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Non autorisé'),
            backgroundColor: redErrorColor,
          ),
        );
      }
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
              Text('Destinataire : ${history.recipientDTO.username}'),
              Text(
                'Nombre de tickets : ${_parseTicketIds(history.ticketIdsTransfered).length}',
              ),
              Text(
                'Date : ${history.transferDate.toLocal().toString().split('.').first}',
              ),
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
                final ticketIds = _parseTicketIds(history.ticketIdsTransfered);
                final request = CancelTransferTicketsRequestDTO(
                  cancelTransferDTO: CancelTransferDTO(
                    transactionId: history.transferHistoryId,
                    originalSenderDTO: OriginalSenderDTO(
                      senderId: history.senderDTO.userId,
                      senderUsername: history.senderDTO.username,
                    ),
                    currentOwnerDTO: RecipientDTO(
                      recipientId: history.recipientDTO.userId,
                      recipientUsername: history.recipientDTO.username,
                    ),
                  ),
                  ticketIdsToCancel: ticketIds,
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

  List<int> _parseTicketIds(String ticketIdsStr) {
    String cleaned = ticketIdsStr.replaceAll('[', '').replaceAll(']', '');
    if (cleaned.isEmpty) return [];
    return cleaned.split(',').map((s) => int.parse(s.trim())).toList();
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
                contentPadding: const EdgeInsets.only(top: 14),
                hintText: 'ID transaction',
                hintStyle: const TextStyle(color: kPrimaryColor, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(backgroundColor: cyanColor),
          child: const Text('Quitter', style: TextStyle(color: kThirdColor)),
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
              : const Text('Annuler', style: TextStyle(color: kSecondColor)),
        ),
      ],
    );
  }
}

/* class PopupCancelTransferById extends StatefulWidget {
  const PopupCancelTransferById({super.key});

  @override
  State<PopupCancelTransferById> createState() =>
      _PopupCancelTransferByIdState();
}

class _PopupCancelTransferByIdState extends State<PopupCancelTransferById> {
  final TextEditingController _idController = TextEditingController();
  bool _isLoading = false;
  TransfertHistoryDTO? _fetchedHistory;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    return AlertDialog(
      title: const Text('Annuler un transfert'),
      content: _fetchedHistory == null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Entrez l\'ID de la transaction :'),
                const SizedBox(height: 10),
                TextField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'ID transaction',
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Destinataire : ${_fetchedHistory!.recipientDTO.username}',
                ),
                Text(
                  'Nombre de tickets : ${_fetchedHistory!.ticketIds.length}',
                ),
                Text('ID transaction : ${_fetchedHistory!.transferHistoryId}'),
                const SizedBox(height: 10),
                const Text('Voulez-vous annuler ce transfert ?'),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Quitter'),
        ),
        if (_fetchedHistory == null)
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    final idText = _idController.text.trim();
                    if (idText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez entrer un ID'),
                          backgroundColor: redErrorColor,
                        ),
                      );
                      return;
                    }
                    final id = int.tryParse(idText);
                    if (id == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ID invalide'),
                          backgroundColor: redErrorColor,
                        ),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);
                    final history = await ticketProvider
                        .fetchTransferHistoryById(id);
                    setState(() {
                      _isLoading = false;
                      _fetchedHistory = history;
                    });

                    if (history == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ticketProvider.error),
                          backgroundColor: redErrorColor,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Rechercher'),
          )
        else
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    // Vérifier que l'utilisateur courant est le sender
                    if (currentUser == null ||
                        currentUser.userId !=
                            _fetchedHistory!.senderDTO.userId) {
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

                    setState(() => _isLoading = true);
                    final success = await ticketProvider.cancelTransfer(
                      transactionId: _fetchedHistory!.transferHistoryId,
                      originalSenderDTO: SenderDTO(
                        senderId: _fetchedHistory!.senderDTO.userId,
                        senderUsername: _fetchedHistory!.senderDTO.username,
                        senderPassword:
                            '', // Ici on ne connaît pas le mot de passe; le backend devra l'accepter sans?
                        // Idéalement, le backend ne devrait pas exiger le mot de passe pour l'annulation.
                      ),
                      currentOwnerDTO: RecipientDTO(
                        recipientId: _fetchedHistory!.recipientDTO.userId,
                        recipientUsername:
                            _fetchedHistory!.recipientDTO.username,
                      ),
                      ticketIdsToCancel: _fetchedHistory!.ticketIds,
                    );
                    setState(() => _isLoading = false);

                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transfert annulé'),
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
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Annuler'),
          ),
      ],
    );
  }
}
 */
