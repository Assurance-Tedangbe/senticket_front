import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senticket_front/constants.dart';
import 'package:senticket_front/navigation/navigation_service.dart';
import 'package:senticket_front/services/token_storage_service.dart';
import 'package:senticket_front/provider/user_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSession();
    });
  }

  Future<void> _initSession() async {
    try {
      final tokenStorage = TokenStorageService();
      final isLoggedIn = await tokenStorage.isLoggedIn();
      final role = await tokenStorage.getRole();

      if (!mounted) return;

      if (isLoggedIn && role != null) {
        // ✅ restoreSession() est ATTENDUE avant toute navigation
        // Plus de race condition possible
        await Provider.of<UserProvider>(context, listen: false)
            .restoreSession();

        if (!mounted) return;

        // currentUser est maintenant garanti d'être set (ou null si échec)
        final currentUser = Provider.of<UserProvider>(
          context,
          listen: false,
        ).currentUser;

        if (currentUser == null) {
          // restoreSession() a échoué → aller au login
          NavigationService.navigatorKey.currentState
              ?.pushReplacementNamed('/cover');
          return;
        }

        // Naviguer selon le rôle
        _navigateByRole(role);
      } else {
        // Pas de token → écran d'accueil
        NavigationService.navigatorKey.currentState
            ?.pushReplacementNamed('/cover');
      }
    } catch (e) {
      print('[SplashScreen] Erreur: $e');
      if (mounted) {
        NavigationService.navigatorKey.currentState
            ?.pushReplacementNamed('/cover');
      }
    }
  }

  void _navigateByRole(String role) {
    switch (role.toUpperCase()) {
      case 'ETUDIANT':
        NavigationService.navigatorKey.currentState
            ?.pushReplacementNamed('/student');
        break;
      case 'ADMIN':
        NavigationService.navigatorKey.currentState
            ?.pushReplacementNamed('/admin');
        break;
      case 'PORTIER':
        NavigationService.navigatorKey.currentState
            ?.pushReplacementNamed('/porter');
        break;
      default:
        NavigationService.navigatorKey.currentState
            ?.pushReplacementNamed('/cover');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Senticket',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            /*const SizedBox(height: 8),
            Text(
              'Gestion de tickets restaurant',
              style: TextStyle(
                fontSize: 13,
                color: kPrimaryColor.withOpacity(0.7),
              ),
            ),*/
            const SizedBox(height: 48),
            CircularProgressIndicator(
              color: kPrimaryColor,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}