import 'package:flutter/material.dart';
import 'package:senticket_front/UI/pages/login.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/home/sizeboxHeightSession.dart';
import 'package:senticket_front/UI/widgets/signup/checksignin.btn.dart';
import 'package:senticket_front/UI/widgets/signup/confirmpwdsection.dart';
import 'package:senticket_front/UI/widgets/signup/emailsection.dart';
import 'package:senticket_front/UI/widgets/signup/firstnamesection.dart';
import 'package:senticket_front/UI/widgets/signup/lastnamesection.dart';
import 'package:senticket_front/UI/widgets/signup/passwordsection.dart';
import 'package:senticket_front/UI/widgets/signup/roleSection.dart';
import 'package:senticket_front/UI/widgets/signup/signup.Btn.dart';
import 'package:senticket_front/UI/widgets/signup/usernamesection.dart';
import 'package:senticket_front/UI/widgets/updateUser/pageIconTemplate.dart';
import 'package:senticket_front/model/role_model.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

/*
  Widget principal qui organise tous les champs du formulaire d'inscription.
  Maintenant tous les sous-widgets sont des StatelessWidget dynamisés.
  StatefulWidget car GESTION DES TextEditingController (Raison principale), 
  Nettoyage obligatoire pour éviter les memory leaks, État local pour le rôle sélectionné

  Architecture propre : Le parent (SignupBody) gère les contrôleurs
   Les enfants (widgets de champs) les reçoivent en paramètre
   Séparation des responsabilités claire */
class SignupBody extends StatefulWidget {
  const SignupBody({super.key});

  @override
  State<SignupBody> createState() => _SignupBodyState();
}

// Le PARENT gère la création/destruction
class _SignupBodyState extends State<SignupBody> {
  // 1. Création du contrôleur
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ⭐ CHANGEMENT : Stockez l'objet Role complet, pas juste le nom
  Role? _selectedRole;

  // État local pour le rôle sélectionné
  // String? _selectedRole;

  @override
  void dispose() {
    // Nettoyage obligatoire pour éviter les memory leaks
    // 2. Libérer le contrôleur lorsque le widget est détruit
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignupSuccess() {
    // Navigation vers la page de connexion après inscription réussie
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  /* État local pour le rôle:Le rôle sélectionné est un état local temporaire
     Pas besoin de le mettre dans le Provider global
     setState() est parfait pour ça */
  // ⭐ CHANGEMENT : Accepte un objet Role, pas un String
  void _onRoleChanged(Role? role) {
    setState(() {
      // ← Besoin de setState pour reconstruire
      _selectedRole = role;
    });

    // Vous pouvez aussi stocker le rôle dans le UserProvider si nécessaire
    // ⭐ IMPORTANT : Transmettez aussi au UserProvider
    if (role != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setRole(role);
      print('🔄 Rôle transmis au provider: ${role.name} (ID: ${role.roleId})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        // Permet de scroller si le formulaire est trop long
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Icône de la page
            const PageIconTemplate(iconData: Icons.person_add),
            const SizedBox(height: 5),

            // Sections du formulaire avec passage des contrôleurs
            // ⭐ AJOUT : Connectez les contrôleurs au provider
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Column(
                  children: [
                    FirstNameSection(
                      controller: _firstNameController, // PASSAGE ou Injection
                      onChanged: (value) => userProvider.setFirstname(value),
                    ),
                    const SizeboxHeightSession(),
                    LastNameSection(
                      controller: _lastNameController,
                      onChanged: (value) => userProvider.setLastname(value),
                    ),
                    const SizeboxHeightSession(),
                    UsernameSection(
                      controller: _usernameController,
                      onChanged: (value) => userProvider.setUsername(value),
                    ),
                    const SizeboxHeightSession(),
                    // ⭐ CHANGEMENT : Passez la valeur sélectionnée
                    RoleSection(
                      onRoleChanged: _onRoleChanged,
                      selectedRole: _selectedRole,
                    ),
                    const SizeboxHeightSession(),
                    EmailSection(
                      controller: _emailController,
                      onChanged: (value) => userProvider.setEmail(value),
                    ),
                    const SizeboxHeightSession(),
                    PasswordSection(
                      controller: _passwordController,
                      onChanged: (value) => userProvider.setPassword(value),
                    ),
                    const SizeboxHeightSession(),
                    ConfirmPwdSection(
                      controller: _confirmPasswordController,
                      onChanged: (value) =>
                          userProvider.setConfirmPassword(value),
                    ),
                    const SizeboxHeightSession(),
                    // Bouton de soumission (activé/désactivé dynamiquement)
                    SignupBtn(onSignupSuccess: _onSignupSuccess),
                    const CheckSigninBtn(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
