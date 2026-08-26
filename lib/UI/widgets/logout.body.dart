import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/UI/pages/coverPage.dart';
import 'package:senticket_front/UI/widgets/background.dart';
import 'package:senticket_front/UI/widgets/customWidgets/sizebox.template.dart';
import 'package:senticket_front/UI/widgets/updateUser/pageIconTemplate.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/provider/user_provider.dart';

class LogOutBody extends StatefulWidget {
  const LogOutBody({super.key});

  @override
  State<LogOutBody> createState() => _LogOutBodyState();
}

class _LogOutBodyState extends State<LogOutBody> {

  // ✅ De la version 2 : indicateur de chargement pendant le logout
  bool _isLoggingOut = false;

  // ✅ De la version 1 : séparation propre — dialog retourne bool
  Future<bool> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            // ✅ Bug corrigé de la version 2
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ANNULER',
                style: TextStyle(color: kPrimaryColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('OUI',
                style: TextStyle(color: kPrimaryColor)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ✅ De la version 1 : logique de logout séparée du dialog
  Future<void> _handleLogout() async {
    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    // ✅ De la version 2 : indicateur de chargement
    setState(() => _isLoggingOut = true);

    try {
      final userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      await userProvider.logout();
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }

    if (!mounted) return;

    // Supprime tout l'historique — impossible de revenir en arrière
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CoverPage()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PageIconTemplate(iconData: Icons.logout),
            const SizeboxTemplate(),
            SizedBox(
              height: 60,
              width: 170,
              child: ElevatedButton(
                // Désactivé pendant le logout
                onPressed: _isLoggingOut ? null : _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                // ✅ De la version 2 : spinner pendant le logout
                child: _isLoggingOut
                    ? const CircularProgressIndicator(
                  color: kSecondColor,
                  strokeWidth: 2,
                )
                    : const Text(
                  'Se déconnecter',
                  style: TextStyle(color: kSecondColor, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}