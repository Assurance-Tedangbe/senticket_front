import 'package:flutter/foundation.dart';
import 'package:senticket_front/model/role_model.dart';
import 'package:senticket_front/services/role_service.dart';

class RoleProvider with ChangeNotifier {
  final RoleApiService _roleservice;

  // === ÉTAT INTERNE - GESTION COMPLÈTE DE TOUS LES ÉTATS ===

  // État principal de l'application
  List<Role> _roles = []; // Liste principale des rôles
  Role? _currentRole; // Rôle actuellement sélectionné ou visualisé
  bool _isLoading = false; // Indicateur de chargement global
  String _error = ''; // Message d'erreur global

  // État spécifique pour chaque type d'opération
  bool _isCreatingRole = false; // Indique si une création est en cours
  bool _isUpdatingRole = false; // Indique si une mise à jour est en cours
  bool _isDeletingRole = false; // Indique si une suppression est en cours
  bool _isFetchingRole =
      false; // Indique si une récupération spécifique est en cours

  // Messages d'erreur spécifiques à chaque opération
  String _createRoleError = ''; // Erreur spécifique à la création
  String _updateRoleError = ''; // Erreur spécifique à la mise à jour
  String _deleteRoleError = ''; // Erreur spécifique à la suppression
  String _fetchRoleError = ''; // Erreur spécifique à la récupération

  /// Constructeur avec injection de dépendance
  RoleProvider(this._roleservice);

  // === GETTERS - ACCÈS CONTRÔLÉ À L'ÉTAT ===

  // Getters principaux pour l'état global
  List<Role> get roles => _roles; // Liste immuable des rôles
  Role? get currentRole => _currentRole; // Rôle courant (peut être null)
  bool get isLoading => _isLoading; // État de chargement global
  String get error => _error; // Erreur globale

  // Getters pour les états spécifiques des opérations
  bool get isCreatingRole => _isCreatingRole; // État création
  bool get isUpdatingRole => _isUpdatingRole; // État mise à jour
  bool get isDeletingRole => _isDeletingRole; // État suppression
  bool get isFetchingRole => _isFetchingRole; // État récupération

  // Getters pour les erreurs spécifiques des opérations
  String get createRoleError => _createRoleError; // Erreur création
  String get updateRoleError => _updateRoleError; // Erreur mise à jour
  String get deleteRoleError => _deleteRoleError; // Erreur suppression
  String get fetchRoleError => _fetchRoleError; // Erreur récupération

  // === MÉTHODES D'ACTION PRINCIPALES ===

  // ************************ READ ALL ROLES **************************

  Future<void> loadAllRoles({bool forceRefresh = false}) async {
    _isLoading = true; // Active l'indicateur de chargement global
    _error = ''; // Réinitialise les erreurs globales
    notifyListeners(); // Notifie immédiatement l'UI du début du chargement

    try {
      // Délégation au service combiné (qui gère le cache)
      _roles = await _roleservice.getAllRoles(forceRefresh: forceRefresh);
      _error = ''; // Confirme le succès de l'opération
      print("✅ Chargement des rôles réussi - ${_roles.length} rôles chargés");
    } catch (e) {
      _error = 'Erreur lors du chargement des rôles: ${e.toString()}';
      print(" Erreur dans loadAllRoles: $e");
    } finally {
      _isLoading = false; // Désactive le chargement dans tous les cas
      notifyListeners(); // Notifie l'UI de la fin de l'opération
    }
  }
}
  /*            SUPPL METHODS 
 // ************************** CREATE ROLE ***************************

  /* Crée un nouveau rôle avec gestion complète de l'état */
  Future<bool> createNewRole(Role role) async {
    _isCreatingRole = true; // Active l'état spécifique de création
    _createRoleError = ''; // Réinitialise l'erreur de création
    _isLoading = true; // Active aussi le chargement global
    notifyListeners(); // Notifie le début de l'opération

    try {
      // Délégation au service combiné (qui valide et appelle l'API)
      final newRole = await _roleservice.createRole(role);
      _roles.add(newRole); // Ajoute le nouveau rôle à la liste locale

      _createRoleError = ''; // Confirme le succès
      _error = ''; // Réinitialise l'erreur globale
      print("✅ Rôle créé avec succès: ${newRole.name}");
      return true; // Indique le succès à l'appelant
    } catch (e) {
      _createRoleError = 'Erreur lors de la création: ${e.toString()}';
      _error = 'Erreur lors de la création: ${e.toString()}';
      print(" Erreur dans createNewRole: $e");
      return false; // Indique l'échec à l'appelant
    } finally {
      _isCreatingRole = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ************************** UPDATE ROLE ***************************
  Future<bool> updateExistingRole(Role role) async {
    _isUpdatingRole = true; // Active l'état spécifique de mise à jour
    _updateRoleError = ''; // Réinitialise l'erreur de mise à jour
    _isLoading = true;
    notifyListeners();

    try {
      // Délégation au service combiné
      final updatedRole = await _roleservice.updateRole(role);

      // Met à jour le rôle dans la liste locale
      final index = _roles.indexWhere((r) => r.roleId == role.roleId);
      if (index != -1) {
        _roles[index] = updatedRole;
      }

      // Met à jour le rôle courant si c'est celui qui a été modifié
      if (_currentRole?.roleId == role.roleId) {
        _currentRole = updatedRole;
      }

      _updateRoleError = ''; // Confirme le succès
      _error = ''; // Réinitialise l'erreur globale
      print("✅ Rôle mis à jour avec succès: ${updatedRole.name}");
      return true;
    } catch (e) {
      _updateRoleError = 'Erreur lors de la mise à jour: ${e.toString()}';
      _error = 'Erreur lors de la mise à jour: ${e.toString()}';
      print(" Erreur dans updateExistingRole: $e");
      return false;
    } finally {
      _isUpdatingRole = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ************************** DELETE ROLE ***************************
  Future<bool> deleteExistingRole(int roleId) async {
    _isDeletingRole = true; // Active l'état spécifique de suppression
    _deleteRoleError = ''; // Réinitialise l'erreur de suppression
    _isLoading = true;
    notifyListeners();

    try {
      // Délégation au service combiné
      await _roleservice.deleteRole(roleId);

      // Supprime le rôle de la liste locale
      _roles.removeWhere((role) => role.roleId == roleId);

      // Efface le rôle courant si c'est celui qui a été supprimé
      if (_currentRole?.roleId == roleId) {
        _currentRole = null;
      }

      _deleteRoleError = ''; // Confirme le succès
      _error = ''; // Réinitialise l'erreur globale
      print("✅ Rôle supprimé avec succès - ID: $roleId");
      return true;
    } catch (e) {
      _deleteRoleError = 'Erreur lors de la suppression: ${e.toString()}';
      _error = 'Erreur lors de la suppression: ${e.toString()}';
      print(" Erreur dans deleteExistingRole: $e");
      return false;
    } finally {
      _isDeletingRole = false; // Désactive l'état spécifique
      _isLoading = false;
      notifyListeners();
    }
  }

  // ************************** READ SINGLE ROLE ***************************
  Future<void> loadRoleById(int roleId) async {
    _isFetchingRole = true; // Active l'état spécifique de récupération
    _fetchRoleError = ''; // Réinitialise l'erreur de récupération
    _isLoading = true;
    notifyListeners();

    try {
      // Délégation au service combiné
      _currentRole = await _roleservice.getRoleById(roleId);
      _fetchRoleError = ''; // Confirme le succès
      _error = ''; // Réinitialise l'erreur globale
      print("✅ Rôle chargé avec succès - ID: $roleId");
    } catch (e) {
      _fetchRoleError = 'Erreur lors du chargement: ${e.toString()}';
      _error = 'Erreur lors du chargement: ${e.toString()}';
      print(" Erreur dans loadRoleById: $e");
    } finally {
      _isFetchingRole = false; // Désactive l'état spécifique
      _isLoading = false;
      notifyListeners();
    }
  }

  // ************************** READ SINGLE ROLE BY NAME ***************************
  Future<void> loadRoleByName(String roleName) async {
    _isFetchingRole = true; // Active l'état spécifique de récupération
    _fetchRoleError = ''; // Réinitialise l'erreur de récupération
    _isLoading = true;
    notifyListeners();

    try {
      // Délégation au service combiné
      _currentRole = await _roleservice.getRoleByName(roleName);
      _fetchRoleError = ''; // Confirme le succès
      _error = ''; // Réinitialise l'erreur globale
      print("✅ Rôle chargé avec succès - Nom: $roleName");
    } catch (e) {
      _fetchRoleError = 'Erreur lors du chargement: ${e.toString()}';
      _error = 'Erreur lors du chargement: ${e.toString()}';
      print(" Erreur dans loadRoleByName: $e");
    } finally {
      _isFetchingRole = false; // Désactive l'état spécifique
      _isLoading = false;
      notifyListeners();
    }
  } 

  // === MÉTHODES UTILITAIRES - OPÉRATIONS LOCALES ===

  // Recherche des rôles dans les données locales (utilisation du cache du service)
  List<Role> searchRoles(String query) {
    return _roleservice.searchRoles(query);
  }

  // Récupère les rôles correspondant à un pattern (pour auto-complétion)
  List<Role> getRolesByPattern(String pattern) {
    return _roleservice.getRolesByPattern(pattern);
  }

  // Vérifie si un rôle existe déjà pour éviter les doublons
  bool roleExists(String roleName) {
    return _roleservice.roleExists(roleName);
  }

  // Récupère les rôles les plus utilisés (logique métier)
  List<Role> getMostUsedRoles([int limit = 5]) {
    return _roleservice.getMostUsedRoles(limit);
  }

  // Récupère un rôle par son ID depuis le cache local uniquement
  Role? getRoleFromCache(int roleId) {
    try {
      return _roles.firstWhere((role) => role.roleId == roleId);
    } catch (e) {
      return null; // Retourne null si non trouvé
    }
  }

  // Récupère un rôle par son nom depuis le cache local uniquement
  Role? getRoleByNameFromCache(String roleName) {
    try {
      return _roles.firstWhere(
        (role) => role.name.toLowerCase() == roleName.toLowerCase(),
      );
    } catch (e) {
      return null; // Retourne null si non trouvé
    }
  }

  // === MÉTHODES DE NETTOYAGE ET RÉINITIALISATION ===

  // Efface TOUS les messages d'erreur
  void clearAllErrors() {
    _error = '';
    _createRoleError = '';
    _updateRoleError = '';
    _deleteRoleError = '';
    _fetchRoleError = '';
    notifyListeners();
  }

  // Efface le rôle courant (utile pour la navigation)
  void clearCurrentRole() {
    _currentRole = null;
    notifyListeners();
  }

  // Force le rafraîchissement complet des données (ignore le cache)
  Future<void> refreshData() async {
    await loadAllRoles(forceRefresh: true);
  }

  // Vide le cache du service (utile pour les tests ou déconnexion)
  void clearCache() {
    _roleservice.clearCache();
    print("🗑️ Cache des rôles vidé via Provider");
  }
  */


/* 
 FONCTIONNALITÉS AVANCÉES fournis par le service et le provider de role:

 Cache intelligent avec expiration et fallback réseau

 Validation des données conforme aux annotations Spring Boot

 Gestion d'état complète pour toutes les opérations

 Messages d'erreur spécifiques par type d'opération

 Recherche et filtrage local haute performance

 Méthodes utilitaires pour une meilleure expérience développeur
*/
