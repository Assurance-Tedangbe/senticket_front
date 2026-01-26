import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:senticket_front/config/network_config.dart';
import 'package:senticket_front/model/role_model.dart';
import 'package:senticket_front/model/user_model.dart';

/*- Service combiné qui gère :
  - Appels HTTP vers l'API Spring Boot: handles all communication with the API
  - Cache simple des données
  - Logique métier légère
  - Transformation des données */
class UserApiService {
  final baseUrl = '${NetworkConfig.baseUrl}/api/users';
  final authUrl =
      '${NetworkConfig.baseUrl}/api/auth'; // URL pour l'authentification

  // Configure HTTP headers for all requests
  static final Map<String, String> headers = {
    'Content-Type': 'application/json', // Tells the server "I'm sending JSON"
    'Accept': 'application/json', // Tells the server "I want to receive JSON"
  };

  // === CACHE SIMPLE INTÉGRÉ ===
  List<User> _cachedUsers = []; // Cache des utilisateurs
  DateTime? _lastFetchTime; // Dernière récupération
  static const Duration cacheDuration = Duration(minutes: 5); // Durée de cache

  // -------------------------
  // 1. CREATE USER (POST /api/users)
  // -------------------------
  Future<User> createUser(User user) async {
    // I will create a user via POST /api/users and return the created user"
    try {
      print('📤 Envoi de la requête POST pour créer un utilisateur');
      // print('📤 Body: ${json.encode(user.toJson())}');

      final response = await http.post(
        // I'm trying to send a POST request:
        Uri.parse(baseUrl), // Converts the URL string to a Uri object
        headers: headers, // Uses the configured headers
        body: json.encode(user.toJson()), // Converts User object → JSON string
      );

      /*print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Headers: ${response.headers}');
      print('📥 Response Body (RAW): ${response.body}');
      print('📥 Response Body Length: ${response.body.length}');*/

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
          // Essayez de parser le JSON
          final Map<String, dynamic> newUser = json.decode(
            response.body,
          ); // Converts the JSON response → User object

          print('✅ JSON parsé avec succès: $newUser');

          _cachedUsers.add(User.fromJson(newUser));

          return User.fromJson(newUser);
        } catch (e) {
          print('❌ Erreur de parsing JSON: $e');
          // Fallback : retournez l'utilisateur original
          return user;
        }
      } else {
        print('❌ Statut HTTP non attendu: ${response.statusCode}');
        throw Exception(
          'Erreur création utilisateur - Code HTTP: ${response.statusCode}',
        );
      }
    } catch (e) {
      //  print("❌ Erreur création: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // LOGIN USER (POST /api/auth/login)
  Future<User> login(String username, String password) async {
    try {
      print('🔐 Tentative de connexion pour: $username');

      final response = await http.post(
        Uri.parse('$authUrl/login'), // ⭐ Ajustez l'URL selon votre API
        headers: headers,
        body: json.encode({'username': username, 'password': password}),
      );

      /*  print('📥 Login Response Status: ${response.statusCode}');
          print('📥 Login Response Body: ${response.body}');
          print('📥 Response Headers: ${response.headers}');
          print('📥 Response Body Length: ${response.body.length}'); */

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Ajustez selon la réponse de votre API
        // Si votre API retourne directement un objet User

        // Cas 1: Format standard avec userId à la racine
        if (responseData.containsKey('userId')) {
          final user = User.fromJson(responseData);
          print('✅ CAS 1: ${user.role.name}');
          print('✅ Connexion réussie, utilisateur: ${user.username}');
          return user;
        }
        // Si votre API retourne un token et des infos utilisateur séparément
        // Cas 2: Format avec token et user séparé
        else if (responseData.containsKey('token') &&
            responseData.containsKey('user')) {
          final token = responseData['token'] as String;
          final userData = responseData['user'] as Map<String, dynamic>;
          final user = User.fromJson(userData);
          print('✅ CAS 2: ${user.role.name}');
          // Vous pourriez stocker le token pour les futures requêtes
          // _saveToken(token);

          print(
            '✅ Connexion réussie avec token, utilisateur: ${user.username}',
          );
          return user;
        }
        // Cas 3: Format spécifique de mon API
        else if (responseData.containsKey('user') &&
            responseData['user'] is Map<String, dynamic>) {
          print('✅ CAS 3');
          print('✅ Format de réponse détecté (avec objet user)');

          final userData = responseData['user'] as Map<String, dynamic>;
          print('📋 userData contenu: $userData');
          print('📋 responseData contenu: $responseData');

          /* final userData = responseData['user'] as Map<String, dynamic>;

          // DEBUG: Afficher ce que contient userData
          print('📋 userData contenu: $userData');
          print('📋 responseData contenu: $responseData');
          print('📋 userData keys: ${userData.keys}');
          print('📋 userData[roleID]: ${userData['roleId']}');
          print('📋 userData[name]: ${userData['name']}');

          // Construire le rôle d'abord pour vérifier
          final role = Role(
            roleId: (userData['roleId'] ?? userData['roleId'] ?? 0).toInt(),
            name: userData['name']?.toString() ?? '',
          );

          print('🛠 Role construit: id=${role.roleId}, name=${role.name}');

          // Extraction des données depuis l'objet 'user'
          final user = User(
            userId: userData['userId'] ?? 0,
            username: userData['username'] ?? username,
            email: userData['email'] ?? '',
            firstName: responseData['firstName'] ?? userData['firstName'] ?? '',
            lastName: responseData['lastName'] ?? userData['lastName'] ?? '',
            password:
                responseData['password'] ??
                userData['password'] ??
                '', // Ne pas stocker le mot de passe
            role: Role(
              roleId: responseData['roleDTO']['roleId'] ?? 0,
              name: responseData['roleDTO']['name'] ?? '',
            ),
            /*  role: Role(
              roleId: userData['roleId'] ?? userData['roleId'] ?? 0,
              name: userData['name'] ?? '',
            ), */
          );

          print('✅ user connecté: ${user.username}');
          print('ID: ${user.userId}');
          print('Email: ${user.email}');
          print('firstname: ${user.firstName}');
          print('lastname: ${user.lastName}');
          print('password: ${user.password}');
          print('Rôle name: ${user.role.name}');
          print('Rôle id: ${user.role.roleId}');

          return user; */

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

  // ⭐ NOUVEAU : Méthode pour obtenir les headers avec authentification
  Future<Map<String, String>> getAuthHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Si vous avez un token, l'ajouter aux headers
    // final token = await _getToken();
    // if (token != null) {
    //   headers['Authorization'] = 'Bearer $token';
    // }

    return headers;
  }

  // -------------------------
  // 2. READ ALL USERS (GET /api/users)
  // -------------------------
  // Uses caching to avoid unnecessary API calls
  Future<List<User>> getAllUsers({bool forceRefresh = false}) async {
    // Checks if the cache is still valid
    final now = DateTime.now();

    final cacheValide =
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < cacheDuration;

    // Returns the cache if valid and not forced
    if (!forceRefresh && cacheValide && _cachedUsers.isNotEmpty) {
      print("Retourne ${_cachedUsers.length} utilisateurs depuis le cache");

      return _cachedUsers;
    }

    try {
      print("Retrieving users from the API");

      final response = await http.get(Uri.parse(baseUrl), headers: headers);

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

  // -------------------------
  // 3. READ USER BY ID (GET /api/users/{userId})
  // -------------------------

  // Déclaration d'une méthode asynchrone qui retourne un objet User
  Future<User> getUserById(int userId) async {
    try {
      print("Retrieving user ID: $userId");

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
        print("📦 User found in cache");
        // Retourne l'utilisateur du cache sans faire d'appel API
        return cachedUser;
      }

      // Si l'utilisateur n'est pas dans le cache, on fait un appel API
      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers:
            headers, // Utilise les headers configurés (Content-Type, Accept, etc.)
      ); // GET /api/users/{userId} to retrieve a specific user"

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

  // -------------------------
  // 4. READ USER BY USERNAME (GET /api/users/username/{username})
  // without cahe
  // -------------------------
  Future<User> getUserByUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/username/$username'),
        headers: headers,
      ); // GET /api/users/username/{username} to find a user by username"

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return User.fromJson(userData);
        /*  return User.fromJson(json.decode(response.body)); */
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

  // -------------------------
  // 5. UPDATE USER (PUT /api/users/{userId})
  // -------------------------
  Future<User> updateUser(User user) async {
    try {
      print("Update user with ID: ${user.userId}");

      final response = await http.put(
        Uri.parse('$baseUrl/${user.userId}'),
        headers: headers,
        body: json.encode(user.toJson()), // Sends the new data"
      ); // PUT /api/users/{userId} to modify an existing user

      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(json.decode(response.body));
        print(" User updated: ${updatedUser.username}");

        // Updates the cache
        final index = _cachedUsers.indexWhere((u) => u.userId == user.userId);
        if (index != -1) {
          _cachedUsers[index] = updatedUser;
        }

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

  // -------------------------
  // 6. UPDATE PASSWORD (PUT /api/users/password/{userId})
  // without cahe
  // -------------------------
  Future<void> updatePassword(int userId, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/password/$userId'),
        headers: headers,
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

  // -------------------------
  // 7. DELETE USER (DELETE /api/users/{userId})
  // -------------------------
  Future<void> deleteUser(int userId) async {
    try {
      print("Deleting user with ID: $userId");

      final response = await http.delete(
        Uri.parse('$baseUrl/$userId'),
        headers: headers,
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

  // -------------------------
  // 8. ADD ROLE TO USER (PUT /api/users/{userId}/roles/{roleId})
  // without cahe
  // -------------------------
  Future<void> addRoleToUser(int userId, int roleId) async {
    print("Add role : $roleId to user : $userId");

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$userId/roles/$roleId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur ajout rôle: ${response.statusCode}');
      }

      print("Rôle $roleId ajouté à l'utilisateur $userId");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 9. REMOVE ROLE FROM USER (DELETE /api/users/{userId}/roles/{roleId})
  // without cahe
  // -------------------------
  Future<void> removeRoleFromUser(int userId, int roleId) async {
    print("Remove role : $roleId from user : $userId");
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$userId/roles/$roleId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur retrait rôle: ${response.statusCode}');
      }

      print("✅ Rôle $roleId retiré de l'utilisateur $userId");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Searching for users in the local cache
  List<User> searchUsers(String query) {
    print("searching for users with query: $query");

    if (query.isEmpty) return _cachedUsers;

    final queryLower = query.toLowerCase();

    return _cachedUsers
        .where(
          (user) =>
              user.username.toLowerCase().contains(queryLower) ||
              user.email.toLowerCase().contains(queryLower) ||
              user.firstName.toLowerCase().contains(queryLower) ||
              user.lastName.toLowerCase().contains(queryLower) ||
              user.role.name.toLowerCase().contains(queryLower),
        )
        .toList();
  }

  // Basic validation of user data
  void validateUserData(User user) {
    if (user.username.length < 3) {
      throw Exception(
        'Le nom d\'utilisateur doit contenir au moins 3 caractères',
      );
    }

    // Validation de la longueur maximale (comme @Size(max = 70))
    if (user.username.length > 70) {
      throw Exception(
        'Le nom d\'utilisateur ne peut pas dépasser 70 caractères',
      );
    }

    if (user.password.length < 6) {
      throw Exception('Le mot de passe doit contenir au moins 6 caractères');
    }

    if (!user.email.contains('@')) {
      throw Exception('Email invalide');
    }
  }

  // Clear the cache (useful for forcing a refresh)
  void clearCache() {
    print("Clearing the cache");
    _cachedUsers.clear();
    _lastFetchTime = null;
    print("🗑️ Cache utilisateurs vidé");
  }

  // Dans UserApiService, ajoutez cette méthode pour forcer le rafraîchissement du cache
  void invalidateUserCache(int userId) {
    // Retirer l'utilisateur du cache pour forcer une nouvelle récupération
    _cachedUsers.removeWhere((user) => user.userId == userId);
    print('🗑️ Cache invalidé pour l\'utilisateur ID: $userId');
  }
}

  /* 
   RÉSUMÉ DU PATTERN GÉNÉRAL
   Chaque méthode suit le même schéma :

     static Future<Type> nomMéthode(paramètres) async {
     try {
        1. 🟡 CONSTRUCTION DE LA REQUÊTE
          final response = await http.méthode(
          Uri.parse(url),
          headers: headers,
          body: données?,
         );

        2. 🟢 VÉRIFICATION DE LA RÉPONSE
      if (response.statusCode == codeSuccès) {

        3. ✅ TRANSFORMATION DES DONNÉES
         return transformation(response.body);
         } else {
        4. ❌ ERREUR HTTP
                 throw Exception('Message: ${response.statusCode}');
                }
    
          } catch (e) {
        5. 🔴 ERREUR RÉSEAU
                throw Exception('Erreur réseau: $e');
          }
       }
   */

  /* 
   CONVERSION DES DONNÉES
   Flux de données dans les deux sens :

   VERS L'API (Envoi)
   Objet User Dart → user.toJson() → Map → json.encode() → String JSON → HTTP Body
   
   DEPUIS L'API (Réception)
   HTTP Body → String JSON → json.decode() → Map → User.fromJson() → Objet User Dart

   Ce service est le pont essentiel entre votre app Flutter et votre API Spring Boot ! 🌉
   */

