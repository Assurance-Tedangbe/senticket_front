import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/pages/qrcode/qr_display_page.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/core/utils/error_handler.dart';
import 'package:senticket_front/model/user_model.dart';
import 'package:senticket_front/provider/user_provider.dart';

import '../../core/utils/error_snackbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;

  bool _isEditing = false;
  bool _showPasswordSection = false;
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser!;
    _firstNameController  = TextEditingController(text: user.firstName);
    _lastNameController   = TextEditingController(text: user.lastName);
    _emailController      = TextEditingController(text: user.email);
    _currentPasswordController = TextEditingController();
    _newPasswordController     = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser!;

      final updatedUser = User(
        userId: user.userId,
        username: user.username,
        password: user.password,
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: user.role,
      );

      await userProvider.updateExistingUser(updatedUser);

      if (!mounted) return;
      setState(() { _isEditing = false; _isLoading = false; });
      ErrorSnackbar.showSuccess(context, 'Profil mis à jour avec succès');

    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ErrorSnackbar.show(context, ErrorHandler.fromException(e));
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty) {
      ErrorSnackbar.show(context, 'Veuillez entrer votre mot de passe actuel.');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      ErrorSnackbar.show(
          context, 'Le nouveau mot de passe doit contenir au moins 6 caractères.');
      return;
    }
    if (_newPasswordController.text == _currentPasswordController.text) {
      ErrorSnackbar.show(
          context, 'Le nouveau mot de passe doit être différent de l\'actuel.');
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.userId;

    if (userId == null) {
      setState(() => _isLoading = false);
      ErrorSnackbar.show(context, 'Session invalide. Reconnectez-vous.');
      return;
    }

    // ✅ Appel via le provider — utilise updatePassword du service
    final success = await userProvider.updateUserPassword(
      userId: userId,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      setState(() {
        _showPasswordSection = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
      });
      ErrorSnackbar.showSuccess(context, 'Mot de passe modifié avec succès');
    } else {
      // L'erreur est dans userProvider.error
      ErrorSnackbar.show(
        context,
        userProvider.error.isNotEmpty
            ? userProvider.error
            : 'Impossible de modifier le mot de passe.',
      );
    }
  }
  
/*  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty) {
      ErrorSnackbar.show(context, 'Veuillez entrer votre mot de passe actuel.');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      ErrorSnackbar.show(context,
          'Le nouveau mot de passe doit contenir au moins 6 caractères.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser!.userId!;

      await userProvider.updateExistingUser(
        User(
          userId: userId,
          username: userProvider.currentUser!.username,
          password: _newPasswordController.text,
          email: userProvider.currentUser!.email,
          firstName: userProvider.currentUser!.firstName,
          lastName: userProvider.currentUser!.lastName,
          role: userProvider.currentUser!.role,
        ),
      );

      if (!mounted) return;
      setState(() {
        _showPasswordSection = false;
        _isLoading = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
      });
      ErrorSnackbar.showSuccess(context, 'Mot de passe modifié avec succès');

    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ErrorSnackbar.show(context, ErrorHandler.fromException(e));
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: kPrimaryColor,
        foregroundColor: kSecondColor,
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text(
                'Modifier',
                style: TextStyle(color: kSecondColor, fontSize: 15),
              ),
            )
          else
            TextButton(
              onPressed: () => setState(() {
                _isEditing = false;
                // Réinitialiser les champs
                final user = Provider.of<UserProvider>(
                    context, listen: false).currentUser!;
                _firstNameController.text = user.firstName;
                _lastNameController.text = user.lastName;
                _emailController.text = user.email;
              }),
              child: const Text(
                'Annuler',
                style: TextStyle(color: kSecondColor, fontSize: 15),
              ),
            ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.currentUser;
          if (user == null) {
            return const Center(child: Text('Non connecté'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatarSection(user),
                  const SizedBox(height: 24),
                  _buildInfoSection(user),
                  const SizedBox(height: 16),
                  if (_isEditing) ...[
                    _buildEditableSection(),
                    const SizedBox(height: 16),
                  ],
                  _buildPasswordSection(),
                  const SizedBox(height: 16),
                  if (user.role.name.toUpperCase() == 'ETUDIANT')
                    _buildQrSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarSection(User user) {
    final initials = '${user.firstName.isNotEmpty ? user.firstName[0] : '?'}'
        '${user.lastName.isNotEmpty ? user.lastName[0] : '?'}'
        .toUpperCase();

    final roleColor = switch (user.role.name.toUpperCase()) {
      'ETUDIANT' => kPrimaryColor,
      'PORTIER'  => kPrimaryColor,
      _          => greyBorderColor,
    };

    return Center(
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: roleColor, width: 2.5),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${user.firstName} ${user.lastName}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: kThirdColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: roleColor),
            ),
            child: Text(
              user.role.name,
              style: TextStyle(
                fontSize: 12,
                color: roleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(User user) {
    return _buildCard(
      title: 'Informations du compte',
      children: [
        _buildReadOnlyField(
          icon: Icons.person_outline,
          label: 'Nom d\'utilisateur',
          value: user.username,
          hint: 'Non modifiable',
        ),
        const Divider(height: 1),
        _buildReadOnlyField(
          icon: Icons.badge_outlined,
          label: 'ID',
          value: '#${user.userId}',
        ),
        const Divider(height: 1),
        _buildReadOnlyField(
          icon: Icons.email_outlined,
          label: 'Email',
          value: user.email,
        ),
      ],
    );
  }

  Widget _buildEditableSection() {
    return _buildCard(
      title: 'Modifier mes informations',
      children: [
        _buildEditableField(
          controller: _firstNameController,
          label: 'Prénom',
          icon: Icons.person_outline,
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          controller: _lastNameController,
          label: 'Nom',
          icon: Icons.person_outline,
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
        ),
        const SizedBox(height: 12),
        _buildEditableField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (v) =>
          !v!.contains('@') ? 'Email invalide' : null,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                  color: kSecondColor, strokeWidth: 2),
            )
                : const Text(
              'Enregistrer les modifications',
              style: TextStyle(color: kSecondColor, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return _buildCard(
      title: 'Sécurité',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.lock_outline, color: kPrimaryColor),
          title: const Text('Changer le mot de passe'),
          trailing: Icon(
            _showPasswordSection ? Icons.expand_less : Icons.expand_more,
            color: kPrimaryColor,
          ),
          onTap: () =>
              setState(() => _showPasswordSection = !_showPasswordSection),
        ),
        if (_showPasswordSection) ...[
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildEditableField(
            controller: _currentPasswordController,
            label: 'Mot de passe actuel',
            icon: Icons.lock_outline,
            obscure: _obscureCurrentPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureCurrentPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: kPrimaryColor,
              ),
              onPressed: () => setState(
                      () => _obscureCurrentPassword = !_obscureCurrentPassword),
            ),
          ),
          const SizedBox(height: 12),
          _buildEditableField(
            controller: _newPasswordController,
            label: 'Nouveau mot de passe',
            icon: Icons.lock_reset,
            obscure: _obscureNewPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: kPrimaryColor,
              ),
              onPressed: () => setState(
                      () => _obscureNewPassword = !_obscureNewPassword),
            ),
            validator: (v) =>
            v!.length < 6 ? 'Au moins 6 caractères' : null,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: redErrorColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Changer le mot de passe',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQrSection() {
    return _buildCard(
      title: 'Mon QR code',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.qr_code, color: kPrimaryColor),
          title: const Text('Afficher mon QR code'),
          subtitle: const Text(
            'Permettre à un portier ou un étudiant de vous identifier',
            style: TextStyle(fontSize: 12),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: kPrimaryColor,
            size: 14,
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const QrDisplayPage()),
          ),
        ),
      ],
    );
  }

  // ── Widgets utilitaires ────────────────────────────────────────

  Widget _buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: textContainerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
        boxShadow: const [
          BoxShadow(color: boxshadowColor, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kThirdColor.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required IconData icon,
    required String label,
    required String value,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kPrimaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(
                  fontSize: 11, color: kThirdColor.withValues(alpha: 0.5))),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(
                  fontSize: 15, color: kThirdColor)),
              if (hint != null)
                Text(hint, style: TextStyle(
                    fontSize: 11,
                    color: kThirdColor.withValues(alpha: 0.4),
                    fontStyle: FontStyle.italic)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      cursorColor: kPrimaryColor,
      style: const TextStyle(color: kThirdColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: kPrimaryColor.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: kPrimaryColor),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kPrimaryColor.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: redErrorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: redErrorColor),
        ),
      ),
    );
  }
}