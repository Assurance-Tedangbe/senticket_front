import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/pages/cancelTransfertTicket.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.height.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizeboxHeightSession.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/numberTicketsSection.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/senderPasswordTrsfTicket.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/recipientUsernameTrsfTicket.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/ticketTypeSection.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/trsfTicketBtn.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/enums/ticket_type.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

class TrsfTicketBody extends StatefulWidget {
  const TrsfTicketBody({super.key});

  @override
  State<TrsfTicketBody> createState() => _TrsfTicketBodyState();
}

class _TrsfTicketBodyState extends State<TrsfTicketBody> {
  TicketType? _selectedTicketType;

  @override
  void initState() {
    super.initState();
    // Réinitialiser l'état du provider quand on entre dans cette page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TicketProvider>(context, listen: false).resetDebitState();
    });
  }

  void _onTicketTypeChanged(TicketType? value) async {
    if (value == null) return;

    setState(() {
      _selectedTicketType = value;
    });

    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    /*  await ticketProvider.getPurchasedTicketsByUser(
      studentId: widget.studentId,
      ticketType: value,
    ); */
  }

  void _onTransfertTicketPressed() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    /* // Vérifier s'il y a des tickets sélectionnés
    if (ticketProvider.selectedTicketIdsForDebit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un ticket'),
          backgroundColor: redErrorColor,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    } */

    // Vérifier que l'utilisateur courant est un ETUDIANT
    final currentUser = userProvider.currentUser;
    if (currentUser == null || currentUser.role.name != 'ETUDIANT') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seuls les ETUDIANTS peuvent transférer leurs tickets'),
          backgroundColor: redErrorColor,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // Créer le DTO de requête de transfert

    final request = TransfertTicketRequestDTO(
      senderDTO: SenderDTO(
        senderId: currentUser.userId!,
        senderUsername: currentUser.username,
      ),
      recipentDTO: RecipientDTO(
        recipientId: widget.studentId,
        recipientUsername: widget.studentUsername,
      ),
      ticketIds: ticketProvider.selectedTicketIdsForDebit,
    );

    // Effectuer l'opération de transfert
    final success = await ticketProvider.transfertTicket(request);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ticket(s) transférés à ${widget.studentUsername}'),
          backgroundColor: validateBtnColor,
          duration: const Duration(seconds: 5),
        ),
      );

      // Rafraîchir les tickets après un transfert réussi
      if (_selectedTicketType != null) {
        await ticketProvider.getPurchasedTicketsByUser(
          studentId: widget.studentId,
          ticketType: _selectedTicketType,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ticketProvider.error),
          backgroundColor: redErrorColor,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.send_rounded, color: kPrimaryColor, size: 70),
            const SizeboxHeight(),
            RecipientUsernameTrsfTicket(),
            const SizeboxHeightSession(),
            Label(text: 'Type de ticket à transférer'),
            const SizedBox(height: 10),
            DropdownButtonFormField<TicketType>(
              initialValue: _selectedTicketType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: kPrimaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: TicketType.a,
                  child: Text(
                    'Type A',
                    style: TextStyle(
                      color: _selectedTicketType == TicketType.a
                          ? kPrimaryColor
                          : Colors.black,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: TicketType.b,
                  child: Text(
                    'Type B',
                    style: TextStyle(
                      color: _selectedTicketType == TicketType.b
                          ? kPrimaryColor
                          : Colors.black,
                    ),
                  ),
                ),
              ],
              onChanged: _onTicketTypeChanged,
              hint: const Text('Sélectionnez un type de ticket'),
            ),
            NumberTicketsSection(),
            const SizeboxHeightSession(),
            SenderPasswordTrsfTicket(),
            const SizeboxHeightSession(),
            TransfertTicketBtn(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  iconSize: 60,
                  icon: const Icon(Icons.cancel, color: kPrimaryColor),
                  tooltip: 'Annuler transfert ticket',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CancelTrsfTicket(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* Sans dynamisation
class TrsfTicketBody extends StatelessWidget {
  const TrsfTicketBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.send_rounded, color: kPrimaryColor, size: 70),
            const SizeboxHeight(),
            RecipientUsernameTrsfTicketSection(),
            const SizeboxHeightSession(),
            NumberTicketsSection(),
            const SizeboxHeightSession(),
            const Padding(
              padding: EdgeInsets.fromLTRB(25.0, 0.0, 8.0, 0.0),
              child: TicketTypeSection(),
            ),
            const SizeboxHeightSession(),
            PasswordTrsfTicketSection(),
            const SizeboxHeightSession(),
            TransfertTicketBtn(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  iconSize: 60,
                  icon: const Icon(Icons.cancel, color: kPrimaryColor),
                  tooltip: 'Annuler transfert ticket',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CancelTrsfTicket(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} */
