import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:senticket_front/model/consulter_menu_model.dart';
import 'package:senticket_front/model/menu_model.dart';

/* 
  - Service combiné qui gère :
  - Appels HTTP vers l'API Spring Boot pour les consultations de menus
  - Cache simple des données
  - Logique métier légère
  - Transformation des données 
*/
class ConsulterMenuApiService {
  static const String baseUrl = 'http://192.168.1.4:8080/api/consulter_menus';

  // Configure HTTP headers for all requests
  static final Map<String, String> headers = {
    'Content-Type': 'application/json', // Indique au serveur "J'envoie du JSON"
    'Accept':
        'application/json', // Indique au serveur "Je veux recevoir du JSON"
  };

  // === CACHE SIMPLE INTÉGRÉ ===
  List<ConsulterMenu> _cachedConsulterMenus =
      []; // Cache des consultations de menus
  DateTime? _lastFetchTime; // Dernière récupération
  static const Duration cacheDuration = Duration(minutes: 5); // Durée de cache

  // -------------------------
  // 1. CREATE CONSULTER MENU (POST /api/consulter_menus)
  // -------------------------
  Future<ConsulterMenu> createConsulterMenu(ConsulterMenu consulterMenu) async {
    // "Je vais créer une consultation de menu via POST /api/consulter_menus et retourner la consultation créée"
    try {
      print(
          "Création d'une nouvelle consultation de menu: ${consulterMenu.menu.menuName} par ${consulterMenu.userDTO.firstName}");

      final response = await http.post(
        // "J'envoie une requête POST :"
        Uri.parse(baseUrl), // Convertit l'URL string en objet Uri
        headers: headers, // Utilise les headers configurés
        body: json.encode(consulterMenu
            .toJson()), // Convertit l'objet ConsulterMenu → JSON string
      );

      if (response.statusCode == 201) {
        final newConsulterMenu = ConsulterMenu.fromJson(json.decode(response
            .body)); // "Convertit la réponse JSON → objet ConsulterMenu"

        print(
            "Consultation de menu créée avec ID: ${newConsulterMenu.consulterMenuId}");

        // Mise à jour du cache
        _cachedConsulterMenus.add(newConsulterMenu);

        return newConsulterMenu;
      } else {
        throw Exception(
            'Erreur création consultation menu: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur création consultation menu: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 2. READ ALL CONSULTER MENUS (GET /api/consulter_menus)
  // -------------------------
  // Utilise le cache pour éviter les appels API inutiles
  Future<List<ConsulterMenu>> getAllConsulterMenus(
      {bool forceRefresh = false}) async {
    // "Vérifie si le cache est encore valide"
    final now = DateTime.now();

    final cacheValide = _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < cacheDuration;

    // "Retourne le cache si valide et pas de force refresh"
    if (!forceRefresh && cacheValide && _cachedConsulterMenus.isNotEmpty) {
      print(
          "Retourne ${_cachedConsulterMenus.length} consultations de menus depuis le cache");

      return _cachedConsulterMenus;
    }

    try {
      print("Récupération des consultations de menus depuis l'API");

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // "Convertit la réponse JSON → liste d'objets ConsulterMenu"

        final List<dynamic> jsonList =
            json.decode(response.body); // "JSON string → Liste d'objets Dart"

        _cachedConsulterMenus = jsonList
            .map((json) => ConsulterMenu.fromJson(json))
            .toList(); // "Transforme chaque objet JSON → objet ConsulterMenu"

        _lastFetchTime = DateTime.now(); // "Mise à jour du timestamp"

        print(
            "${_cachedConsulterMenus.length} consultations de menus récupérées");

        return _cachedConsulterMenus;
      } else {
        throw Exception(
            'Erreur récupération consultations menus: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur récupération consultations menus: $e");

      // Fallback: retourne le cache même expiré si pas de réseau
      if (_cachedConsulterMenus.isNotEmpty) {
        print("Retourne cache expiré en fallback");
        return _cachedConsulterMenus;
      }

      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 3. READ CONSULTER MENU BY ID (GET /api/consulter_menus/{consulterMenuId})
  // -------------------------
  Future<ConsulterMenu> getConsulterMenuById(String consulterMenuId) async {
    try {
      print("Récupération de la consultation de menu ID: $consulterMenuId");

      // "D'abord, recherche dans le cache"
      final cachedConsulterMenu = _cachedConsulterMenus.firstWhere(
        (consulterMenu) => consulterMenu.consulterMenuId == consulterMenuId,
        orElse: () => ConsulterMenu(
          consulterMenuId:
              -1, // Marqueur "non trouvé" - valeur spéciale pour indiquer l'absence
          consultationDate: DateTime.now(),
          menu: Menu(
            menuName: '',
            menuType: '',
            menuDescription: '',
          ),
          userDTO: UserDTO(
            firstName: '',
            lastName: '',
            username: '',
          ),
        ),
      );

      if (cachedConsulterMenu.consulterMenuId != -1) {
        print("Consultation de menu trouvée dans le cache");
        return cachedConsulterMenu;
      }

      // "Si pas dans le cache, appel API"
      final response = await http.get(
        Uri.parse('$baseUrl/$consulterMenuId'),
        headers: headers,
      ); // "GET /api/consulter_menus/{consulterMenuId} pour récupérer une consultation spécifique"

      if (response.statusCode == 200) {
        final consulterMenu =
            ConsulterMenu.fromJson(json.decode(response.body));

        print(
            "Consultation de menu récupérée: ${consulterMenu.consulterMenuId}");

        return consulterMenu;
      } else if (response.statusCode == 404) {
        throw Exception('Consultation de menu non trouvée');
      } else {
        throw Exception(
            'Erreur récupération consultation menu: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur récupération par ID: $e");

      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 4. UPDATE CONSULTER MENU (PUT /api/consulter_menus/{consulterMenuId})
  // -------------------------
  Future<ConsulterMenu> updateConsulterMenu(ConsulterMenu consulterMenu) async {
    try {
      print(
          "Mise à jour de la consultation de menu ID: ${consulterMenu.consulterMenuId}");

      final response = await http.put(
        Uri.parse('$baseUrl/${consulterMenu.consulterMenuId}'),
        headers: headers,
        body: json
            .encode(consulterMenu.toJson()), // "Envoie les nouvelles données"
      ); // "PUT /api/consulter_menus/{consulterMenuId} pour modifier une consultation existante"

      if (response.statusCode == 200) {
        final updatedConsulterMenu =
            ConsulterMenu.fromJson(json.decode(response.body));
        print(
            "Consultation de menu mise à jour: ${updatedConsulterMenu.consulterMenuId}");

        // "Met à jour le cache"
        final index = _cachedConsulterMenus.indexWhere(
            (cm) => cm.consulterMenuId == consulterMenu.consulterMenuId);
        if (index != -1) {
          _cachedConsulterMenus[index] = updatedConsulterMenu;
        }

        return updatedConsulterMenu;
      } else {
        throw Exception(
            'Erreur mise à jour consultation menu: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur mise à jour consultation menu: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 5. DELETE CONSULTER MENU (DELETE /api/consulter_menus/{consulterMenuId})
  // -------------------------
  Future<void> deleteConsulterMenu(String consulterMenuId) async {
    try {
      print("Suppression de la consultation de menu ID: $consulterMenuId");

      final response = await http.delete(
        Uri.parse('$baseUrl/$consulterMenuId'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        print("Consultation de menu supprimée avec ID: $consulterMenuId");

        // "Met à jour le cache"
        _cachedConsulterMenus.removeWhere((consulterMenu) =>
            consulterMenu.consulterMenuId == consulterMenuId);
      } else {
        throw Exception(
            'Erreur suppression consultation menu: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur suppression consultation menu: $e");

      throw Exception('Erreur réseau: $e');
    }
  }

  // === MÉTHODES UTILITAIRES AVEC LOGIQUE MÉTIER LÉGÈRE ===

  // "Recherche de consultations de menus dans le cache local"
  List<ConsulterMenu> searchConsulterMenus(String query) {
    if (query.isEmpty) return _cachedConsulterMenus;

    final queryLower = query.toLowerCase();

    return _cachedConsulterMenus
        .where((consulterMenu) =>
            consulterMenu.menu.menuName.toLowerCase().contains(queryLower) ||
            consulterMenu.menu.menuType.toLowerCase().contains(queryLower) ||
            consulterMenu.userDTO.firstName
                .toLowerCase()
                .contains(queryLower) ||
            consulterMenu.userDTO.lastName.toLowerCase().contains(queryLower) ||
            consulterMenu.userDTO.username.toLowerCase().contains(queryLower) ||
            _formatDate(consulterMenu.consultationDate).contains(queryLower))
        .toList();
  }

  // "Validation basique des données de consultation de menu"
  void validateConsulterMenuData(ConsulterMenu consulterMenu) {
    if (consulterMenu.consultationDate.isAfter(DateTime.now())) {
      throw Exception('La date de consultation ne peut pas être dans le futur');
    }

    if (consulterMenu.menu.menuId == null) {
      throw Exception('Le menu est requis');
    }
    /* if (consulterMenu.menu.menuId.isEmpty) {
      throw Exception('Le menu est requis');
    } */

    if (consulterMenu.userDTO.userId == null) {
      throw Exception('L\'utilisateur est requis');
    }
  }

  // "Vide le cache (utile pour forcer un rafraîchissement)"
  void clearCache() {
    _cachedConsulterMenus.clear();
    _lastFetchTime = null;
    print("Cache consultations de menus vidé");
  }

  // "Filtre les consultations par utilisateur"
  List<ConsulterMenu> filterConsulterMenusByUserId(String userId) {
    return _cachedConsulterMenus
        .where((consulterMenu) => consulterMenu.userDTO.userId == userId)
        .toList();
  }

  // "Filtre les consultations par menu"
  List<ConsulterMenu> filterConsulterMenusByMenuId(String menuId) {
    return _cachedConsulterMenus
        .where((consulterMenu) => consulterMenu.menu.menuId == menuId)
        .toList();
  }

  // "Filtre les consultations par date"
  List<ConsulterMenu> filterConsulterMenusByDate(DateTime date) {
    return _cachedConsulterMenus
        .where((consulterMenu) =>
            consulterMenu.consultationDate.year == date.year &&
            consulterMenu.consultationDate.month == date.month &&
            consulterMenu.consultationDate.day == date.day)
        .toList();
  }

  // "Filtre les consultations par période"
  List<ConsulterMenu> filterConsulterMenusByDateRange(
      DateTime startDate, DateTime endDate) {
    return _cachedConsulterMenus
        .where((consulterMenu) =>
            consulterMenu.consultationDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            consulterMenu.consultationDate
                .isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  // "Trie les consultations par date (récentes ou anciennes en premier)"
  List<ConsulterMenu> sortConsulterMenusByDate(bool ascending) {
    final sortedConsulterMenus =
        List<ConsulterMenu>.from(_cachedConsulterMenus);
    sortedConsulterMenus.sort((a, b) => ascending
        ? a.consultationDate.compareTo(b.consultationDate)
        : b.consultationDate.compareTo(a.consultationDate));
    return sortedConsulterMenus;
  }

  // "Trie les consultations par nom de menu"
  List<ConsulterMenu> sortConsulterMenusByMenuName(bool ascending) {
    final sortedConsulterMenus =
        List<ConsulterMenu>.from(_cachedConsulterMenus);
    sortedConsulterMenus.sort((a, b) => ascending
        ? a.menu.menuName.compareTo(b.menu.menuName)
        : b.menu.menuName.compareTo(a.menu.menuName));
    return sortedConsulterMenus;
  }

  // "Trie les consultations par nom d'utilisateur"
  List<ConsulterMenu> sortConsulterMenusByUserName(bool ascending) {
    final sortedConsulterMenus =
        List<ConsulterMenu>.from(_cachedConsulterMenus);
    sortedConsulterMenus.sort((a, b) {
      final aName = '${a.userDTO.firstName} ${a.userDTO.lastName}';
      final bName = '${b.userDTO.firstName} ${b.userDTO.lastName}';
      return ascending ? aName.compareTo(bName) : bName.compareTo(aName);
    });
    return sortedConsulterMenus;
  }

  // "Méthode utilitaire pour formater une date"
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // "Obtient les statistiques de consultation"
  Map<String, dynamic> getConsultationStatistics() {
    final statistics = <String, dynamic>{};

    // "Nombre total de consultations"
    statistics['totalConsultations'] = _cachedConsulterMenus.length;

    // "Consultations par menu"
    final consultationsByMenu = <String, int>{};
    for (final consulterMenu in _cachedConsulterMenus) {
      final menuName = consulterMenu.menu.menuName;
      consultationsByMenu[menuName] = (consultationsByMenu[menuName] ?? 0) + 1;
    }
    statistics['consultationsByMenu'] = consultationsByMenu;

    // "Consultations par utilisateur"
    final consultationsByUser = <String, int>{};
    for (final consulterMenu in _cachedConsulterMenus) {
      final userName =
          '${consulterMenu.userDTO.firstName} ${consulterMenu.userDTO.lastName}';
      consultationsByUser[userName] = (consultationsByUser[userName] ?? 0) + 1;
    }
    statistics['consultationsByUser'] = consultationsByUser;

    // "Consultations par date"
    final consultationsByDate = <String, int>{};
    for (final consulterMenu in _cachedConsulterMenus) {
      final dateKey = _formatDate(consulterMenu.consultationDate);
      consultationsByDate[dateKey] = (consultationsByDate[dateKey] ?? 0) + 1;
    }
    statistics['consultationsByDate'] = consultationsByDate;

    return statistics;
  }

  // "Vérifie si un utilisateur a déjà consulté un menu aujourd'hui"
  bool hasUserConsultedMenuToday(String userId, String menuId) {
    final today = DateTime.now();
    return _cachedConsulterMenus.any((consulterMenu) =>
        consulterMenu.userDTO.userId == userId &&
        consulterMenu.menu.menuId == menuId &&
        consulterMenu.consultationDate.year == today.year &&
        consulterMenu.consultationDate.month == today.month &&
        consulterMenu.consultationDate.day == today.day);
  }

  // "Obtient le menu le plus consulté"
  String getMostConsultedMenu() {
    if (_cachedConsulterMenus.isEmpty) return 'Aucune consultation';

    final menuCounts = <String, int>{};
    for (final consulterMenu in _cachedConsulterMenus) {
      final menuName = consulterMenu.menu.menuName;
      menuCounts[menuName] = (menuCounts[menuName] ?? 0) + 1;
    }

    return menuCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // "Obtient l'utilisateur qui a le plus consulté de menus"
  String getMostActiveUser() {
    if (_cachedConsulterMenus.isEmpty) return 'Aucun utilisateur';

    final userCounts = <String, int>{};
    for (final consulterMenu in _cachedConsulterMenus) {
      final userName =
          '${consulterMenu.userDTO.firstName} ${consulterMenu.userDTO.lastName}';
      userCounts[userName] = (userCounts[userName] ?? 0) + 1;
    }

    return userCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
