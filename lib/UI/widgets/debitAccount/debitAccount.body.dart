import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/pages/login.dart';
import 'package:senticket_front/UI/pages/scanqr.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/debitAccount/DebitUsernameSection.dart';
import 'package:senticket_front/UI/widgets/debitAccount/debitPage.dart';
import 'package:senticket_front/UI/widgets/debitAccount/accessDebitPageBtn.dart';
import 'package:senticket_front/UI/widgets/debitAccount/infoContainer.dart';
import 'package:senticket_front/UI/widgets/home/sizebox.template.dart';
import 'package:senticket_front/UI/widgets/home/sizeboxHeightSession.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';

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

  Future<void> _validateStudent(UserProvider userProvider) async {
    if (_usernameController.text.isEmpty) {
      userProvider.setDebitUsernameError(
        'Veuillez entrer un nom d\'utilisateur',
      );
      return;
    }

    // Rechercher l'étudiant par son nom d'utilisateur
    final success = await userProvider.searchUserByUsername(
      _usernameController.text.trim(),
    );

    if (success && userProvider.searchedUser != null) {
      final searchedUser = userProvider.searchedUser!;

      // Vérifier que l'utilisateur trouvé est un étudiant
      if (searchedUser.role.name != 'ETUDIANT') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le compte à débiter doit être pour un ETUDIANT'),
            backgroundColor: redErrorColor,
            duration: Duration(seconds: 3),
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
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onQRScanned(String username, UserProvider userProvider) {
    _usernameController.text = username;
    // Mettre à jour le provider avec le nom d'utilisateur scanné
    userProvider.setDebitUsername(username);
    _validateStudent(userProvider);
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
    Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        const InfoContainer(),
        const SizeboxHeightSession(),

        ScanQR(
          onScanned: (username) {
            _onQRScanned(username, userProvider);
          },
        ),
        const SizeboxHeightSession(),
        // Section de saisie du nom d'utilisateur
        Container(
          alignment: Alignment.center,
          height: size.height * 0.3,
          width: size.width,
          decoration: BoxDecoration(
            color: textContainerColor,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return DebitUsernameSection(
                    controller: _usernameController,
                    onChanged: (value) {
                      userProvider.setDebitUsername(value);
                    },
                    //  errorText: userProvider.debitUsernameError,
                  );
                },
              ),
              const SizeboxTemplate(),
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return AccessDebitPageBtn(
                    onPressed: () => _validateStudent(userProvider),
                    isLoading: userProvider.isSearchingUser,
                    isFormValid: userProvider.isDebitFormValid,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

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
