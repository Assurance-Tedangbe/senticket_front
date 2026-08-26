import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:senticket_front/config/network_config.dart';
import 'package:senticket_front/model/role_model.dart';
import 'package:senticket_front/model/user_model.dart';
import 'package:senticket_front/http/auth_http_client.dart';
import 'package:senticket_front/services/token_storage_service.dart';

import '../navigation/navigation_service.dart';

/*- Service combiné qui gère :
  - Appels HTTP vers l'API Spring Boot: handles all communication with the API
  - Cache simple des données
  - Logique métier légère
  - Transformation des données */
class UserApiService {
  final baseUrl = '${NetworkConfig.baseUrl}/api/users';
  final authUrl =
      '${NetworkConfig.baseUrl}/api/auth'; // URL pour l'authentification

  // ✅ onUnauthorized branché sur NavigationService.goToLogin()
  // Quand le backend retourne 401 (token expiré/invalide) :
  //   1. AuthHttpClient efface le token local
  //   2. Appelle ce callback
  //   3. NavigationService redirige vers /login sans BuildContext
  final AuthHttpClient _authClient = AuthHttpClient(
    onUnauthorized: () => NavigationService.goToLogin(),
  );

  /*// Client authentifié pour les routes protégées
  final AuthHttpClient _authClient = AuthHttpClient();*/

  // Configure HTTP headers for all requests (sans Authorization — le client l'ajoute automatiquement)
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',  // Tells the server "I'm sending JSON"
    'Accept': 'application/json',        // Tells the server "I want to receive JSON"
  };

  final _tokenStorage = TokenStorageService();

  // CACHE SIMPLE INTÉGRÉ
  List<User> _cachedUsers = []; // Cache des utilisateurs
  DateTime? _lastFetchTime; // Dernière récupération
  static const Duration cacheDuration = Duration(minutes: 5); // Durée de cache

  // ************ INSCRIPTION (public — pas de token)(POST /api/users) **************
  Future<User> createUser(User user) async {
    try {
      print('Envoi de la requête POST pour créer un utilisateur');

      // http.post direct car endpoint public (pas d'auth nécessaire)
      final response = await http.post(
        // sending a POST request:
        Uri.parse(baseUrl), // Converts the URL string to a Uri object
        headers: _jsonHeaders, // Uses the configured headers
        body: json.encode(user.toJson()), // Converts User object → JSON string
      );

      if (response.statusCode == 201) {
        // Si le corps de réponse est vide (null)
        if (response.body.isEmpty) {
          print('⚠️ API a répondu avec un corps vide (null)');
          // Retournez l'utilisateur envoyé avec un ID par défaut
          return User(
            userId: 0, // ID temporaire
            firstName: user.firstName,
            lastName: user.lastName,
            username: user.username,
            email: user.email,
            password: user.password,
            role: user.role,
          );
        }

        try {
          final Map<String, dynamic> newUser = json.decode(
            response.body,
          ); // Converts the JSON response → User object

          print('✅ JSON parsé avec succès: $newUser');

          _cachedUsers.add(User.fromJson(newUser));

          return User.fromJson(newUser);
        } catch (e) {
          print(' Erreur de parsing JSON: $e');
          // Fallback : retournez l'utilisateur original
          return user;
        }
      } else {
        print(' Statut HTTP non attendu: ${response.statusCode}');
        throw Exception(
          'Erreur création utilisateur - Code HTTP: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // ****************** LOGIN (public — génère & sauvegarde le token)(POST /api/auth/login) **********************
  Future<User> login(String username, String password) async {
    try {
      print('Connexion pour: $username');

      // http.post direct car endpoint public
      final response = await http.post(
        Uri.parse('$authUrl/login'),
        headers: _jsonHeaders,
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Ajustez selon la réponse de votre API

        // Cas 1: Format standard avec userId à la racine
        if (responseData.containsKey('userId')) {
          final user = User.fromJson(responseData);
          print('✅ CAS 1: ${user.role.name}');
          print('✅ Connexion réussie, utilisateur: ${user.username}');
          return user;
        }
        // Si votre API retourne un token et des infos utilisateur séparément
        // Cas 2: Format avec token et user séparé
        // Format attendu du backend : { token, success, user: { id, username, roleDTO: { name } } }
        else if (responseData.containsKey('token') &&
            responseData.containsKey('user')) {
          final token = responseData['token'] as String;
          final userData = responseData['user'] as Map<String, dynamic>;
          final user = User.fromJson(userData);
          print('✅ CAS 2: ${user.role.name}');
          // Vous pourriez stocker le token pour les futures requêtes
          // _saveToken(token);

          //  // ✅ SAUVEGARDER LE TOKEN — c'est le cœur du système JWT
          // Toutes les requêtes suivantes l'auront automatiquement
          /*await TokenStorageService.instance.saveToken(token);
          await TokenStorageService.instance.saveUserInfo*/
          await _tokenStorage.saveToken(token);
          await _tokenStorage.saveUserSession(
            userId: user.userId?.toString() ?? '',
            username: user.username,
            role: user.role.name,
          );

          print('Connexion réussie avec token, Token sauvegardé pour: ${user.username} (${user.role.name})');
          return user;
        }
        // Cas 3: Format spécifique de mon API
        else if (responseData.containsKey('user') &&
            responseData['user'] is Map<String, dynamic>) {
          print('✅ CAS 3');
          print('✅ Format de réponse détecté (avec objet user)');

          final userData = responseData['user'] as Map<String, dynamic>;
          print(' userData : $userData');
          print(' responseData : $responseData');

          return User.fromJson(userData);
        }
        // Cas 4: Autres formats: Si votre API a un format différent
        else {
          print(
            '⚠️ Format de réponse non reconnu, extraction des données disponibles',
          );

          final user = User(
            userId:
                responseData['id'] ??
                responseData['userId'] ??
                (responseData['user'] != null
                    ? (responseData['user'] as Map)['userId']
                    : null) ??
                0,
            username:
                responseData['username'] ??
                (responseData['user'] != null
                    ? (responseData['user'] as Map)['username']
                    : null) ??
                username,
            email:
                responseData['email'] ??
                (responseData['user'] != null
                    ? (responseData['user'] as Map)['email']
                    : null) ??
                '',
            firstName:
                responseData['firstName'] ??
                responseData['firstname'] ??
                (responseData['user'] != null
                    ? (responseData['user'] as Map)['firstName']
                    : null) ??
                '',
            lastName:
                responseData['lastName'] ??
                responseData['lastname'] ??
                (responseData['user'] != null
                    ? (responseData['user'] as Map)['lastName']
                    : null) ??
                '',
            password: '',
            role: Role(
              roleId:
                  responseData['roleId'] ??
                  responseData['roleID'] ??
                  (responseData['role'] != null
                      ? (responseData['role'] as Map)['roleId']
                      : null) ??
                  (responseData['user'] != null
                      ? (responseData['user'] as Map)['roleID']
                      : null) ??
                  0,
              name:
                  responseData['role']?['name'] ??
                  responseData['name'] ??
                  (responseData['user'] != null
                      ? (responseData['user'] as Map)['name']
                      : null) ??
                  '',
            ),
          );

          return user;
        }
      } else if (response.statusCode == 401) {
        throw Exception('Identifiants incorrects');
      } else if (response.statusCode == 404) {
        throw Exception('Utilisateur non trouvé');
      } else {
        throw Exception('Erreur de connexion: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      rethrow;
    }
  }

  // ************ LOGOUT — protégé + nettoyage local **************
  Future<void> logout() async {
    try {
      // Informer le serveur (token ajouté automatiquement par _authClient)
      // Si 401 → onUnauthorized → goToLogin() (peu probable ici mais géré)
      await _authClient.post(
        Uri.parse('$authUrl/logout'),
        headers: _jsonHeaders,
      );
    } catch (e) {
      // Échec serveur ignoré — le vrai logout est local
      print('[UserApiService] Erreur logout serveur (ignorée): $e');
    } finally {
      // Le vrai logout : supprimer le token localement
      // Nettoyage local garanti quoi qu'il arrive
      await _tokenStorage.clearAll() /* TokenStorageService.instance.clearAll() */;
      _cachedUsers.clear();
      _lastFetchTime = null;
      print('Token supprimé — utilisateur déconnecté');
    }
  }

  // READ ALL USERS (GET /api/users) (protégé)
  // Uses caching to avoid unnecessary API calls
  Future<List<User>> getAllUsers({bool forceRefresh = false}) async {
    // Checks if the cache is still valid
    final now = DateTime.now();

    final cacheValide =
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < cacheDuration;

    // Returns the cache if valid and not forced
    if (!forceRefresh && cacheValide && _cachedUsers.isNotEmpty) {
      print('Cache valide: ${_cachedUsers.length} utilisateurs');
      return _cachedUsers;
    }

    try {
      print("Retrieving users from the API");
      // _authClient ajoute Authorization: Bearer <token> automatiquement
      // Si token expiré → 401 → onUnauthorized → goToLogin()
      final response = await _authClient.get(
        Uri.parse(baseUrl),
        headers: _jsonHeaders,
      );

      if (response.statusCode == 200) {
        // the JSON response → a list of User objects

        final List<dynamic> jsonList = json.decode(
          response.body,
        ); // JSON string  → List of Dart objects

        _cachedUsers = jsonList
            .map((json) => User.fromJson(json))
            .toList(); // Transforms each JSON object → User object"

        _lastFetchTime = DateTime.now(); // Timestamp update

        print(" ${_cachedUsers.length} utilisateurs récupérés");

        return _cachedUsers;
      } else {
        throw Exception(
          'Erreur récupération utilisateurs: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("Erreur récupération: $e");

      // Fallback: retourne le cache même expiré si pas de réseau
      if (_cachedUsers.isNotEmpty) {
        print("Retourne cache expiré en fallback");
        return _cachedUsers;
      }

      throw Exception('Erreur réseau: $e');
    }
  }

  // READ USER BY ID (GET /api/users/{userId}) (protégé)
  Future<User> getUserById(int userId) async {
    try {
      print("Retrieving user with ID: $userId");

      // Recherche d'abord dans le cache local pour éviter un appel API inutile
      final cachedUser = _cachedUsers.firstWhere(
        // Condition de recherche : cherche un utilisateur avec l'ID correspondant
        (user) => user.userId == userId,

        // Si aucun utilisateur n'est trouvé dans le cache, retourne un utilisateur "vide" avec userId = -1
        orElse: () => User(
          userId:
              -1, // Marqueur "non trouvé" - valeur spéciale pour indiquer l'absence
          username: '',
          password: '',
          email: '',
          firstName: '',
          lastName: '',
          role: Role(name: ''),
        ),
      );

      // Vérifie si l'utilisateur a été trouvé dans le cache
      // cachedUser.userId != -1 signifie qu'on a trouvé un utilisateur valide dans le cache
      if (cachedUser.userId != -1) {
        print(" User $userId found in cache");
        // Retourne l'utilisateur du cache sans faire d'appel API
        return cachedUser;
      }

      // Si l'utilisateur n'est pas dans le cache, on fait un appel API protégé pour le récupérer depuis le serveur
      final response = await _authClient.get(
        Uri.parse('$baseUrl/$userId'),
        headers: _jsonHeaders, // Utilise les headers configurés (Content-Type, Accept, etc.)
      );

      // Vérifie le code de statut HTTP de la réponse
      if (response.statusCode == 200) {
        // Décode le corps de la réponse JSON en objet Dart
        final user = User.fromJson(json.decode(response.body));

        print("Utilisateur récupéré: ${user.username}");

        // Retourne l'utilisateur récupéré depuis l'API
        return user;
      } else if (response.statusCode == 404) {
        throw Exception('Utilisateur non trouvé');
      } else {
        throw Exception(
          'Erreur récupération utilisateur: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Bloc catch qui capture toutes les exceptions pouvant survenir
      print("Erreur récupération par ID: $e");

      // Relance une exception avec un message générique
      throw Exception('Erreur réseau: $e');
    }
  }

  // READ USER BY USERNAME (GET /api/users/username/{username}) (protégé)
  // without cahe
  Future<User> getUserByUsername(String username) async {
    try {
      print("getUserByUsername: $username");

      final response = await _authClient.get(
        Uri.parse('$baseUrl/username/$username'),
        headers: _jsonHeaders,
      );

      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);

        print(
          "Utilisateur trouvé: ${userData['username']} (Rôle: ${userData['role']?['name']})",
        );
        return User.fromJson(userData);
      } else if (response.statusCode == 404) {
        throw Exception('Utilisateur non trouvé');
      } else {
        throw Exception(
          'Erreur récupération utilisateur(serveur): ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // UPDATE USER (PUT /api/users/{userId}) (protégé)
  Future<User> updateUser(User user) async {
    try {
      print("Update user with ID: ${user.userId}");

      final response = await _authClient.put(
        Uri.parse('$baseUrl/${user.userId}'),
        headers: _jsonHeaders,
        body: json.encode(user.toJson()), // Sends the new data"
      );

      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(json.decode(response.body));
        print(" User updated: ${updatedUser.username}");

        // Updates the cache
        final index = _cachedUsers.indexWhere((u) => u.userId == user.userId);
        if (index != -1) { _cachedUsers[index] = updatedUser;}
        print('✅ User mis à jour: ${updatedUser.username}');
        return updatedUser;
      } else {
        throw Exception(
          'Erreur mise à jour utilisateur: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("Erreur mise à jour: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // DELETE USER (DELETE /api/users/{userId}) (protégé)
  Future<void> deleteUser(int userId) async {
    try {
      print("Deleting user with ID: $userId");

      // ✅ Appel protégé
      final response = await _authClient.delete(
        Uri.parse('$baseUrl/$userId'),
        headers: _jsonHeaders,
      );

      if (response.statusCode == 204) {
        print("User deleted with ID: $userId");
        // Updates the cache
        _cachedUsers.removeWhere((user) => user.userId == userId);
      } else {
        throw Exception(
          'Erreur suppression utilisateur: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("Erreur suppression: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // Basic validation of user data
  void validateUserData(User user) {
    if (user.username.length < 3) {throw Exception('Nom d\'utilisateur trop court (min 3 caractères)');}
    if (user.username.length > 70) {throw Exception('Nom d\'utilisateur trop long (max 70 caractères)');}
    if (user.password.length < 6) {throw Exception('Mot de passe trop court (min 6 caractères)');}
    if (!user.email.contains('@')) {throw Exception('Email invalide');}
  }

  // UPDATE PASSWORD (PUT /api/users/password/{userId}) (protegé)
  // without cahe
  Future<void> updatePassword(int userId, String newPassword) async {
    try {
      final response = await _authClient.put(
        Uri.parse('$baseUrl/password/$userId'),
        headers: _jsonHeaders,
        body: json.encode(
          newPassword,
        ), // Sends only the new password (not the entire User object)"
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Erreur mise à jour mot de passe: ${response.statusCode}',
        );
      }
      print("Password updated for user with ID: $userId");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
