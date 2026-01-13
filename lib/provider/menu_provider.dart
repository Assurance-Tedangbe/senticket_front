import 'package:flutter/foundation.dart';
import 'package:senticket_front/model/menu_model.dart';
import 'package:senticket_front/services/menu_service.dart';

/*
  Rôle Principal: Gestionnaire d'état centralisé pour les menus
  Votre MenuProvider sert de cerveau central qui :
   - Stocke l'état de tous les menus / gère l'état de l'interface utilisateur 
   - Coordonne les opérations CRUD / actions sur les menus 
   - Gère le loading et les erreurs
   - Notifie l'UI des changements / notifie les changements aux écouteurs

  Gère l'état de toutes les opérations du MenuApiService
*/
class MenuProvider with ChangeNotifier {
  // "Crée une classe qui peut notifier ses écouteurs des changements"

  // "_" signifie que ces variables sont privées

  final MenuApiService _service;

  // === INTERNAL STATE FOR ALL OPERATIONS ===

  // "État principal"
  List<Menu> _menus = []; // "Liste vide pour stocker tous les menus"
  Menu? _currentMenu; // "Menu actuellement sélectionné (peut être null)"
  bool _isLoading = false; // "Indicateur de chargement (initialement false)"
  String _error = ''; // "Stocke les messages d'erreur (initialement vide)"

  // "État pour les opérations spécifiques"
  bool _isCreatingMenu = false; // "Création en cours"
  bool _isUpdatingMenu = false; // "Mise à jour en cours"
  bool _isDeletingMenu = false; // "Suppression en cours"

  MenuProvider(this._service);

  // === GETTERS - Accès contrôlé à l'état ===

  // "Getters principaux"
  List<Menu> get menus =>
      _menus; // "Permet à d'autres classes de lire `_menus` mais pas de le modifier"
  Menu? get currentMenu => _currentMenu;
  bool get isLoading => _isLoading;
  String get error => _error;

  // "Getters pour les états spécifiques"
  bool get isCreatingMenu => _isCreatingMenu;
  bool get isUpdatingMenu => _isUpdatingMenu;
  bool get isDeletingMenu => _isDeletingMenu;

  // === MÉTHODES D'ACTION - Gestion complète des états ===

  // "Charge tous les menus depuis le service"
  Future<void> loadAllMenus({bool forceRefresh = false}) async {
    // "charge les menus, cela va prendre du temps (async)"

    _isLoading = true; // "active le chargement"
    _error = ''; // "efface les erreurs précédentes"
    notifyListeners(); // "notifie l'UI du début du chargement"

    try {
      _menus = await _service.getAllMenus(
          forceRefresh:
              forceRefresh); // "Demande au service de me donner tous les menus"

      _error = ''; // "Confirme qu'il n'y a pas d'erreurs"
      print("Chargement réussi : ${_menus.length} menus");
    } catch (e) {
      _error = e.toString(); // "Stocke l'erreur"
      print("Erreur loadAllMenus: $e");
    } finally {
      _isLoading = false; // "arrête le chargement"
      notifyListeners(); // "notifie l'UI de la fin du chargement"
    }
  }

  // "Crée un nouveau menu"
  Future<bool> createNewMenu(Menu menu) async {
    // "Je vais créer un menu et je vous dirai si ça a fonctionné (bool)"
    _isCreatingMenu = true;
    _isLoading = true;
    notifyListeners(); // "démarre le travail et notifie l'interface"

    try {
      // "Valide les données avant la création"
      _service.validateMenuData(menu);

      final newMenu = await _service
          .createMenu(menu); // "demande au service de créer ce menu dans l'API"

      _menus.add(
          newMenu); // "Si ça fonctionne, ajoute le nouveau menu à ma liste locale"

      _error = ''; // "Efface les erreurs"
      print("Menu créé avec succès: ${newMenu.menuName}");
      return true; // "Succès"
    } catch (e) {
      _error = 'Erreur création: ${e.toString()}';
      print("Erreur createNewMenu: $e");
      return false; // "Échec"
    } finally {
      _isCreatingMenu = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Met à jour un menu existant"
  Future<bool> updateExistingMenu(Menu menu) async {
    _isUpdatingMenu = true;
    _isLoading = true;
    notifyListeners();

    try {
      _service.validateMenuData(menu);

      final updatedMenu = await _service
          .updateMenu(menu); // "demande à l'API de mettre à jour ce menu"

      // "Met à jour dans la liste locale"
      final index = _menus.indexWhere((m) =>
          m.menuId ==
          menu.menuId); // "cherche la position de ce menu dans ma liste"
      if (index != -1) {
        _menus[index] =
            updatedMenu; // "Si j'ai trouvé le menu (index != -1), je remplace l'ancienne version par la nouvelle"
      }

      _error = '';
      print("Menu mis à jour avec succès: ${updatedMenu.menuName}");
      return true;
    } catch (e) {
      _error = 'Erreur mise à jour menu: ${e.toString()}';
      print("Erreur updateExistingMenu: $e");
      return false;
    } finally {
      _isUpdatingMenu = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Supprime un menu"
  Future<bool> deleteExistingMenu(String menuId) async {
    _isDeletingMenu = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteMenu(
          menuId); // "demande à l'API de supprimer le menu avec cet ID"

      // "supprime le menu de la liste locale"
      _menus.removeWhere((menu) => menu.menuId == menuId);

      _error = '';
      print("Menu avec cet ID supprimé: $menuId");
      return true;
    } catch (e) {
      _error = 'Erreur suppression: ${e.toString()}';
      print("Erreur deleteExistingMenu: $e");
      return false;
    } finally {
      _isDeletingMenu = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Charge un menu spécifique par son ID
     Cette méthode retourne void car le résultat est stocké dans _currentMenu */
  Future<void> loadMenuById(String menuId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _currentMenu = await _service.getMenuById(
          menuId); // "demande un menu spécifique par son id à l'API et le stocke dans _currentMenu"
      _error = '';
      print("Menu chargé par ID: $menuId");
    } catch (e) {
      _error = 'Erreur chargement menu: ${e.toString()}';
      print("Erreur loadMenuById: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === MÉTHODES UTILITAIRES ===

  // "Recherche de menus (utilise le cache local du service)"
  List<Menu> searchMenus(String query) {
    return _service.searchMenus(query);
  }

  // "Filtre les menus par type"
  List<Menu> filterMenusByType(String menuType) {
    return _service.filterMenusByType(menuType);
  }

  // "Trie les menus par nom"
  List<Menu> sortMenusByName(bool ascending) {
    return _service.sortMenusByName(ascending);
  }

  // "Efface le message d'erreur et notifie l'UI"
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // "Efface le menu courant et notifie l'UI"
  void clearCurrentMenu() {
    _currentMenu = null;
    notifyListeners();
  }

  // "Force le rafraîchissement des données"
  Future<void> refreshData() async {
    await loadAllMenus(forceRefresh: true);
  }

  /*  // "Obtient tous les types de menus uniques"
  List<String> getUniqueMenuTypes() {
    final types = _menus.map((menu) => menu.menuType).toSet().toList();
    types.sort();
    return types;
  }

  // "Vérifie si un nom de menu existe déjà"
  bool doesMenuNameExist(String menuName) {
    return _menus
        .any((menu) => menu.menuName.toLowerCase() == menuName.toLowerCase());
  }

  // "Obtient un menu par son nom"
  Menu? getMenuByName(String menuName) {
    try {
      return _menus.firstWhere(
          (menu) => menu.menuName.toLowerCase() == menuName.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // "Obtient les statistiques des menus"
  Map<String, int> getMenuStatistics() {
    final statistics = <String, int>{};

    // "Compte par type de menu"
    for (final menu in _menus) {
      statistics[menu.menuType] = (statistics[menu.menuType] ?? 0) + 1;
    }

    return statistics;
  } */
}
