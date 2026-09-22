import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/pages/login.dart';
import 'package:senticket_front/UI/pages/qrcode/scanqr.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/debitAccount/DebitUsernameSection.dart';
import 'package:senticket_front/UI/widgets/debitAccount/debitPage.dart';
import 'package:senticket_front/UI/widgets/debitAccount/accessDebitPageBtn.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/model/qr_code_model.dart';


class DebitBody extends StatefulWidget {
  const DebitBody({super.key});

  @override
  State<DebitBody> createState() => _DebitBodyState();
}

class _DebitBodyState extends State<DebitBody> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Réinitialiser l'état de recherche au chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.resetDebitState();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // ============ SCAN QR — ouvre le scanner et traite le résultat ============
  Future<void> _scanQrForDebit({bool scanTicket = false}) async {
    final result = await Navigator.of(context).push<ScanResult>(
      MaterialPageRoute(
        builder: (_) => const ScanQR(
          operationType: ScanOperationType.debit,
          expectTicketQr: true, // ← message adapté
          ),
      ),
    );

    if (result == null || !mounted) return;
    final qrData = result.qrData;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Vérification que la cible est bien un ETUDIANT
    if (qrData.role.toUpperCase() != 'ETUDIANT') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce QR code ne correspond pas à un étudiant'),
          backgroundColor: redErrorColor,
        ),
      );
      return;
    }

    // CAS 1: QR ticket → débit direct d'un ticket précis
    if (result.isDirectTicket && qrData.ticketId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DebitPage(
            studentUsername: qrData.username,
            studentId: qrData.userId,
            preSelectedTicketId: qrData.ticketId,
          ),
        ),
      );
      return;
    }

    // CAS 2: QR utilisateur → sélection manuelle
    _usernameController.text = qrData.username;
    userProvider.setDebitUsername(qrData.username);

    final success = await userProvider.searchUserByUsername(qrData.username);
    if (!mounted) return;

    if (success && userProvider.searchedUser != null) {
      // Naviguer directement vers DebitPage
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DebitPage(
            studentUsername: qrData.username,
            studentId: qrData.userId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.debitUsernameError ?? 'Étudiant non trouvé'),
          backgroundColor: redErrorColor,
        ),
      );
    }
  }

  // Navigation vers DebitPage avec le ticket pré-sélectionné (QR ticket direct)
  void _navigateToDebitWithTicket(QrCodeData qrData, UserProvider userProvider) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DebitPage(
          studentUsername: qrData.username,
          studentId: qrData.userId,
          preSelectedTicketId: qrData.ticketId, // ticket pré-sélectionné
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ticket #${qrData.ticketId} (Type ${qrData.ticketTypeLabel}) '
              'pré-sélectionné pour ${qrData.username}',
        ),
        backgroundColor: validateBtnColor,
      ),
    );
  }

  // ============ VALIDATION MANUELLE (saisie username) ============
  Future<void> _validateStudent(UserProvider userProvider) async {
    if (_usernameController.text.isEmpty) {
      userProvider.setUsernameError(
        'Veuillez entrer un nom d\'utilisateur',
      );
      return;
    }

    // Rechercher l'étudiant par son nom d'utilisateur
    final success = await userProvider.searchUserByUsername(
      _usernameController.text.trim(),
    );

    if (!mounted) return;

    if (success && userProvider.searchedUser != null) {
      final searchedUser = userProvider.searchedUser!;

      // Vérifier que l'utilisateur trouvé est un étudiant
      if (searchedUser.role.name != 'ETUDIANT') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le compte à débiter doit être pour un ETUDIANT'),
            backgroundColor: redErrorColor,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }

      // Naviguer vers la page de sélection de débit
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DebitPage(
            studentUsername: searchedUser.username,
            studentId: searchedUser.userId!,
          ),
        ),
      );
    } else {
      // L'erreur est déjà gérée dans le provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.debitUsernameError ?? 'Erreur inconnue'),
          backgroundColor: redErrorColor,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        final isLoggedIn = user != null;
        final isPorter = isLoggedIn ? user.role.name == 'PORTIER' : false;

        return Background(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
              child: SizedBox(
                width: size.width,
                child: Column(
                  children: [
                    // Interface de débit (seulement si portier connecté)
                    if (isLoggedIn && isPorter)
                      _buildDebitInterface(context, userProvider)
                    else if (isLoggedIn && !isPorter)
                      _buildNotPorterWarning()
                    else
                      _buildLoginRequired(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebitInterface(BuildContext context, UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        // ── Section 1 : Scan QR ──────────────────────────────────────
        // Titre de section discret — remplace le paragraphe explicatif
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Via QR code',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: greyBorderColor,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Bouton QR étudiant
        _buildScanButton(
          label: 'QR étudiant',
          subtitle: 'Sélectionner les tickets après scan',
          tooltip: 'Scannez le QR personnel de l\'étudiant. '
              'Vous pourrez ensuite débiter son compte.',
          icon: Icons.person_search,
          color: kPrimaryColor,
          onPressed: () => _scanQrForDebit(scanTicket: false),
        ),

        const SizedBox(height: 10),

        // Bouton QR ticket
        _buildScanButton(
          label: 'QR ticket',
          subtitle: 'Débit immédiat d\'un ticket précis',
          tooltip: 'Scannez le QR d\'un ticket affiché sur '
              'l\'application de l\'étudiant. '
              'Le débit s\'effectue immédiatement',
          icon: Icons.qr_code_scanner,
          color: cyanColor,
          onPressed: () => _scanQrForDebit(scanTicket: true),
        ),

        const SizedBox(height: 24),

        // ── Section 2 : Saisie manuelle ──────────────────────────────
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Par username',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: greyBorderColor,
              letterSpacing: 0.5,
            ),
          ),
        ),

        Consumer<UserProvider>(
          builder: (context, userProvider, _) => DebitUsernameSection(
            controller: _usernameController,
            onChanged: (value) => userProvider.setDebitUsername(value),
          ),
        ),
        const SizedBox(height: 12),
        Consumer<UserProvider>(
          builder: (context, userProvider, _) => AccessDebitPageBtn(
            onPressed: () => _validateStudent(userProvider),
            isLoading: userProvider.isSearchingUser,
            isFormValid: userProvider.isDebitFormValid,
          ),
        ),
      ],
    );
  }

// Widget bouton scan réutilisable avec titre + sous-titre
  Widget _buildScanButton({
    required String label,
    required String subtitle,
    required String tooltip,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
        message: tooltip,
        preferBelow: false,
        decoration: BoxDecoration(
          color: kThirdColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        child:
        InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: kThirdColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    ),
  );
  }
/*  Widget _buildDebitInterface(BuildContext context, UserProvider userProvider) {
    Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        const InfoContainer(),
        const SizeboxHeightSession(),

        // ── Deux boutons scan distincts et clairs ────────────────────
        Row(
          children: [
            // Bouton 1 : scanner le QR de l'étudiant (sélection manuelle ensuite)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _scanQrForDebit(scanTicket: false),
                icon: const Icon(Icons.person_search, size: 20),
                label: const Text(
                  'QR étudiant',
                  style: TextStyle(fontSize: 13),

                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: kSecondColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Bouton 2 : scanner le QR d'un ticket précis (débit direct)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _scanQrForDebit(scanTicket: true),
                icon: const Icon(Icons.qr_code_scanner, size: 20),
                label: const Text(
                  'QR ticket direct',
                  style: TextStyle(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cyanColor,
                  foregroundColor: kSecondColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizeboxHeightSession(),

        // ── Séparateur OU ─────────────────────────────────────────────
        Row(
          children: [
            const Expanded(child: Divider(color: greyBorderColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OU entrer le username',
                style: TextStyle(
                  fontSize: 12,
                  color: kThirdColor.withValues(alpha: 0.6),
                ),
              ),
            ),
            const Expanded(child: Divider(color: greyBorderColor)),
          ],
        ),

        const SizeboxHeightSession(),

        // ── Saisie manuelle — sans bouton scan ──────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          width: size.width,
          decoration: BoxDecoration(
            color: textContainerColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: boxshadowColor, blurRadius: 6, offset: Offset(0, 2)),
            ],
            border: Border.all(color: kPrimaryColor, width: 1),
          ),
          child: Column(
            children: [
              Consumer<UserProvider>(
                builder: (context, userProvider, _) => DebitUsernameSection(
                  controller: _usernameController,
                  onChanged: (value) => userProvider.setDebitUsername(value),
                ),
              ),
              const SizeboxTemplate(),
              Consumer<UserProvider>(
                builder: (context, userProvider, _) => AccessDebitPageBtn(
                  onPressed: () => _validateStudent(userProvider),
                  isLoading: userProvider.isSearchingUser,
                  isFormValid: userProvider.isDebitFormValid,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }*/

  Widget _buildNotPorterWarning() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.block, size: 80, color: kPrimaryColor),
          const SizedBox(height: 20),
          const Text(
            'Accès réservé aux PORTIERS',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Seuls les PORTIERS peuvent débiter des comptes.',
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
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: kSecondColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
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
            'Connectez-vous pour pouvoir débiter un compte',
            textAlign: TextAlign.center,
            style: TextStyle(color: greyBorderColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
            icon: const Icon(Icons.login),
            label: const Text('Se connecter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: kSecondColor,
            ),
          ),
        ],
      ),
    );
  }
}
