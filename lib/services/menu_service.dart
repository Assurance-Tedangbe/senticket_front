import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:senticket_front/model/menu_model.dart';

/* 
  - Service combiné qui gère :
  - Appels HTTP vers l'API Spring Boot pour les menus
  - Cache simple des données
  - Logique métier légère
  - Transformation des données 
*/
class MenuApiService {
  static const String baseUrl = 'http://192.168.1.4:8080/api/menus';

  // Configure HTTP headers for all requests
  static final Map<String, String> headers = {
    'Content-Type': 'application/json', // Indique au serveur "J'envoie du JSON"
    'Accept':
        'application/json', // Indique au serveur "Je veux recevoir du JSON"
  };

  // === CACHE SIMPLE INTÉGRÉ ===
  List<Menu> _cachedMenus = []; // Cache des menus
  DateTime? _lastFetchTime; // Dernière récupération
  static const Duration cacheDuration = Duration(minutes: 5); // Durée de cache

  // -------------------------
  // 1. CREATE MENU (POST /api/menus)
  // -------------------------
  Future<Menu> createMenu(Menu menu) async {
    // "Je vais créer un menu via POST /api/menus et retourner le menu créé"
    try {
      print("Création d'un nouveau menu: ${menu.menuName}");

      final response = await http.post(
        // "J'envoie une requête POST :"
        Uri.parse(baseUrl), // Convertit l'URL string en objet Uri
        headers: headers, // Utilise les headers configurés
        body:
            json.encode(menu.toJson()), // Convertit l'objet Menu → JSON string
      );

      if (response.statusCode == 201) {
        final newMenu = Menu.fromJson(json
            .decode(response.body)); // "Convertit la réponse JSON → objet Menu"

        print("Menu créé avec ID: ${newMenu.menuId}");

        // Mise à jour du cache
        _cachedMenus.add(newMenu);

        return newMenu;
      } else {
        throw Exception('Erreur création menu: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur création menu: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 2. READ ALL MENUS (GET /api/menus)
  // -------------------------
  // Utilise le cache pour éviter les appels API inutiles
  Future<List<Menu>> getAllMenus({bool forceRefresh = false}) async {
    // "Vérifie si le cache est encore valide"
    final now = DateTime.now();

    final cacheValide = _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < cacheDuration;

    // "Retourne le cache si valide et pas de force refresh"
    if (!forceRefresh && cacheValide && _cachedMenus.isNotEmpty) {
      print("Retourne ${_cachedMenus.length} menus depuis le cache");

      return _cachedMenus;
    }

    try {
      print("Récupération des menus depuis l'API");

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // "Convertit la réponse JSON → liste d'objets Menu"

        final List<dynamic> jsonList =
            json.decode(response.body); // "JSON string → Liste d'objets Dart"

        _cachedMenus = jsonList
            .map((json) => Menu.fromJson(json))
            .toList(); // "Transforme chaque objet JSON → objet Menu"

        _lastFetchTime = DateTime.now(); // "Mise à jour du timestamp"

        print("${_cachedMenus.length} menus récupérés");

        return _cachedMenus;
      } else {
        throw Exception('Erreur récupération menus: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur récupération menus: $e");

      // Fallback: retourne le cache même expiré si pas de réseau
      if (_cachedMenus.isNotEmpty) {
        print("Retourne cache expiré en fallback");
        return _cachedMenus;
      }

      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 3. READ MENU BY ID (GET /api/menus/{menuId})
  // -------------------------
  Future<Menu> getMenuById(String menuId) async {
    try {
      print("Récupération du menu ID: $menuId");

      // "D'abord, recherche dans le cache"
      final cachedMenu = _cachedMenus.firstWhere(
        (menu) => menu.menuId == menuId,
        orElse: () => Menu(
          menuId: -1, // Marqueur "non trouvé"
          menuName: '',
          menuType: '',
          menuDescription: '',
        ),
      );

      if (cachedMenu.menuId != -1) {
        print("Menu trouvé dans le cache");
        return cachedMenu;
      }

      // "Si pas dans le cache, appel API"
      final response = await http.get(
        Uri.parse('$baseUrl/$menuId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final menu = Menu.fromJson(json.decode(response.body));

        print("Menu récupéré: ${menu.menuName}");

        return menu;
      } else if (response.statusCode == 404) {
        throw Exception('Menu non trouvé');
      } else {
        throw Exception('Erreur récupération menu: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur récupération par ID: $e");

      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 4. UPDATE MENU (PUT /api/menus/{menuId})
  // -------------------------
  Future<Menu> updateMenu(Menu menu) async {
    try {
      print("Mise à jour du menu ID: ${menu.menuId}");

      final response = await http.put(
        Uri.parse('$baseUrl/${menu.menuId}'),
        headers: headers,
        body: json.encode(menu.toJson()), // "Envoie les nouvelles données"
      );

      if (response.statusCode == 200) {
        final updatedMenu = Menu.fromJson(json.decode(response.body));
        print("Menu mis à jour: ${updatedMenu.menuName}");

        // "Met à jour le cache"
        final index = _cachedMenus.indexWhere((m) => m.menuId == menu.menuId);
        if (index != -1) {
          _cachedMenus[index] = updatedMenu;
        }

        return updatedMenu;
      } else {
        throw Exception('Erreur mise à jour menu: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur mise à jour menu: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 5. DELETE MENU (DELETE /api/menus/{menuId})
  // -------------------------
  Future<void> deleteMenu(String menuId) async {
    try {
      print("Suppression du menu ID: $menuId");

      final response = await http.delete(
        Uri.parse('$baseUrl/$menuId'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        print("Menu supprimé avec ID: $menuId");

        // "Met à jour le cache"
        _cachedMenus.removeWhere((menu) => menu.menuId == menuId);
      } else {
        throw Exception('Erreur suppression menu: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur suppression menu: $e");

      throw Exception('Erreur réseau: $e');
    }
  }

  // === MÉTHODES UTILITAIRES AVEC LOGIQUE MÉTIER LÉGÈRE ===

  // "Recherche de menus dans le cache local"
  List<Menu> searchMenus(String query) {
    print("searching for menus with query: $query");
    if (query.isEmpty) return _cachedMenus;

    final queryLower = query.toLowerCase();

    return _cachedMenus
        .where((menu) =>
            menu.menuName.toLowerCase().contains(queryLower) ||
            menu.menuType.toLowerCase().contains(queryLower) ||
            menu.menuDescription.toLowerCase().contains(queryLower))
        .toList();
  }

  // "Validation basique des données de menu"
  void validateMenuData(Menu menu) {
    if (menu.menuName.length < 3) {
      throw Exception('Le nom du menu doit contenir au moins 3 caractères');
    }

    // "Validation de la longueur maximale (comme @Size(max = 70))"
    if (menu.menuName.length > 70) {
      throw Exception('Le nom du menu ne peut pas dépasser 70 caractères');
    }

    if (menu.menuType.length < 3) {
      throw Exception('Le type de menu doit contenir au moins 3 caractères');
    }

    if (menu.menuType.length > 30) {
      throw Exception('Le type de menu ne peut pas dépasser 30 caractères');
    }

    if (menu.menuDescription.length < 3) {
      throw Exception(
          'La description du menu doit contenir au moins 3 caractères');
    }

    if (menu.menuDescription.length > 100) {
      throw Exception(
          'La description du menu ne peut pas dépasser 100 caractères');
    }
  }

  // "Vide le cache (utile pour forcer un rafraîchissement)"
  void clearCache() {
    print("Vider le cache");
    _cachedMenus.clear();
    _lastFetchTime = null;
    print("Cache menus vidé");
  }

  // "Filtre les menus par type"
  List<Menu> filterMenusByType(String menuType) {
    print("Filtrer les menus par type: $menuType");

    if (menuType.isEmpty) return _cachedMenus;

    return _cachedMenus
        .where((menu) => menu.menuType.toLowerCase() == menuType.toLowerCase())
        .toList();
  }

  // "Trie les menus par nom (ordre alphabétique)"
  List<Menu> sortMenusByName(bool ascendingOrder) {
    print("Trie les menus par nom: $ascendingOrder");

    final sortedMenus = List<Menu>.from(_cachedMenus);

    sortedMenus.sort((a, b) => ascendingOrder
        ? a.menuName.compareTo(b.menuName)
        : b.menuName.compareTo(a.menuName));

    return sortedMenus;
  }
}
