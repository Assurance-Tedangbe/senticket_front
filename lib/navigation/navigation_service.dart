// lib/core/navigation/navigation_service.dart

import 'package:flutter/material.dart';

/// Service de navigation global.
///
/// Permet de naviguer depuis n'importe où dans l'app
/// sans avoir besoin d'un BuildContext — indispensable
/// pour gérer le 401 dans AuthHttpClient qui n'a pas
/// accès au contexte Flutter.
///
/// Utilisation :
///   // Dans main.dart (déjà branché via navigatorKey)
///   MaterialApp(navigatorKey: NavigationService.navigatorKey)
///
///   // Depuis AuthHttpClient (onUnauthorized)
///   NavigationService.goToLogin();
class NavigationService {

  // Clé globale unique partagée entre MaterialApp et ce service
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  /// Redirige vers la page de login en supprimant tout l'historique.
  /// Appelé automatiquement par AuthHttpClient quand le serveur
  /// retourne 401 (token expiré ou invalide).
  static void goToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
          (_) => false, // supprime tout l'historique de navigation
    );
  }

  /// Redirige vers la page de couverture (déconnexion complète).
  static void goToCover() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/cover',
          (_) => false,
    );
  }

  /// Navigue vers l'interface correspondant au rôle.
  /// Utilisé par :
  ///   - _onLoginSuccess() dans login.body.dart (après login)
  ///   - restoreSession() dans user_provider.dart (après restauration)
  static void goToRoleInterface(String? role) {
    if (role == null) {
      goToCover();
      return;
    }

    switch (role.toUpperCase()) {
      case 'ETUDIANT':
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/student', (_) => false,
        );
        break;
      case 'ADMIN':
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/admin', (_) => false,
        );
        break;
      case 'PORTIER':
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/porter', (_) => false,
        );
        break;
      default:
        goToCover();
    }
  }
}