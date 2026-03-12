import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/pages/login.dart';
import 'package:senticket_front/UI/pages/studentInterface.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/cancelTrsf/popupCancelTransfer.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.height.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizeboxHeightSession.dart';
import 'package:senticket_front/UI/widgets/customWidgets/label.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/numberTicketsSection.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/senderPasswordTrsfTicket.dart';
import 'package:senticket_front/UI/widgets/transfert/transfert.ticket/recipientUsernameTrsfTicket.dart';
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
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  TicketType? _selectedTicketType;

  @override
  void initState() {
    super.initState();
    // Réinitialiser l'état de recherche au chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setTransferRecipientUsername('');
    });
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _numberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _validateRecipientUsername(UserProvider userProvider) async {
    if (_recipientController.text.isEmpty) {
      userProvider.setDebitUsernameError(
        'Veuillez entrer le nom du destinataire',
      );
      return;
    }

    // Rechercher le destinataire par son nom d'utilisateur
    final success = await userProvider.searchUserByUsername(
      _recipientController.text.trim(),
    );

    if (success && userProvider.searchedUser != null) {
      final searchedUser = userProvider.searchedUser!;

      // Vérifier que l'utilisateur trouvé est un étudiant
      if (searchedUser.role.name != 'ETUDIANT') {
        userProvider.setDebitUsernameError(
          'Le destinataire doit être un étudiant',
        );
        return;
      }
    } else {
      // L'erreur est déjà gérée dans le provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userProvider.debitUsernameError ?? 'Erreur inconnue',
          ),
          backgroundColor: redErrorColor,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _validateSenderPassword(UserProvider userProvider) async {
    if (_passwordController.text.isEmpty) {
      userProvider.setSenderPasswordError('Veuillez entrer votre mot de passe');
      return;
    }
  }

  Future<void> _validateNumberTickets(TicketProvider ticketProvider) async {
    final numberText = _numberController.text.trim();
    if (numberText.isEmpty) {
      ticketProvider.setNumberOfTicketsError(
        'Veuillez entrer le nombre de tickets',
      );
      return;
    }
  }

  Future<void> _numberTicketsIsValid(TicketProvider ticketProvider) async {
    final numberText = _numberController.text.trim();
    final number = int.tryParse(numberText);
    if (number == null || number <= 0) {
      ticketProvider.setNumberOfTicketsIsInvalid(
        'Le nombre doit être un entier positif',
      );
      return;
    }
  }

  Future<void> _onTransferPressed() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final ticketProvider = Provider.of<TicketProvider>(context, listen: false);

    // Vérifier que l'utilisateur courant est connecté et étudiant
    final currentUser = userProvider.currentUser;
    if (currentUser == null || currentUser.role.name != 'ETUDIANT') {
      await _validateRecipientUsername(userProvider);
      return;
    }

    // Valider le type sélectionné
    if (_selectedTicketType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un type de ticket'),
          backgroundColor: redErrorColor,
        ),
      );
      return;
    }

    // Valider le nombre
    final numberText = _numberController.text.trim();
    if (numberText.isEmpty) {
      await _validateNumberTickets(ticketProvider);
      return;
    }

    final number = int.tryParse(numberText);
    if (number == null || number <= 0) {
      await _numberTicketsIsValid(ticketProvider);
      return;
    }

    // Valider le mot de passe
    if (_passwordController.text.isEmpty) {
      await _validateSenderPassword(userProvider);
      return;
    }

    // Valider le destinataire (et le chercher si pas encore fait)
    if (userProvider.searchedUser == null) {
      await _validateRecipientUsername(userProvider);
      if (userProvider.debitUsernameError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.debitUsernameError!),
            backgroundColor: redErrorColor,
            duration: const Duration(seconds: 5),
          ),
        );
        return;
      }
    }
    final recipient = userProvider.searchedUser!;

    // Construire la requête
    final request = TransfertTicketRequestDTO(
      senderDTO: SenderDTO(
        senderId: currentUser.userId!,
        senderUsername: currentUser.username,
        senderPassword: _passwordController.text,
      ),
      recipentDTO: RecipientDTO(
        recipientId: recipient.userId!,
        recipientUsername: recipient.username,
      ),
      ticketType: _selectedTicketType!,
      numberOfTicketsToTransfer: number,
    );

    final history = await ticketProvider.transferTickets(request);
    if (history != null) {
      // Afficher le popup d'annulation
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => PopupCancelTransfer(transferHistoryDTO: history),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$number ticket(s) transferé(s) avec succès'
           /* '$number ticket(s) de type ${_selectedTicketType == TicketType.a ? 'A' : 'B'} '
            'transféré(s) à ${recipient.username}',*/
          ),
          backgroundColor: validateBtnColor,
          duration: const Duration(seconds: 5),
        ),
      );

      // Réinitialiser les champs
      _recipientController.clear();
      _numberController.clear();
      _passwordController.clear();
      setState(() {
        _selectedTicketType = null;
      });
      userProvider.setTransferRecipientUsername('');
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
    final userProvider = Provider.of<UserProvider>(context);
    final ticketProvider = Provider.of<TicketProvider>(context);

    final isLoggedIn = userProvider.currentUser != null;
    final isStudent = isLoggedIn
        ? userProvider.currentUser!.role.name == 'ETUDIANT'
        : false;

    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isLoggedIn)
              _buildLoginRequired()
            else if (!isStudent)
              _buildNotStudentWarning()
            else
              _buildTransferForm(context, userProvider, ticketProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Column(
      children: [
        const Icon(Icons.lock_person, size: 80, color: greyBorderColor),
        const SizedBox(height: 20),
        const Text(
          'Authentification requise',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: greyBorderColor,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Connectez-vous pour pouvoir transférer des tickets',
          textAlign: TextAlign.center,
          style: TextStyle(color: greyBorderColor),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
          icon: const Icon(Icons.login),
          label: const Text('Se connecter'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: kSecondColor,
          ),
          /* style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor), */
        ),
      ],
    );
  }

  Widget _buildNotStudentWarning() {
    return Column(
      children: [
        const Icon(Icons.block, size: 80, color: kPrimaryColor),
        const SizedBox(height: 20),
        const Text(
          'Accès réservé aux ETUDIANTS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Seuls les ETUDIANTS peuvent transférer leurs tickets.',
          textAlign: TextAlign.center,
          style: TextStyle(color: greyBorderColor),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            final userProvider = Provider.of<UserProvider>(
              context,
              listen: false,
            );
            userProvider.currentUser = null;
            userProvider.resetLoginForm();
          },
          icon: const Icon(Icons.logout, color: kSecondColor),
          label: const Text(
            'Se déconnecter',
            style: TextStyle(color: kSecondColor),
          ),
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
        ),
      ],
    );
  }

  Widget _buildTransferForm(
    BuildContext context,
    UserProvider userProvider,
    TicketProvider ticketProvider,
  ) {
    return Column(
      children: [
        const Icon(Icons.send_rounded, color: kPrimaryColor, size: 70),
        const SizeboxHeight(),
        RecipientUsernameTrsfTicket(
          controller: _recipientController,
          onChanged: (value) {
            userProvider.setDebitUsername(value);
          },
        ),
        const SizeboxHeightSession(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Label(text: 'Type de ticket'),
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
              onChanged: (value) => setState(() => _selectedTicketType = value),
              hint: const Text('Sélectionnez un type de ticket', style: TextStyle(
                color: kPrimaryColor,
                fontSize: 13,
              )),
            ),
          ],
        ),
        const SizeboxHeightSession(),
        NumberTicketsSection(controller: _numberController),
        const SizeboxHeightSession(),
        SenderPasswordTrsfTicket(
          controller: _passwordController,
          onChanged: (value) {
            userProvider.setSenderPassword(value);
          },
        ),
        const SizeboxHeightSession(),
        TransfertTicketBtn(
          onPressed: _onTransferPressed,
          isLoading: ticketProvider.isTransferringTickets,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              iconSize: 60,
              icon: const Icon(Icons.cancel, color: kPrimaryColor),
              tooltip: 'Annuler transfert ticket',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StudentInterface()
                  //const PopupCancelTransfer(transferHistoryDTO: transferHistoryDTO),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
