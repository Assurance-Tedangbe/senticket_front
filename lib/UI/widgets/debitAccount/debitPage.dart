import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/widgets/background.dart';
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
    await ticketProvider.fetchStudentTicketsForDebit(
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
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Vérifier que l'utilisateur courant est un PORTIER
    final currentUser = userProvider.currentUser;
    if (currentUser == null || currentUser.role?.name != 'PORTIER') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seuls les portiers peuvent débiter des comptes'),
          backgroundColor: redErrorColor,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Créer le DTO de requête de débit
    final request = DebitAccountRequestDTO(
      debitPorterDTO: DebitPorterDTO(
        porterId: currentUser.userId!,
        porterUsername: currentUser.username!,
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
            '${ticketProvider.selectedTicketIdsForDebit.length} ticket(s) débité(s) avec succès pour ${widget.studentUsername}',
          ),
          backgroundColor: validateBtnColor,
          duration: const Duration(seconds: 3),
        ),
      );

      // Rafraîchir les tickets après un débit réussi
      if (_selectedTicketType != null) {
        await ticketProvider.fetchStudentTicketsForDebit(
          studentId: widget.studentId,
          ticketType: _selectedTicketType,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ticketProvider.error),
          backgroundColor: redErrorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          ),
          body: Background(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Information de l'étudiant
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Étudiant: ${widget.studentUsername}',
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<TicketType>(
                    value: _selectedTicketType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
                      const Center(child: CircularProgressIndicator())
                    else if (ticketProvider.error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                ticketProvider.error,
                                style: const TextStyle(color: Colors.red),
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
                              'Aucun ticket de type ${_selectedTicketType == TicketType.a ? 'A' : 'B'} disponible pour le débit (booked=true, status=BOOKED)',
                              style: const TextStyle(color: Colors.grey),
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
                            'Tickets disponibles (${ticketProvider.studentTicketsForDebit.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (ticketProvider.studentTicketsForDebit.isNotEmpty)
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed:
                                      ticketProvider.selectAllTicketsForDebit,
                                  child: const Text('Tout sélectionner'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed:
                                      ticketProvider.deselectAllTicketsForDebit,
                                  child: const Text('Tout désélectionner'),
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Sélectionnés: $selectedCount ticket(s)',
                        style: TextStyle(
                          color: selectedCount > 0 ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ticketProvider.studentTicketsForDebit.length,
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: ticketProvider.isDebitingAccount
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Débiter $selectedCount ticket(s)',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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
        );
      },
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    Ticket ticket,
    TicketProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: ticket.isSelected ? Colors.green[50] : null,
      child: ListTile(
        leading: Checkbox(
          value: ticket.isSelected,
          onChanged: (value) {
            provider.toggleTicketSelectionForDebit(ticket.ticketId!);
          },
        ),
        title: Text('Ticket #${ticket.ticketId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${ticket.ticketType.toString().split('.').last}'),
            Text('Prix: ${ticket.ticketPrice} FCFA'),
            Text('Statut: ${ticket.ticketStatus.toString().split('.').last}'),
            if (ticket.paymentCode.isNotEmpty)
              Text('Code: ${ticket.paymentCode}'),
            if (ticket.ticketCreationDate != null)
              Text('Créé: ${_formatDate(ticket.ticketCreationDate)}'),
          ],
        ),
        trailing: Icon(
          ticket.isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: ticket.isSelected ? Colors.green : Colors.grey,
        ),
        onTap: () {
          provider.toggleTicketSelectionForDebit(ticket.ticketId!);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/*
// Page pour effectuer l'opération de debit de compte
class DebitPage extends StatefulWidget {
  final int userId;

  const DebitPage({super.key, required this.userId});

  @override
  State<DebitPage> createState() => _DebitPageState();
}

class _DebitPageState extends State<DebitPage> {
  static const String _title = 'Debiter un compte';

  @override
  void initState() {
    super.initState();
    // Charger l'utilisateur au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadUserById(widget.userId);
    });
  }

  // Méthode pour masquer le mot de passe
  String _maskPassword(String password) {
    if (password.isEmpty) return '********';
    return '*' * password.length; // Afficher 8 étoiles pour la sécurité
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text(_title), backgroundColor: kPrimaryColor),
      /* nous pouvons directement utiliser userProvider.currentUser 
         sans avoir besoin d'un FutureBuilder suppl.  */
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && userProvider.currentUser == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userProvider.currentUser; // ← Données déjà disponibles

          // Pas besoin de FutureBuilder car les données sont déjà dans le Provider
          return Background(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Carte principale des informations
                  Container(
                    alignment: Alignment.center,
                    width: size.width * 0.9,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: textContainerColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: boxshadowColor,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        // Icône utilisateur
                        const Icon(
                          Icons.account_circle,
                          size: 80,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(height: 20),

                        if (user == null)
                          const Center(
                            child: Text(
                              'Aucune donnée utilisateur disponible',
                              style: TextStyle(
                                color: greyBorderColor,
                                fontSize: 16,
                              ),
                            ),
                          )
                        else
                          _buildUserInfo(user),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Bouton de retour
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Réinitialiser l'utilisateur courant si nécessaire
                      userProvider.clearCurrentUser();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Retour',
                      style: TextStyle(
                        color: kSecondColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget pour construire les informations utilisateur
  Widget _buildUserInfo(User user) {
    return Column(
      children: <Widget>[
        // ID utilisateur
        _buildInfoRow('ID', user.userId?.toString() ?? 'N/A'),
        const Divider(color: greyBorderColor),

        // Nom complet
        _buildInfoRow(
          'Nom complet',
          '${user.firstName} ${user.lastName}'.trim(),
        ),
        const Divider(color: greyBorderColor),

        // Nom d'utilisateur
        _buildInfoRow('Nom d\'utilisateur', user.username),
        const Divider(color: greyBorderColor),
        // Email
        _buildInfoRow('Email', user.email),
        const Divider(color: greyBorderColor),

        // Mot de passe (masqué)
        _buildInfoRow(
          'Mot de passe',
          _maskPassword(user.password),
          isPassword: true,
        ),
        const Divider(color: greyBorderColor),

        // Rôle
        _buildInfoRow('Rôle', user.role.name),
      ],
    );
  }

  // Widget pour une ligne d'information
  Widget _buildInfoRow(String label, String value, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kThirdColor,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: isPassword ? greyBorderColor : kThirdColor,
                fontSize: 16,
                fontStyle: isPassword ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 */
