import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/pages/login.dart';
import 'package:senticket_front/UI/pages/scanqr.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/debitAccount/DebitUsernameSection.dart';
import 'package:senticket_front/UI/widgets/debitAccount/debitPage.dart';
import 'package:senticket_front/UI/widgets/debitAccount/accessDebitPageBtn.dart';
import 'package:senticket_front/UI/widgets/debitAccount/infoContainer.dart';
import 'package:senticket_front/UI/widgets/debitAccount/ouContainer.dart';
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

    // D'abord vérifier que l'utilisateur courant est PORTIER
    if (!userProvider.isCurrentUserPorter) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seuls les PORTIERS peuvent effectuer cette opération'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Rechercher l'étudiant par nom d'utilisateur
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
            backgroundColor: Colors.red,
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
          backgroundColor: Colors.red,
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

                    /* const SizeboxTemplate(),
                    // En-tête d'authentification
                    _buildAuthHeader(
                      context,
                      userProvider,
                      isLoggedIn,
                      isPorter,
                    ), */
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthHeader(
    BuildContext context,
    UserProvider userProvider,
    bool isLoggedIn,
    bool isPorter,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn
                      ? ' ${userProvider.currentUser!.username} connecté (${userProvider.currentUser!.role!.name})'
                      : '',
                  style: TextStyle(
                    color: isLoggedIn
                        ? (isPorter ? kThirdColor : kPrimaryColor)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isLoggedIn)
            IconButton(
              onPressed: () {
                userProvider.currentUser = null;
                userProvider.resetLoginForm();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Déconnexion réussie'),
                    backgroundColor: kPrimaryColor,
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: kPrimaryColor),
              tooltip: 'Se déconnecter',
            ),
        ],
      ),
    );
  }

  Widget _buildDebitInterface(BuildContext context, UserProvider userProvider) {
    Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        const InfoContainer(),
        const SizeboxHeightSession(),

        // QR Scanner
        ScanQR(
          onScanned: (username) {
            _onQRScanned(username, userProvider);
          },
        ),
        const SizeboxHeightSession(),

        //const OuContainer(),
        //const SizeboxHeightSession(),

        // Section de saisie du nom d'utilisateur
        Container(
          alignment: Alignment.center,
          height: size.height * 0.3,
          width: size.width * 7,
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
            'Accès réservé aux portiers',
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
            style: TextStyle(color: Colors.grey),
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
              foregroundColor: Colors.white,
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
          const Icon(Icons.lock_person, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Authentification requise',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Connectez-vous pour pouvoir débiter un compte',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
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
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/* class DebitBody extends StatefulWidget {
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
      Provider.of<UserProvider>(context, listen: false).resetDebitState();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _validateStudent() async {
    if (_usernameController.text.isEmpty) {
      // Mettre à jour l'erreur dans le provider
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).setDebitUsernameError('Veuillez entrer un nom d\'utilisateur');
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // D'abord vérifier que l'utilisateur courant est PORTIER
    if (!userProvider.isCurrentUserPorter) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seuls les ETUDIANTS peuvent effectuer cette opération',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Rechercher l'étudiant par nom d'utilisateur
    final success = await userProvider.searchUserByUsername(
      _usernameController.text.trim(),
    );

    if (success && userProvider.searchedUser != null) {
      final searchedUser = userProvider.searchedUser!;

      // Vérifier que l'utilisateur trouvé est un étudiant
      if (searchedUser.role.name != 'ETUDIANT') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('L\'utilisateur doit être un ETUDIANT'),
            backgroundColor: Colors.red,
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
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onQRScanned(String username) {
    _usernameController.text = username;
    // Mettre à jour le provider avec le nom d'utilisateur scanné
    Provider.of<UserProvider>(
      context,
      listen: false,
    ).setDebitUsername(username);
    _validateStudent();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Background(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const InfoContainer(),
                const SizeboxHeightSession(),
                ScanQR(onScanned: _onQRScanned),
                // const SizeboxHeightSession(),
                // const OuContainer(),
                const SizeboxHeightSession(),
                // Section de saisie du nom d'utilisateur
                Container(
                  alignment: Alignment.center,
                  height: size.height * 0.3,
                  width: size.width * 7,
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
                      DebitUsernameSection(
                        controller: _usernameController,
                        onChanged: (value) {
                          userProvider.setDebitUsername(value);
                        },
                        //  errorText: userProvider.debitUsernameError,
                      ),
                      const SizeboxTemplate(),
                      AccessDebitPageBtn(
                        onPressed: _validateStudent,
                        isLoading: userProvider.isSearchingUser,
                        isFormValid: userProvider.isDebitFormValid,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} */

/* class DebitBody extends StatefulWidget {
  const DebitBody({super.key});

  @override
  State<DebitBody> createState() => _DebitBodyState();
}

class _DebitBodyState extends State<DebitBody> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isSearching = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _validateStudent() async {
    if (_usernameController.text.isEmpty) {
      setState(() {
        _error = 'Veuillez entrer un nom d\'utilisateur';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // D'abord vérifier que l'utilisateur courant est PORTIER
      final currentUser = userProvider.currentUser;
      if (currentUser == null || currentUser.role.name != 'PORTIER') {
        throw Exception(
          'Seuls les utilisateurs PORTIER peuvent effectuer cette opération',
        );
      }

      // Rechercher l'étudiant par nom d'utilisateur
      await userProvider.searchUserByUsername(_usernameController.text.trim());

      final searchedUser = userProvider.searchedUser;
      if (searchedUser == null) {
        throw Exception('Utilisateur non trouvé');
      }

      // Vérifier que l'utilisateur trouvé est un étudiant
      if (searchedUser.role?.name != 'ETUDIANT') {
        throw Exception('L\'utilisateur doit être un étudiant (ETUDIANT)');
      }

      // Naviguer vers la page de sélection de débit
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DebitPage(
            studentUsername: searchedUser.username!,
            studentId: searchedUser.userId!,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onQRScanned(String username) {
    _usernameController.text = username;
    _validateStudent();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const InfoContainer(),
            const SizeboxHeightSession(),

            // Scanner QR
            ScanQR(onScanned: _onQRScanned),
            const SizeboxHeightSession(),

            const OuContainer(),
            const SizeboxHeightSession(),

            // Section de saisie du nom d'utilisateur
            Container(
              alignment: Alignment.center,
              height: size.height * 0.3,
              width: size.width * 7,
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
                  DebitUsernameSection(
                    controller: _usernameController,
                    onChanged: (value) {
                      setState(() {
                        _error = null;
                      });
                    },
                    errorText: _error,
                  ),
                  const SizeboxTemplate(),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return AccessDebitPageBtn(
                        onPressed: _validateStudent,
                        isLoading: _isSearching || userProvider.isSearchingUser,
                        isFormValid: _usernameController.text.isNotEmpty,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} */

/* 
// Widget principal pour debiter un compte
class DebitBody extends StatefulWidget {
  const DebitBody({super.key});

  @override
  State<DebitBody> createState() => _DebitBodyState();
}

class _DebitBodyState extends State<DebitBody> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const InfoContainer(),
            const SizeboxHeightSession(),
            const ScanQR(),
            // const SizeboxHeightSession(),
            // const OuContainer(),
            const SizeboxHeightSession(),
            Container(
              alignment: Alignment.center,
              height: size.height * 0.3,
              width: size.width * 10,
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
                // border: Border.all(color: kPrimaryColor, width: 1),
              ),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DebitUsernameSection(
                        controller: _usernameController,
                        onChanged: (value) =>
                            userProvider.setDebitUsername(value),
                      ),
                      SizeboxTemplate(),
                      /*  AccessDebitPageBtn(
                        onFormSuccess: (int userId) {
                          // Naviguer vers DebitPage avec l'ID de l'utilisateur
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DebitPage(userId: userId),
                            ),
                          );
                        },
                      ), */
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} */
