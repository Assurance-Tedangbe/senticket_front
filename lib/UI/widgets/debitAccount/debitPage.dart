import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/customWidgets/customCircularProgressIndicator.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/enums/ticket_type.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/provider/ticket_provider.dart';
import 'package:senticket_front/provider/user_provider.dart';

class DebitPage extends StatefulWidget {
  final String studentUsername;
  final int studentId;

  const DebitPage({
    super.key,
    required this.studentUsername,
    required this.studentId,
  });

  @override
  State<DebitPage> createState() => _DebitPageState();
}

class _DebitPageState extends State<DebitPage> {
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
    await ticketProvider.getPurchasedTicketsByUser(
      studentId: widget.studentId,
      ticketType: value,
    );
  }

  void _onDebitPressed() async {
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Vérifier s'il y a des tickets sélectionnés
    if (ticketProvider.selectedTicketIdsForDebit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins un ticket'),
          backgroundColor: redErrorColor,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // Vérifier que l'utilisateur courant est un PORTIER
    final currentUser = userProvider.currentUser;
    if (currentUser == null || currentUser.role.name != 'PORTIER') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seuls les PORTIERS peuvent débiter des comptes'),
          backgroundColor: redErrorColor,
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    // Créer le DTO de requête de débit
    final request = DebitAccountRequestDTO(
      debitPorterDTO: DebitPorterDTO(
        porterId: currentUser.userId!,
        porterUsername: currentUser.username,
      ),
      debitStudentDTO: DebitStudentDTO(
        debitStudentId: widget.studentId,
        username: widget.studentUsername,
      ),
      ticketIds: ticketProvider.selectedTicketIdsForDebit,
    );

    // Effectuer l'opération de débit
    final success = await ticketProvider.debitAccount(request);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ticket(s) débité(s) avec succès pour ${widget.studentUsername}',
          ),
          backgroundColor: validateBtnColor,
          duration: const Duration(seconds: 5),
        ),
      );

      // Rafraîchir les tickets après un débit réussi
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
    Size size = MediaQuery.of(context).size;
    return Consumer<TicketProvider>(
      builder: (context, ticketProvider, child) {
        final selectedCount = ticketProvider.selectedTicketIdsForDebit.length;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: const Text('Sélection des tickets à débiter'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: kPrimaryColor,
          ),
          backgroundColor: secondColor,
          body: Background(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Container(
                alignment: Alignment.center,
                width: size.width,
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                decoration: BoxDecoration(
                  color: secondColor,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Information de l'étudiant
                    Card(
                      color: secondColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 40,
                              color: kPrimaryColor,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ÉTUDIANT: ${widget.studentUsername}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${widget.studentId}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Sélection du type de ticket
                    const Text(
                      'Type de ticket à débiter:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

                    const SizedBox(height: 20),

                    // Liste des tickets
                    if (_selectedTicketType != null) ...[
                      if (ticketProvider.isLoadingStudentTickets)
                        const Center(child: CustomCircularProgressIndicator())
                      else if (ticketProvider.error.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: redErrorColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: redErrorColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ticketProvider.error,
                                  style: const TextStyle(color: redErrorColor),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (ticketProvider.studentTicketsForDebit.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                'Aucun ticket de type ${_selectedTicketType == TicketType.a ? 'A' : 'B'} acheté',
                                style: const TextStyle(
                                  color: enterTextFieldColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tickets achetés (${ticketProvider.studentTicketsForDebit.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (ticketProvider.studentTicketsForDebit.isNotEmpty)
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed:
                                    ticketProvider.selectAllTicketsForDebit,
                                child: const Text(
                                  'Tout sélectionner',
                                  style: TextStyle(color: kThirdColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed:
                                    ticketProvider.deselectAllTicketsForDebit,
                                child: const Text(
                                  'Tout désélectionner',
                                  style: TextStyle(color: kThirdColor),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 10),

                        Text(
                          'Sélectionnés: $selectedCount ticket(s)',
                          style: TextStyle(
                            color: selectedCount > 0
                                ? kThirdColor
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              ticketProvider.studentTicketsForDebit.length,
                          itemBuilder: (context, index) {
                            final ticket =
                                ticketProvider.studentTicketsForDebit[index];
                            return _buildTicketCard(
                              context,
                              ticket,
                              ticketProvider,
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Bouton de débit
                      if (ticketProvider.studentTicketsForDebit.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: ticketProvider.isDebitingAccount
                                ? null
                                : _onDebitPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedCount > 0
                                  ? kPrimaryColor
                                  : greyBorderColor,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: ticketProvider.isDebitingAccount
                                ? CustomCircularProgressIndicator()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Débiter $selectedCount ticket(s)',
                                        style: const TextStyle(
                                          color: kSecondColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    Ticket ticket,
    TicketProvider provider,
  ) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 0.5),
            color: ticket.isSelected ? Colors.blue[50] : null,
            child: ListTile(
              leading: Checkbox(
                value: ticket.isSelected,
                onChanged: (value) {
                  provider.toggleTicketSelectionForDebit(ticket.ticketId!);
                },
                checkColor: kSecondColor,
                activeColor: kPrimaryColor,
              ),
              title: Text('Ticket ${ticket.ticketId}'),
              /*  subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text('Type: ${ticket.ticketType.toString().split('.').last}'),
                  Text('Prix: ${ticket.ticketPrice} FCFA'),
                  Text('Statut: ${ticket.ticketStatus.toString().split('.').last}'),
                  if (ticket.paymentCode.isNotEmpty)
                     Text('Code: ${ticket.paymentCode}'),
                  if (ticket.ticketCreationDate != null)
                     Text('Créé: ${_formatDate(ticket.ticketCreationDate!)}'),
                  ],
                 ), */
              /*  trailing: Icon(
                  ticket.isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                        color: ticket.isSelected ? kPrimaryColor : Colors.grey,
              ), */
              onTap: () {
                provider.toggleTicketSelectionForDebit(ticket.ticketId!);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
