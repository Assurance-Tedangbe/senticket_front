import 'package:flutter/foundation.dart'; // "Importe les bases de Flutter, dont ChangeNotifier"
import 'package:senticket_front/model/credit_model.dart';
import 'package:senticket_front/services/credit_service.dart';

/*
  Rôle Principal: Gestionnaire d'état centralisé pour les crédits
  Votre CreditProvider sert de cerveau central qui :
   - Stocke l'état de tous les crédits / gère l'état de l'interface utilisateur 
   - Coordonne les opérations CRUD / actions sur les crédits 
   - Gère le loading et les erreurs
   - Notifie l'UI des changements / notifie les changements aux écouteurs

  Gère l'état de toutes les opérations du CreditApiService
*/
class CreditProvider with ChangeNotifier {
  // "Crée une classe qui peut notifier ses écouteurs des changements"

  // "_" signifie que ces variables sont privées

  final CreditApiService _service;

  // === INTERNAL STATE FOR ALL OPERATIONS ===

  // "État principal"
  List<Credit> _credits = []; // "Liste vide pour stocker tous les crédits"
  Credit? _currentCredit; // "Crédit actuellement sélectionné (peut être null)"
  bool _isLoading = false; // "Indicateur de chargement (initialement false)"
  String _error = ''; // "Stocke les messages d'erreur (initialement vide)"

  // "État pour les opérations spécifiques"
  bool _isCreatingCredit = false; // "Création en cours"
  bool _isUpdatingCredit = false; // "Mise à jour en cours"
  bool _isDeletingCredit = false; // "Suppression en cours"
  bool _isLinkingCredit = false; // "Liaison en cours"
  bool _isUnlinkingCredit = false; // "Déliaison en cours"

  CreditProvider(this._service);

  // === GETTERS - Accès contrôlé à l'état ===

  // "Getters principaux"
  List<Credit> get credits =>
      _credits; // "Permet à d'autres classes de lire `_credits` mais pas de le modifier"
  Credit? get currentCredit => _currentCredit;
  bool get isLoading => _isLoading;
  String get error => _error;

  // "Getters pour les états spécifiques"
  bool get isCreatingCredit => _isCreatingCredit;
  bool get isUpdatingCredit => _isUpdatingCredit;
  bool get isDeletingCredit => _isDeletingCredit;
  bool get isLinkingCredit => _isLinkingCredit;
  bool get isUnlinkingCredit => _isUnlinkingCredit;

  // === MÉTHODES D'ACTION - Gestion complète des états ===

  // "Charge tous les crédits depuis le service"
  Future<void> loadAllCredits({bool forceRefresh = false}) async {
    // "charge les crédits, cela va prendre du temps (async)"

    _isLoading = true; // "active le chargement"
    _error = ''; // "efface les erreurs précédentes"
    notifyListeners(); // "notifie l'UI du début du chargement"

    try {
      _credits = await _service.getAllCredits(
          forceRefresh:
              forceRefresh); // "Demande au service de me donner tous les crédits"
      _error = ''; // "Confirme qu'il n'y a pas d'erreurs"
      print("Chargement réussi : ${_credits.length} crédits");
    } catch (e) {
      _error = e.toString(); // "Stocke l'erreur"
      print("Erreur loadAllCredits: $e");
    } finally {
      _isLoading = false; // "arrête le chargement"
      notifyListeners(); // "notifie l'UI de la fin du chargement"
    }
  }

  // "Crée un nouveau crédit"
  Future<bool> createNewCredit(Credit credit) async {
    // "Je vais créer un crédit et je vous dirai si ça a fonctionné (bool)"
    _isCreatingCredit = true;
    _isLoading = true;
    notifyListeners(); // "démarre le travail et notifie l'interface"

    try {
      // "Valide les données avant la création"
      _service.validateCreditData(credit);

      final newCredit = await _service.createCredit(
          credit); // "demande au service de créer ce crédit dans l'API"
      _credits.add(
          newCredit); // "Si ça fonctionne, ajoute le nouveau crédit à ma liste locale"
      _error = ''; // "Efface les erreurs"
      print("Crédit créé avec succès: ${newCredit.creditId}");
      return true; // "Succès"
    } catch (e) {
      _error = 'Erreur création crédit: ${e.toString()}';
      print("Erreur createNewCredit: $e");
      return false; // "Échec"
    } finally {
      _isCreatingCredit = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Met à jour un crédit existant"
  Future<bool> updateExistingCredit(String creditId, Credit credit) async {
    _isUpdatingCredit = true;
    _isLoading = true;
    notifyListeners();

    try {
      _service.validateCreditData(credit);

      final updatedCredit = await _service.updateCredit(
          creditId, credit); // "demande à l'API de mettre à jour ce crédit"

      // "Met à jour dans la liste locale"
      final index = _credits.indexWhere((c) =>
          c.creditId ==
          creditId); // "cherche la position de ce crédit dans ma liste"
      if (index != -1) {
        _credits[index] =
            updatedCredit; // "Si j'ai trouvé le crédit (index != -1), je remplace l'ancienne version par la nouvelle"
      }

      _error = '';
      print("Crédit mis à jour avec succès: ${updatedCredit.creditId}");
      return true;
    } catch (e) {
      _error = 'Erreur mise à jour crédit: ${e.toString()}';
      print("Erreur updateExistingCredit: $e");
      return false;
    } finally {
      _isUpdatingCredit = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Supprime un crédit"
  Future<bool> deleteExistingCredit(String creditId) async {
    _isDeletingCredit = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteCredit(
          creditId); // "demande à l'API de supprimer le crédit avec cet ID"

      // "supprime le crédit de la liste locale"
      _credits.removeWhere((credit) => credit.creditId == creditId);

      _error = '';
      print("Crédit avec cet ID supprimé: $creditId");
      return true;
    } catch (e) {
      _error = 'Erreur suppression: ${e.toString()}';
      print("Erreur deleteExistingCredit: $e");
      return false;
    } finally {
      _isDeletingCredit = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Charge un crédit spécifique par son ID
     Cette méthode retourne void car le résultat est stocké dans _currentCredit */
  Future<void> loadCreditById(String creditId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _currentCredit = await _service.getCreditById(
          creditId); // "demande un crédit spécifique par son id à l'API et le stocke dans _currentCredit"
      _error = '';
      print("Crédit chargé par ID: $creditId");
    } catch (e) {
      _error = 'Erreur chargement crédit: ${e.toString()}';
      print("Erreur loadCreditById: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Lie un crédit à un compte"
  Future<bool> linkCreditToAccount(String creditId, String accountId) async {
    _isLinkingCredit = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.linkCreditToAccount(
          creditId, accountId); // "demande à l'API de lier le crédit au compte"

      _error = '';
      print("Crédit $creditId lié au compte $accountId");
      return true;
    } catch (e) {
      _error = 'Erreur liaison crédit-compte: ${e.toString()}';
      print("Erreur linkCreditToAccount: $e");
      return false;
    } finally {
      _isLinkingCredit = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Délie un crédit d'un compte"
  Future<bool> unlinkCreditFromAccount(
      String creditId, String accountId) async {
    _isUnlinkingCredit = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.unlinkCreditFromAccount(creditId,
          accountId); // "demande à l'API de délier le crédit du compte"

      _error = '';
      print("Crédit $creditId délié du compte $accountId");
      return true;
    } catch (e) {
      _error = 'Erreur déliaison crédit-compte: ${e.toString()}';
      print("Erreur unlinkCreditFromAccount: $e");
      return false;
    } finally {
      _isUnlinkingCredit = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // === MÉTHODES UTILITAIRES ===

  // "Recherche de crédits (utilise le cache local du service)"
  List<Credit> searchCredits(String query) {
    return _service.searchCredits(query);
  }

  // "Filtre les crédits par compte"
  List<Credit> filterCreditsByAccountId(String accountId) {
    return _service.filterCreditsByAccountId(accountId);
  }

  // "Filtre les crédits par utilisateur"
  List<Credit> filterCreditsByUserId(String userId) {
    return _service.filterCreditsByUserId(userId);
  }

  // "Filtre les crédits par date"
  List<Credit> filterCreditsByDate(DateTime date) {
    return _service.filterCreditsByDate(date);
  }

  // "Filtre les crédits par période"
  List<Credit> filterCreditsByDateRange(DateTime startDate, DateTime endDate) {
    return _service.filterCreditsByDateRange(startDate, endDate);
  }

  // "Filtre les crédits par montant minimum"
  List<Credit> filterCreditsByMinAmount(double minAmount) {
    return _service.filterCreditsByMinAmount(minAmount);
  }

  // "Filtre les crédits par montant maximum"
  List<Credit> filterCreditsByMaxAmount(double maxAmount) {
    return _service.filterCreditsByMaxAmount(maxAmount);
  }

  // "Trie les crédits par date"
  List<Credit> sortCreditsByDate(bool ascending) {
    return _service.sortCreditsByDate(ascending);
  }

  // "Trie les crédits par montant"
  List<Credit> sortCreditsByAmount(bool ascending) {
    return _service.sortCreditsByAmount(ascending);
  }

  // "Trie les crédits par nom d'utilisateur"
  List<Credit> sortCreditsByUserName(bool ascending) {
    return _service.sortCreditsByUserName(ascending);
  }

  // "Trie les crédits par numéro de compte"
  List<Credit> sortCreditsByAccountNumber(bool ascending) {
    return _service.sortCreditsByAccountNumber(ascending);
  }

  // "Efface le message d'erreur et notifie l'UI"
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // "Efface le crédit courant et notifie l'UI"
  void clearCurrentCredit() {
    _currentCredit = null;
    notifyListeners();
  }

  // "Force le rafraîchissement des données"
  Future<void> refreshData() async {
    await loadAllCredits(forceRefresh: true);
  }

  // "Obtient les statistiques des crédits"
  Map<String, dynamic> getCreditStatistics() {
    return _service.getCreditStatistics();
  }

  // "Obtient le total des crédits pour un compte spécifique"
  double getTotalCreditsForAccount(String accountId) {
    return _service.getTotalCreditsForAccount(accountId);
  }

  // "Obtient le total des crédits pour un utilisateur spécifique"
  double getTotalCreditsForUser(String userId) {
    return _service.getTotalCreditsForUser(userId);
  }

  // "Obtient le compte avec le plus de crédits"
  String getAccountWithMostCredits() {
    return _service.getAccountWithMostCredits();
  }

  // "Obtient l'utilisateur avec le plus de crédits"
  String getUserWithMostCredits() {
    return _service.getUserWithMostCredits();
  }
/* 
  // "Obtient les crédits récents (derniers 30 jours)"
  List<Credit> getRecentCredits() {
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    return _credits
        .where((credit) => credit.creditDate.isAfter(oneMonthAgo))
        .toList();
  }

  // "Obtient les crédits d'aujourd'hui"
  List<Credit> getTodayCredits() {
    final today = DateTime.now();
    return _credits
        .where((credit) =>
            credit.creditDate.year == today.year &&
            credit.creditDate.month == today.month &&
            credit.creditDate.day == today.day)
        .toList();
  }

  // "Obtient le nombre total de crédits"
  int getTotalCredits() {
    return _credits.length;
  }

  // "Obtient le montant total de tous les crédits"
  double getTotalCreditsAmount() {
    return _credits.fold(0.0, (sum, credit) => sum + credit.creditAmount);
  }

  // "Obtient le montant moyen des crédits"
  double getAverageCreditAmount() {
    return _credits.isEmpty ? 0.0 : getTotalCreditsAmount() / _credits.length;
  }

  // "Obtient le crédit le plus élevé"
  Credit? getHighestCredit() {
    if (_credits.isEmpty) return null;
    return _credits.reduce((a, b) => a.creditAmount > b.creditAmount ? a : b);
  }

  // "Obtient le crédit le plus bas"
  Credit? getLowestCredit() {
    if (_credits.isEmpty) return null;
    return _credits.reduce((a, b) => a.creditAmount < b.creditAmount ? a : b);
  }

   // "Crée un crédit rapide (avec date actuelle)"
  Future<bool> createQuickCredit(
      double amount, AccountDTO accountDTO, UserDTO userDTO) async {
    final newCredit = Credit(
      creditDate: DateTime.now(),
      creditAmount: amount,
      accountDTO: accountDTO,
      userDTO: userDTO,
    );

    return await createNewCredit(newCredit);
  }  */
}
