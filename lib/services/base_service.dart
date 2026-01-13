// Fichier: lib/services/base_service.dart

import 'dart:async';
import 'dart:convert';  // Pour jsonEncode/jsonDecode
import 'dart:io';       // Pour SocketException
import 'package:http/http.dart' as http;
import '../config/network_config.dart';  // Package HTTP

/*
 * SERVICE DE BASE POUR LES APPELS HTTP
 * Cette classe fournit des méthodes génériques pour:
 * - GET: Récupérer des données
 * - POST: Envoyer des données
 * - Gérer les erreurs réseau
 * - Gérer les réponses HTTP
 */
class BaseService {
  final String endpoint;  // Endpoint spécifique (ex: 'api/users')
  final Map<String, String>? customHeaders;  // Headers personnalisés

  BaseService({required this.endpoint, this.customHeaders});

  /// ============ SECTION 1: MÉTHODE GET ============
  /// Effectue une requête GET vers l'endpoint configuré
  Future<dynamic> get({Map<String, String>? queryParams}) async {
    try {
      // 1. Construction de l'URL avec paramètres de requête
      final uri = Uri.parse('${NetworkConfig.apiBaseUrl}/$endpoint')
          .replace(queryParameters: queryParams);

      // 2. Log pour débogage
      print('🌐 [GET] Requête vers: $uri');
      if (queryParams != null) {
        print('📋 Paramètres: $queryParams');
      }

      // 3. Exécution de la requête avec timeout
      final response = await http.get(
        uri,
        headers: {...NetworkConfig.defaultHeaders, ...?customHeaders},
      ).timeout(NetworkConfig.connectTimeout);

      // 4. Traitement de la réponse
      return _handleResponse(response);

    } on SocketException {
      // Erreur: Pas de connexion Internet
      print('❌ [GET] Pas de connexion Internet');
      throw Exception('Vérifiez votre connexion Internet et réessayez.');

    } on http.ClientException catch (e) {
      // Erreur: Problème de connexion au serveur
      print('❌ [GET] Erreur client HTTP: $e');
      throw Exception('Impossible de se connecter au serveur. Vérifiez que Spring Boot est démarré.');

    } on TimeoutException {
      // Erreur: Délai dépassé
      print('❌ [GET] Timeout après ${NetworkConfig.connectTimeout.inSeconds}s');
      throw Exception('Le serveur met trop de temps à répondre. Vérifiez votre connexion.');

    } catch (e) {
      // Erreur inattendue
      print('❌ [GET] Erreur inattendue: $e');
      throw Exception('Une erreur inattendue s\'est produite: ${e.toString()}');
    }
  }

  /// ============ SECTION 2: MÉTHODE POST ============
  /// Effectue une requête POST avec des données
  Future<dynamic> post(Map<String, dynamic> data) async {
    try {
      // 1. Construction de l'URL
      final uri = Uri.parse('${NetworkConfig.apiBaseUrl}/$endpoint');

      // 2. Log pour débogage
      print('🌐 [POST] Requête vers: $uri');
      print('📦 Données envoyées: ${jsonEncode(data)}');

      // 3. Exécution de la requête
      final response = await http.post(
        uri,
        headers: {...NetworkConfig.defaultHeaders, ...?customHeaders},
        body: jsonEncode(data),  // Conversion des données en JSON
      ).timeout(NetworkConfig.connectTimeout);

      // 4. Traitement de la réponse
      return _handleResponse(response);

    } on SocketException {
      print('❌ [POST] Pas de connexion Internet');
      throw Exception('Vérifiez votre connexion Internet.');
    } on http.ClientException catch (e) {
      print('❌ [POST] Erreur client HTTP: $e');
      throw Exception('Impossible de se connecter au serveur.');
    } on TimeoutException {
      print('❌ [POST] Timeout');
      throw Exception('Délai d\'attente dépassé.');
    } catch (e) {
      print('❌ [POST] Erreur inattendue: $e');
      throw Exception('Erreur: ${e.toString()}');
    }
  }

  /// ============ SECTION 3: GESTION CENTRALISÉE DES RÉPONSES ============
  /// Traite les réponses HTTP selon leur code de statut
  dynamic _handleResponse(http.Response response) {
    // Log de la réponse
    print('📥 [${response.statusCode}] Réponse reçue');
    if (response.body.isNotEmpty) {
      print('📄 Corps de la réponse: ${response.body}');
    }

    // Traitement selon le code HTTP
    switch (response.statusCode) {
      case 200:  // OK - Requête réussie
      case 201:  // Created - Ressource créée
        if (response.body.isEmpty) {
          return null;  // Pas de données dans la réponse
        }
        try {
          return jsonDecode(response.body);  // Conversion JSON -> Dart
        } catch (e) {
          print('⚠️ Erreur de parsing JSON: $e');
          throw Exception('Format de réponse invalide');
        }

      case 400:  // Bad Request - Requête mal formée
        throw Exception('Requête invalide: ${response.body}');

      case 401:  // Unauthorized - Non authentifié
        throw Exception('Veuillez vous reconnecter');

      case 403:  // Forbidden - Pas les permissions
        throw Exception('Accès non autorisé');

      case 404:  // Not Found - Ressource inexistante
        throw Exception('Ressource non trouvée: ${response.request?.url}');

      case 500:  // Internal Server Error
        throw Exception('Erreur serveur. Veuillez réessayer plus tard.');

      default:
      // Code HTTP non géré
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
  }
}