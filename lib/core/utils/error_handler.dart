import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'dart:convert';

/// Convertit les exceptions réseau et les codes HTTP
/// en messages lisibles pour l'utilisateur final.
class ErrorHandler {

  /// Traite une réponse HTTP et retourne un message d'erreur
  /// si le statut n'est pas dans les 2xx.
  /// Retourne null si la réponse est un succès (2xx).
  static String? fromResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return null;

    // Essayer de lire le message d'erreur du backend
    String? backendMessage;
    try {
      final body = json.decode(response.body);
      backendMessage = body['message'] as String?
          ?? body['error'] as String?;
    } catch (_) {}

    switch (response.statusCode) {
      case 400:
        if (backendMessage != null) {
          if (backendMessage.contains('password') ||
              backendMessage.contains('Invalid password')) {
            return 'Mot de passe incorrect';
          }
          if (backendMessage.contains('enough tickets') ||
              backendMessage.contains('Available')) {
            return 'Vous n\'avez pas assez de tickets de ce type';
          }
          return backendMessage;
        }
        return 'Données invalides. Vérifiez vos informations.';
      case 401:
        return 'Session expirée. Veuillez vous reconnecter.';
      case 403:
        return 'Vous n\'avez pas les droits pour cette action.';
      case 404:
        return backendMessage ?? 'Ressource introuvable.';
      case 409:
        return backendMessage ?? 'Ce nom d\'utilisateur ou email est déjà utilisé.';
      case 422:
        return backendMessage ?? 'Opération impossible avec ces données.';
      case 500:
        return 'Erreur serveur. Réessayez dans quelques instants.';
      case 503:
        return 'Service temporairement indisponible.';
      default:
        return 'Erreur inattendue (${response.statusCode}).';
    }
  }

  /// Traite une exception Flutter/Dart en message lisible
  static String fromException(Object e) {
    if (e is SocketException) {
      return 'Pas de connexion internet. '
          'Vérifiez votre réseau et réessayez.';
    }
    if (e is TimeoutException) {
      return 'Le serveur met trop de temps à répondre. '
          'Vérifiez votre connexion.';
    }
    if (e is FormatException) {
      return 'Réponse serveur invalide. Contactez le support.';
    }
    if (e is HandshakeException) {
      return 'Connexion sécurisée impossible. '
          'Vérifiez votre réseau.';
    }

    final message = e.toString();

    // Nettoyer les messages Exception("...") bruts
    if (message.startsWith('Exception:')) {
      final cleaned = message.replaceFirst('Exception: ', '').trim();

      // Traductions des messages backend connus
      final translations = {
        'Identifiants incorrects': 'Nom d\'utilisateur ou mot de passe incorrect.',
        'Utilisateur non trouvé': 'Aucun compte trouvé avec ce nom d\'utilisateur.',
        'Mot de passe incorrect': 'Le mot de passe saisi est incorrect.',
        'Token invalide': 'Session expirée. Veuillez vous reconnecter.',
        'Ticket non disponible': 'Ce ticket n\'est plus disponible.',
        'Ticket déjà débité': 'Ce ticket a déjà été utilisé.',
        'Solde insuffisant': 'Vous n\'avez pas assez de tickets de ce type.',
        'Invalid password': 'Mot de passe incorrect.',
        'enough tickets': 'Vous n\'avez pas assez de tickets de ce type.',
      };

      for (final entry in translations.entries) {
        if (cleaned.contains(entry.key)) return entry.value;
      }

      return cleaned;
    }

    return 'Une erreur inattendue s\'est produite.';
  }
}