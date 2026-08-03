import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:senticket_front/config/network_config.dart';
import 'package:senticket_front/model/role_model.dart';

class RoleApiService {
  final baseUrl = '${NetworkConfig.baseUrl}/api/roles';

  /// Headers HTTP pour indiquer qu'on travaille avec du JSON
  /// GET /api/roles est public (nécessaire pour l'inscription)
  /// donc on utilise http directement, pas AuthHttpClient
  static const Map<String, String> headers = {
    'Content-Type': 'application/json', // Type de contenu qu'on envoie
    'Accept': 'application/json', // Type de contenu qu'on accepte en retour
  };

  // Cache en mémoire pour stocker la liste des rôles
  List<Role> _cachedRoles = [];
  // Timestamp de la dernière récupération des données
  DateTime? _lastFetchTime;
  // Durée de validité du cache (10 minutes pour les rôles qui changent peu)
  static const Duration cacheDuration = Duration(minutes: 10);

  // === MÉTHODES PRINCIPALES - CORRESPONDANT AUX ENDPOINTS DU CONTROLLER ===

  // *********************** READ ALL ROLES **************************
  Future<List<Role>> getAllRoles({bool forceRefresh = false}) async {
    // Vérification de la validité du cache
    final now = DateTime.now();
    final cacheValide = _lastFetchTime != null && now.difference(_lastFetchTime!) < cacheDuration;

    // Retourne les données du cache si valides et non forcées
    if (!forceRefresh && cacheValide && _cachedRoles.isNotEmpty) {
      print("📦 Retourne ${_cachedRoles.length} rôles depuis le cache");
      return _cachedRoles;
    }

    try {
      print(" Récupération des rôles");

      // Appel HTTP GET vers l'API
      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      print(' Status Code: ${response.statusCode}');
      print(' Response Body : ${response.body}');

      // Vérification du code HTTP 200 (OK) comme dans le Controller
      if (response.statusCode == 200) {
        print(' 200 OK - succès');
        // JSON response → Role object list
        final List<dynamic> jsonList = json.decode(response.body);
        _cachedRoles = jsonList.map((json) => Role.fromJson(json)).toList();
        _lastFetchTime = DateTime.now(); // Mise à jour du timestamp

        print("${_cachedRoles.length} rôles récupérés et mis en cache");
        return _cachedRoles;
      } else {
        throw Exception(
          'Erreur récupération rôles - Code HTTP: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(" Erreur lors de la récupération des rôles: $e");

      // Fallback stratégique : retourne le cache même expiré si pas de réseau
      if (_cachedRoles.isNotEmpty) {
        print(" API inaccessible - Retourne cache expiré en fallback");
        return _cachedRoles;
      }
      throw Exception('Erreur réseau: $e');
    }
  }
}

/* //  SUPPL METHODS not used yet
  // ************************** CREATE ROLE ***************************
  Future<Role> createRole(Role role) async {
    try {
      print(" Création d'un nouveau rôle: ${role.name}");

      // Validation des données avant envoi à l'API
      _validateRoleData(role);

      // Appel HTTP POST vers l'API Spring Boot
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(role.toJson()), // Role → JSON
      );

      // Vérification du code HTTP 201 (Created) comme dans le Controller Spring Boot
      if (response.statusCode == 201) {
        // JSON response → Role object
        final newRole = Role.fromJson(json.decode(response.body));
        print(
          "✅ Rôle créé avec succès - ID: ${newRole.roleId}, Nom: ${newRole.name}",
        );

        // Mise à jour du cache : ajout du nouveau rôle
        _cachedRoles.add(newRole);

        return newRole;
      } else {
        // Gestion des erreurs HTTP
        throw Exception(
          'Erreur création rôle - Code HTTP: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(" Erreur lors de la création du rôle: $e");
      throw Exception('Erreur création rôle: $e');
    }
  }

  // ************************ READ ROLE BY ID **************************
  Future<Role> getRoleById(int roleId) async {
    try {
      print("🔄 Récupération du rôle par ID: $roleId");

      // Recherche d'abord dans le cache local pour optimiser les performances
      final cachedRole = _cachedRoles.firstWhere(
        (role) => role.roleId == roleId,
        orElse: () =>
            Role(roleId: -1, name: ''), // Valeur par défaut si non trouvé
      );

      // Si trouvé dans le cache, retourne immédiatement
      if (cachedRole.roleId != -1) {
        print("📦 Rôle trouvé dans le cache: ${cachedRole.name}");
        return cachedRole;
      }

      // Si pas dans le cache, appel API
      final response = await http.get(
        Uri.parse('$baseUrl/$roleId'), // Endpoint /api/roles/{roleId}
        headers: headers,
      );

      if (response.statusCode == 200) {
        final role = Role.fromJson(json.decode(response.body));
        print("✅ Rôle récupéré depuis l'API: ${role.name}");
        return role;
      } else if (response.statusCode == 404) {
        throw Exception('Rôle non trouvé avec ID: $roleId');
      } else {
        throw Exception(
          'Erreur récupération rôle - Code HTTP: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(" Erreur lors de la récupération du rôle par ID: $e");
      throw Exception('Erreur récupération rôle: $e');
    }
  }

  // ************************ READ ROLE BY NAME **************************
  Future<Role> getRoleByName(String roleName) async {
    try {
      print("🔄 Récupération du rôle par nom: $roleName");

      final response = await http.get(
        Uri.parse(
          '$baseUrl/name/$roleName',
        ), // Endpoint /api/roles/name/{roleName}
        headers: headers,
      );

      if (response.statusCode == 200) {
        final role = Role.fromJson(json.decode(response.body));
        print("✅ Rôle trouvé: ${role.name}");
        return role;
      } else if (response.statusCode == 404) {
        throw Exception('Rôle non trouvé avec nom: $roleName');
      } else {
        throw Exception(
          'Erreur récupération rôle - Code HTTP: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(" Erreur lors de la récupération du rôle par nom: $e");
      throw Exception('Erreur récupération rôle: $e');
    }
  }

  // ************************** UPDATE ROLE ***************************
  Future<Role> updateRole(Role role) async {
    try {
      print("🔄 Mise à jour du rôle ID: ${role.roleId}");

      // Validation des données avant mise à jour
      _validateRoleData(role);

      final response = await http.put(
        Uri.parse('$baseUrl/${role.roleId}'), // Endpoint /api/roles/{roleId}
        headers: headers,
        body: json.encode(role.toJson()), // Données mises à jour
      );

      if (response.statusCode == 200) {
        final updatedRole = Role.fromJson(json.decode(response.body));
        print("✅ Rôle mis à jour avec succès: ${updatedRole.name}");

        // Mise à jour du cache : remplacement du rôle modifié
        final index = _cachedRoles.indexWhere((r) => r.roleId == role.roleId);
        if (index != -1) {
          _cachedRoles[index] = updatedRole;
        }

        return updatedRole;
      } else {
        throw Exception(
          'Erreur mise à jour rôle - Code HTTP: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(" Erreur lors de la mise à jour du rôle: $e");
      throw Exception('Erreur mise à jour rôle: $e');
    }
  }

  // ************************** DELETE ROLE ***************************
  Future<void> deleteRole(int roleId) async {
    try {
      print("🔄 Suppression du rôle ID: $roleId");

      final response = await http.delete(
        Uri.parse('$baseUrl/$roleId'),
        headers: headers,
      );

      // Vérification du code HTTP 204 (No Content) comme dans le Controller
      if (response.statusCode == 204) {
        print("✅ Rôle supprimé avec succès - ID: $roleId");

        // Mise à jour du cache : suppression du rôle
        _cachedRoles.removeWhere((role) => role.roleId == roleId);
      } else {
        throw Exception(
          'Erreur suppression rôle - Code HTTP: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(" Erreur lors de la suppression du rôle: $e");
      throw Exception('Erreur suppression rôle: $e');
    }
  } 

  // === MÉTHODES UTILITAIRES

  /*  Recherche des rôles dans le cache local selon un critère
      Utilise le cache pour des performances optimales  */
  List<Role> searchRoles(String query) {
    if (query.isEmpty) return _cachedRoles; // Retourne tout si recherche vide

    final queryLower = query.toLowerCase();

    // Filtrage des rôles selon le critère de recherche
    return _cachedRoles
        .where(
          (role) => role.name.toLowerCase().contains(
            queryLower,
          ), // Recherche dans le nom
        )
        .toList();
  }

  /* Validation des données du rôle selon les règles métier
     correspondant à @Size et @NotBlank */
  void _validateRoleData(Role role) {
    // Validation de la longueur minimale (comme @Size(min = 3))
    if (role.name.length < 3) {
      throw Exception('Le nom du rôle doit contenir au moins 3 caractères');
    }

    // Validation de la longueur maximale (comme @Size(max = 50))
    if (role.name.length > 50) {
      throw Exception('Le nom du rôle ne peut pas dépasser 50 caractères');
    }

    // Validation des noms de rôles réservés (logique métier supplémentaire)
    final nomsReserves = ['superadmin', 'root', 'system'];
    if (nomsReserves.contains(role.name.toLowerCase())) {
      throw Exception('Ce nom de rôle est réservé et ne peut pas être utilisé');
    }
  }

  /* Vérifie si un rôle existe déjà dans le cache pour éviter les doublons  */
  bool roleExists(String roleName) {
    return _cachedRoles.any(
      (role) => role.name.toLowerCase() == roleName.toLowerCase(),
    );
  }

  // Récupère les rôles correspondant à un pattern (pour auto-complétion)
  List<Role> getRolesByPattern(String pattern) {
    if (pattern.isEmpty) return _cachedRoles;

    return _cachedRoles
        .where(
          (role) => role.name.toLowerCase().contains(pattern.toLowerCase()),
        )
        .toList();
  }

  /* Vide complètement le cache utile pour forcer un rafraîchissement complet */
  void clearCache() {
    _cachedRoles.clear();
    _lastFetchTime = null;
    print("🗑️ Cache des rôles vidé");
  }

  /* Récupère les rôles les plus utilisés:
   pour l'instant retourne simplement les premiers rôles */
  List<Role> getMostUsedRoles([int limit = 5]) {
    // Ici on pourrait implémenter une logique plus complexe
    // basée sur l'utilisation réelle des rôles
    return _cachedRoles.take(limit).toList();
  }
  */
