import 'package:flutter/material.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/home/sizeboxHeightSession.dart';
import 'package:senticket_front/UI/widgets/updateUser/updateEmail.dart';
import 'package:senticket_front/UI/widgets/updateUser/updateFirstName.dart';
import 'package:senticket_front/UI/widgets/updateUser/pageIconTemplate.dart';
import 'package:senticket_front/UI/widgets/updateUser/updateLastName.dart';
import 'package:senticket_front/UI/widgets/updateUser/updatePassword.dart';
import 'package:senticket_front/UI/widgets/updateUser/updateRole.dart';
import 'package:senticket_front/UI/widgets/updateUser/updateUserBtn.dart';
import 'package:senticket_front/UI/widgets/updateUser/updateUsername.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/model/role_model.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:provider/provider.dart';

class UpdateUserBody extends StatefulWidget {
  const UpdateUserBody({super.key});

  @override
  State<UpdateUserBody> createState() => _UpdateUserBodyState();
}

class _UpdateUserBodyState extends State<UpdateUserBody> {
  // Contrôleurs pour les champs
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Role? _selectedRole;

  @override
  void initState() {
    super.initState();
    // Pré-remplir les champs avec les données de l'utilisateur courant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser;

      if (user != null) {
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _usernameController.text = user.username;
        _emailController.text = user.email;
        _passwordController.text = user.password;
        _selectedRole = user.role;

        // Pré-remplir aussi dans le provider
        userProvider.prefillUpdateForm(user);
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(Role? role) {
    setState(() {
      _selectedRole = role;
    });

    if (role != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUpdateRole(role);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const PageIconTemplate(iconData: Icons.update),
            const SizedBox(height: 5),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Column(
                  children: [
                    UpdateFirstName(
                      controller: _firstNameController,
                      onChanged: (value) =>
                          userProvider.setUpdateFirstName(value),
                    ),
                    const SizeboxHeightSession(),
                    UpdateLastName(
                      controller: _lastNameController,
                      onChanged: (value) =>
                          userProvider.setUpdateLastName(value),
                    ),
                    const SizeboxHeightSession(),
                    UpdateUsername(
                      controller: _usernameController,
                      onChanged: (value) =>
                          userProvider.setUpdateUsername(value),
                    ),
                    const SizeboxHeightSession(),
                    UpdateRole(
                      onRoleChanged: _onRoleChanged,
                      selectedRole: _selectedRole,
                    ),
                    const SizeboxHeightSession(),
                    UpdateEmail(
                      controller: _emailController,
                      onChanged: (value) => userProvider.setUpdateEmail(value),
                    ),
                    const SizeboxHeightSession(),
                    UpdatePassword(
                      controller: _passwordController,
                      onChanged: (value) =>
                          userProvider.setUpdatePassword(value),
                    ),
                    const SizeboxHeightSession(),
                    UpdateUserBtn(
                      onUpdateSuccess: () {
                        // Navigation après succès
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Compte modifié avec succès !'),
                            backgroundColor: validateBtnColor,
                          ),
                        );
                      },
                    ),
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

/* class UpdateUserBody extends StatefulWidget {
  const UpdateUserBody({super.key});

  @override
  State<UpdateUserBody> createState() => _UpdateUserBodyState();
}

class _UpdateUserBodyState extends State<UpdateUserBody> {
  @override
  Widget build(BuildContext context) {
    return const Background(
        child: SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PageIconTemplate(iconData: Icons.update),
          SizedBox(height: 5),
          UpdateFirstName(),
          SizeboxHeightSession(),
          UpdateLastName(),
          SizeboxHeightSession(),
          UpdateUsername(),
          SizeboxHeightSession(),
          UpdateRole(),
          SizeboxHeightSession(),
          UpdateEmail(),
          SizeboxHeightSession(),
          UpdatePassword(),
          // SizeboxHeightSession(),
          // UpdateConfirmPassword(),
          UpdateUserBtn()
        ],
      ),
    ));
  }
} */
