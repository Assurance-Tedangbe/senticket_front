import 'package:flutter/foundation.dart';
import 'package:senticket_front/model/consulter_menu_model.dart';
import 'package:senticket_front/model/menu_model.dart';
import 'package:senticket_front/services/consulter_menu_service.dart';

/*
  Rôle Principal: Gestionnaire d'état centralisé pour les consultations de menus
  Votre ConsulterMenuProvider sert de cerveau central qui :
   - Stocke l'état de toutes les consultations / gère l'état de l'interface utilisateur 
   - Coordonne les opérations CRUD / actions sur les consultations 
   - Gère le loading et les erreurs
   - Notifie l'UI des changements / notifie les changements aux écouteurs

  Gère l'état de toutes les opérations du ConsulterMenuApiService
*/
class ConsulterMenuProvider with ChangeNotifier {
  // "Crée une classe qui peut notifier ses écouteurs des changements"

  // "_" signifie que ces variables sont privées

  final ConsulterMenuApiService _service;

  // === INTERNAL STATE FOR ALL OPERATIONS ===

  // "État principal"
  List<ConsulterMenu> _consulterMenus =
      []; // "Liste vide pour stocker toutes les consultations"
  ConsulterMenu?
      _currentConsulterMenu; // "Consultation actuellement sélectionnée (peut être null)"
  bool _isLoading = false; // "Indicateur de chargement (initialement false)"
  String _error = ''; // "Stocke les messages d'erreur (initialement vide)"

  // "État pour les opérations spécifiques"
  bool _isCreatingConsulterMenu = false; // "Création en cours"
  bool _isUpdatingConsulterMenu = false; // "Mise à jour en cours"
  bool _isDeletingConsulterMenu = false; // "Suppression en cours"

  ConsulterMenuProvider(this._service);

  // === GETTERS - Accès contrôlé à l'état ===

  // "Getters principaux"
  List<ConsulterMenu> get consulterMenus =>
      _consulterMenus; // "Permet à d'autres classes de lire `_consulterMenus` mais pas de le modifier"
  ConsulterMenu? get currentConsulterMenu => _currentConsulterMenu;
  bool get isLoading => _isLoading;
  String get error => _error;

  // "Getters pour les états spécifiques"
  bool get isCreatingConsulterMenu => _isCreatingConsulterMenu;
  bool get isUpdatingConsulterMenu => _isUpdatingConsulterMenu;
  bool get isDeletingConsulterMenu => _isDeletingConsulterMenu;

  // === MÉTHODES D'ACTION - Gestion complète des états ===

  // "Charge toutes les consultations depuis le service"
  Future<void> loadAllConsulterMenus({bool forceRefresh = false}) async {
    // "charge les consultations, cela va prendre du temps (async)"

    _isLoading = true; // "active le chargement"
    _error = ''; // "efface les erreurs précédentes"
    notifyListeners(); // "notifie l'UI du début du chargement"

    try {
      _consulterMenus = await _service.getAllConsulterMenus(
          forceRefresh:
              forceRefresh); // "Demande au service de me donner toutes les consultations"
      _error = ''; // "Confirme qu'il n'y a pas d'erreurs"
      print(
          "Chargement réussi : ${_consulterMenus.length} consultations de menus");
    } catch (e) {
      _error = e.toString(); // "Stocke l'erreur"
      print("Erreur loadAllConsulterMenus: $e");
    } finally {
      _isLoading = false; // "arrête le chargement"
      notifyListeners(); // "notifie l'UI de la fin du chargement"
    }
  }

  // "Crée une nouvelle consultation de menu"
  Future<bool> createNewConsulterMenu(ConsulterMenu consulterMenu) async {
    // "Je vais créer une consultation et je vous dirai si ça a fonctionné (bool)"
    _isCreatingConsulterMenu = true;
    _isLoading = true;
    notifyListeners(); // "démarre le travail et notifie l'interface"

    try {
      // "Valide les données avant la création"
      _service.validateConsulterMenuData(consulterMenu);

      final newConsulterMenu = await _service.createConsulterMenu(
          consulterMenu); // "demande au service de créer cette consultation dans l'API"
      _consulterMenus.add(
          newConsulterMenu); // "Si ça fonctionne, ajoute la nouvelle consultation à ma liste locale"
      _error = ''; // "Efface les erreurs"
      print(
          "Consultation de menu créée avec succès: ${newConsulterMenu.consulterMenuId}");
      return true; // "Succès"
    } catch (e) {
      _error = 'Erreur création consultation: ${e.toString()}';
      print("Erreur createNewConsulterMenu: $e");
      return false; // "Échec"
    } finally {
      _isCreatingConsulterMenu = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Met à jour une consultation existante"
  Future<bool> updateExistingConsulterMenu(ConsulterMenu consulterMenu) async {
    _isUpdatingConsulterMenu = true;
    _isLoading = true;
    notifyListeners();

    try {
      _service.validateConsulterMenuData(consulterMenu);

      final updatedConsulterMenu = await _service.updateConsulterMenu(
          consulterMenu); // "demande à l'API de mettre à jour cette consultation"

      // "Met à jour dans la liste locale"
      final index = _consulterMenus.indexWhere((cm) =>
          cm.consulterMenuId ==
          consulterMenu
              .consulterMenuId); // "cherche la position de cette consultation dans ma liste"
      if (index != -1) {
        _consulterMenus[index] =
            updatedConsulterMenu; // "Si j'ai trouvé la consultation (index != -1), je remplace l'ancienne version par la nouvelle"
      }

      _error = '';
      print(
          "Consultation de menu mise à jour avec succès: ${updatedConsulterMenu.consulterMenuId}");
      return true;
    } catch (e) {
      _error = 'Erreur mise à jour consultation: ${e.toString()}';
      print("Erreur updateExistingConsulterMenu: $e");
      return false;
    } finally {
      _isUpdatingConsulterMenu = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Supprime une consultation"
  Future<bool> deleteExistingConsulterMenu(String consulterMenuId) async {
    _isDeletingConsulterMenu = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteConsulterMenu(
          consulterMenuId); // "demande à l'API de supprimer la consultation avec cet ID"

      // "supprime la consultation de la liste locale"
      _consulterMenus.removeWhere(
          (consulterMenu) => consulterMenu.consulterMenuId == consulterMenuId);

      _error = '';
      print("Consultation avec cet ID supprimée: $consulterMenuId");
      return true;
    } catch (e) {
      _error = 'Erreur suppression: ${e.toString()}';
      print("Erreur deleteExistingConsulterMenu: $e");
      return false;
    } finally {
      _isDeletingConsulterMenu = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Charge une consultation spécifique par son ID
     Cette méthode retourne void car le résultat est stocké dans _currentConsulterMenu */
  Future<void> loadConsulterMenuById(String consulterMenuId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _currentConsulterMenu = await _service.getConsulterMenuById(
          consulterMenuId); // "demande une consultation spécifique par son id à l'API et la stocke dans _currentConsulterMenu"
      _error = '';
      print("Consultation de menu chargée par ID: $consulterMenuId");
    } catch (e) {
      _error = 'Erreur chargement consultation: ${e.toString()}';
      print("Erreur loadConsulterMenuById: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === MÉTHODES UTILITAIRES ===

  // "Recherche de consultations (utilise le cache local du service)"
  List<ConsulterMenu> searchConsulterMenus(String query) {
    return _service.searchConsulterMenus(query);
  }

  // "Filtre les consultations par utilisateur"
  List<ConsulterMenu> filterConsulterMenusByUserId(String userId) {
    return _service.filterConsulterMenusByUserId(userId);
  }

  // "Filtre les consultations par menu"
  List<ConsulterMenu> filterConsulterMenusByMenuId(String menuId) {
    return _service.filterConsulterMenusByMenuId(menuId);
  }

  // "Filtre les consultations par date"
  List<ConsulterMenu> filterConsulterMenusByDate(DateTime date) {
    return _service.filterConsulterMenusByDate(date);
  }

  // "Filtre les consultations par période"
  List<ConsulterMenu> filterConsulterMenusByDateRange(
      DateTime startDate, DateTime endDate) {
    return _service.filterConsulterMenusByDateRange(startDate, endDate);
  }

  // "Trie les consultations par date"
  List<ConsulterMenu> sortConsulterMenusByDate(bool ascending) {
    return _service.sortConsulterMenusByDate(ascending);
  }

  // "Trie les consultations par nom de menu"
  List<ConsulterMenu> sortConsulterMenusByMenuName(bool ascending) {
    return _service.sortConsulterMenusByMenuName(ascending);
  }

  // "Trie les consultations par nom d'utilisateur"
  List<ConsulterMenu> sortConsulterMenusByUserName(bool ascending) {
    return _service.sortConsulterMenusByUserName(ascending);
  }

  // "Efface le message d'erreur et notifie l'UI"
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // "Efface la consultation courante et notifie l'UI"
  void clearCurrentConsulterMenu() {
    _currentConsulterMenu = null;
    notifyListeners();
  }

  // "Force le rafraîchissement des données"
  Future<void> refreshData() async {
    await loadAllConsulterMenus(forceRefresh: true);
  }
/* 
  // "Obtient les statistiques de consultation"
  Map<String, dynamic> getConsultationStatistics() {
    return _service.getConsultationStatistics();
  }

  // "Vérifie si un utilisateur a déjà consulté un menu aujourd'hui"
  bool hasUserConsultedMenuToday(String userId, String menuId) {
    return _service.hasUserConsultedMenuToday(userId, menuId);
  }

  // "Obtient le menu le plus consulté"
  String getMostConsultedMenu() {
    return _service.getMostConsultedMenu();
  }

  // "Obtient l'utilisateur qui a le plus consulté de menus"
  String getMostActiveUser() {
    return _service.getMostActiveUser();
  }

  // "Obtient les consultations récentes (derniers 7 jours)"
  List<ConsulterMenu> getRecentConsultations() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _consulterMenus
        .where((consulterMenu) =>
            consulterMenu.consultationDate.isAfter(oneWeekAgo))
        .toList();
  }

  // "Obtient les consultations d'aujourd'hui"
  List<ConsulterMenu> getTodayConsultations() {
    final today = DateTime.now();
    return _consulterMenus
        .where((consulterMenu) =>
            consulterMenu.consultationDate.year == today.year &&
            consulterMenu.consultationDate.month == today.month &&
            consulterMenu.consultationDate.day == today.day)
        .toList();
  }

  // "Obtient le nombre total de consultations"
  int getTotalConsultations() {
    return _consulterMenus.length;
  }

  // "Obtient le nombre de consultations pour un menu spécifique"
  int getConsultationCountForMenu(String menuId) {
    return _consulterMenus
        .where((consulterMenu) => consulterMenu.menu.menuId == menuId)
        .length;
  }

  // "Obtient le nombre de consultations pour un utilisateur spécifique"
  int getConsultationCountForUser(String userId) {
    return _consulterMenus
        .where((consulterMenu) => consulterMenu.userDTO.userId == userId)
        .length;
  }

  // "Enregistre une consultation rapide (avec date actuelle)"
  Future<bool> recordQuickConsultation(
      int userId, int menuId, Menu menu, UserDTO userDTO) async {
    final newConsultation = ConsulterMenu(
      consulterMenuId: '', // "L'ID sera généré par le backend"
      consultationDate: DateTime.now(),
      menu: menu,
      userDTO: userDTO,
    );

    return await createNewConsulterMenu(newConsultation);
  }  */
}
