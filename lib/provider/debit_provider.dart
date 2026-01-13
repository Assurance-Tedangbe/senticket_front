import 'package:flutter/foundation.dart'; // "Importe les bases de Flutter, dont ChangeNotifier"
import 'package:senticket_front/model/debit_model.dart';
import 'package:senticket_front/services/debit_service.dart';

/*
  Rôle Principal: Gestionnaire d'état centralisé pour les débits
  Votre DebitProvider sert de cerveau central qui :
   - Stocke l'état de tous les débits / gère l'état de l'interface utilisateur 
   - Coordonne les opérations CRUD / actions sur les débits 
   - Gère le loading et les erreurs
   - Notifie l'UI des changements / notifie les changements aux écouteurs

  Gère l'état de toutes les opérations du DebitApiService
*/
class DebitProvider with ChangeNotifier {
  // "Crée une classe qui peut notifier ses écouteurs des changements"

  // "_" signifie que ces variables sont privées

  final DebitApiService _service;

  // === INTERNAL STATE FOR ALL OPERATIONS ===

  // "État principal"
  List<Debit> _debits = []; // "Liste vide pour stocker tous les débits"
  Debit? _currentDebit; // "Débit actuellement sélectionné (peut être null)"
  bool _isLoading = false; // "Indicateur de chargement (initialement false)"
  String _error = ''; // "Stocke les messages d'erreur (initialement vide)"

  // "État pour les opérations spécifiques"
  bool _isCreatingDebit = false; // "Création en cours"
  bool _isUpdatingDebit = false; // "Mise à jour en cours"
  bool _isDeletingDebit = false; // "Suppression en cours"
  bool _isLinkingDebit = false; // "Liaison en cours"
  bool _isUnlinkingDebit = false; // "Déliaison en cours"

  DebitProvider(this._service);

  // === GETTERS - Accès contrôlé à l'état ===

  // "Getters principaux"
  List<Debit> get debits =>
      _debits; // "Permet à d'autres classes de lire `_debits` mais pas de le modifier"
  Debit? get currentDebit => _currentDebit;
  bool get isLoading => _isLoading;
  String get error => _error;

  // "Getters pour les états spécifiques"
  bool get isCreatingDebit => _isCreatingDebit;
  bool get isUpdatingDebit => _isUpdatingDebit;
  bool get isDeletingDebit => _isDeletingDebit;
  bool get isLinkingDebit => _isLinkingDebit;
  bool get isUnlinkingDebit => _isUnlinkingDebit;

  // === MÉTHODES D'ACTION - Gestion complète des états ===

  // "Charge tous les débits depuis le service"
  Future<void> loadAllDebits({bool forceRefresh = false}) async {
    // "charge les débits, cela va prendre du temps (async)"

    _isLoading = true; // "active le chargement"
    _error = ''; // "efface les erreurs précédentes"
    notifyListeners(); // "notifie l'UI du début du chargement"

    try {
      _debits = await _service.getAllDebits(
          forceRefresh:
              forceRefresh); // "Demande au service de me donner tous les débits"
      _error = ''; // "Confirme qu'il n'y a pas d'erreurs"
      print("Chargement réussi : ${_debits.length} débits");
    } catch (e) {
      _error = e.toString(); // "Stocke l'erreur"
      print("Erreur loadAllDebits: $e");
    } finally {
      _isLoading = false; // "arrête le chargement"
      notifyListeners(); // "notifie l'UI de la fin du chargement"
    }
  }

  // "Crée un nouveau débit"
  Future<bool> createNewDebit(Debit debit) async {
    // "Je vais créer un débit et je vous dirai si ça a fonctionné (bool)"
    _isCreatingDebit = true;
    _isLoading = true;
    notifyListeners(); // "démarre le travail et notifie l'interface"

    try {
      // "Valide les données avant la création"
      _service.validateDebitData(debit);

      final newDebit = await _service.createDebit(
          debit); // "demande au service de créer ce débit dans l'API"
      _debits.add(
          newDebit); // "Si ça fonctionne, ajoute le nouveau débit à ma liste locale"
      _error = ''; // "Efface les erreurs"
      print("Débit créé avec succès: ${newDebit.debitId}");
      return true; // "Succès"
    } catch (e) {
      _error = 'Erreur création débit: ${e.toString()}';
      print("Erreur createNewDebit: $e");
      return false; // "Échec"
    } finally {
      _isCreatingDebit = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Met à jour un débit existant"
  Future<bool> updateExistingDebit(String debitId, Debit debit) async {
    _isUpdatingDebit = true;
    _isLoading = true;
    notifyListeners();

    try {
      _service.validateDebitData(debit);

      final updatedDebit = await _service.updateDebit(
          debitId, debit); // "demande à l'API de mettre à jour ce débit"

      // "Met à jour dans la liste locale"
      final index = _debits.indexWhere((d) =>
          d.debitId ==
          debitId); // "cherche la position de ce débit dans ma liste"
      if (index != -1) {
        _debits[index] =
            updatedDebit; // "Si j'ai trouvé le débit (index != -1), je remplace l'ancienne version par la nouvelle"
      }

      _error = '';
      print("Débit mis à jour avec succès: ${updatedDebit.debitId}");
      return true;
    } catch (e) {
      _error = 'Erreur mise à jour débit: ${e.toString()}';
      print("Erreur updateExistingDebit: $e");
      return false;
    } finally {
      _isUpdatingDebit = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Supprime un débit"
  Future<bool> deleteExistingDebit(String debitId) async {
    _isDeletingDebit = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteDebit(
          debitId); // "demande à l'API de supprimer le débit avec cet ID"

      // "supprime le débit de la liste locale"
      _debits.removeWhere((debit) => debit.debitId == debitId);

      _error = '';
      print("Débit avec cet ID supprimé: $debitId");
      return true;
    } catch (e) {
      _error = 'Erreur suppression: ${e.toString()}';
      print("Erreur deleteExistingDebit: $e");
      return false;
    } finally {
      _isDeletingDebit = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Charge un débit spécifique par son ID
     Cette méthode retourne void car le résultat est stocké dans _currentDebit */
  Future<void> loadDebitById(String debitId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _currentDebit = await _service.getDebitById(
          debitId); // "demande un débit spécifique par son id à l'API et le stocke dans _currentDebit"
      _error = '';
      print("Débit chargé par ID: $debitId");
    } catch (e) {
      _error = 'Erreur chargement débit: ${e.toString()}';
      print("Erreur loadDebitById: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Lie un débit à un compte"
  Future<bool> linkDebitToAccount(String debitId, String accountId) async {
    _isLinkingDebit = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.linkDebitToAccount(
          debitId, accountId); // "demande à l'API de lier le débit au compte"

      _error = '';
      print("Débit $debitId lié au compte $accountId");
      return true;
    } catch (e) {
      _error = 'Erreur liaison débit-compte: ${e.toString()}';
      print("Erreur linkDebitToAccount: $e");
      return false;
    } finally {
      _isLinkingDebit = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Délie un débit d'un compte"
  Future<bool> unlinkDebitFromAccount(String debitId, String accountId) async {
    _isUnlinkingDebit = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.unlinkDebitFromAccount(
          debitId, accountId); // "demande à l'API de délier le débit du compte"

      _error = '';
      print("Débit $debitId délié du compte $accountId");
      return true;
    } catch (e) {
      _error = 'Erreur déliaison débit-compte: ${e.toString()}';
      print("Erreur unlinkDebitFromAccount: $e");
      return false;
    } finally {
      _isUnlinkingDebit = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // === MÉTHODES UTILITAIRES ===

  // "Recherche de débits (utilise le cache local du service)"
  List<Debit> searchDebits(String query) {
    return _service.searchDebits(query);
  }

  // "Filtre les débits par compte"
  List<Debit> filterDebitsByAccountId(String accountId) {
    return _service.filterDebitsByAccountId(accountId);
  }

  // "Filtre les débits par utilisateur"
  List<Debit> filterDebitsByUserId(String userId) {
    return _service.filterDebitsByUserId(userId);
  }

  // "Filtre les débits par date"
  List<Debit> filterDebitsByDate(DateTime date) {
    return _service.filterDebitsByDate(date);
  }

  // "Filtre les débits par période"
  List<Debit> filterDebitsByDateRange(DateTime startDate, DateTime endDate) {
    return _service.filterDebitsByDateRange(startDate, endDate);
  }

  // "Filtre les débits par montant minimum"
  List<Debit> filterDebitsByMinAmount(double minAmount) {
    return _service.filterDebitsByMinAmount(minAmount);
  }

  // "Filtre les débits par montant maximum"
  List<Debit> filterDebitsByMaxAmount(double maxAmount) {
    return _service.filterDebitsByMaxAmount(maxAmount);
  }

  // "Trie les débits par date"
  List<Debit> sortDebitsByDate(bool ascending) {
    return _service.sortDebitsByDate(ascending);
  }

  // "Trie les débits par montant"
  List<Debit> sortDebitsByAmount(bool ascending) {
    return _service.sortDebitsByAmount(ascending);
  }

  // "Trie les débits par nom d'utilisateur"
  List<Debit> sortDebitsByUserName(bool ascending) {
    return _service.sortDebitsByUserName(ascending);
  }

  // "Trie les débits par numéro de compte"
  List<Debit> sortDebitsByAccountNumber(bool ascending) {
    return _service.sortDebitsByAccountNumber(ascending);
  }

  // "Efface le message d'erreur et notifie l'UI"
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // "Efface le débit courant et notifie l'UI"
  void clearCurrentDebit() {
    _currentDebit = null;
    notifyListeners();
  }

  // "Force le rafraîchissement des données"
  Future<void> refreshData() async {
    await loadAllDebits(forceRefresh: true);
  }

  // "Obtient les statistiques des débits"
  Map<String, dynamic> getDebitStatistics() {
    return _service.getDebitStatistics();
  }

  // "Obtient le total des débits pour un compte spécifique"
  double getTotalDebitsForAccount(String accountId) {
    return _service.getTotalDebitsForAccount(accountId);
  }

  // "Obtient le total des débits pour un utilisateur spécifique"
  double getTotalDebitsForUser(String userId) {
    return _service.getTotalDebitsForUser(userId);
  }

  // "Obtient le compte avec le plus de débits"
  String getAccountWithMostDebits() {
    return _service.getAccountWithMostDebits();
  }

  // "Obtient l'utilisateur avec le plus de débits"
  String getUserWithMostDebits() {
    return _service.getUserWithMostDebits();
  }
/* 
  // "Obtient les débits récents (derniers 30 jours)"
  List<Debit> getRecentDebits() {
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    return _debits
        .where((debit) => debit.debitDate.isAfter(oneMonthAgo))
        .toList();
  }

  // "Obtient les débits d'aujourd'hui"
  List<Debit> getTodayDebits() {
    final today = DateTime.now();
    return _debits
        .where((debit) =>
            debit.debitDate.year == today.year &&
            debit.debitDate.month == today.month &&
            debit.debitDate.day == today.day)
        .toList();
  }

  // "Obtient le nombre total de débits"
  int getTotalDebits() {
    return _debits.length;
  }

  // "Obtient le montant total de tous les débits"
  double getTotalDebitsAmount() {
    return _debits.fold(0.0, (sum, debit) => sum + debit.debitAmount);
  }

  // "Obtient le montant moyen des débits"
  double getAverageDebitAmount() {
    return _debits.isEmpty ? 0.0 : getTotalDebitsAmount() / _debits.length;
  }

  // "Obtient le débit le plus élevé"
  Debit? getHighestDebit() {
    if (_debits.isEmpty) return null;
    return _debits.reduce((a, b) => a.debitAmount > b.debitAmount ? a : b);
  }

  // "Obtient le débit le plus bas"
  Debit? getLowestDebit() {
    if (_debits.isEmpty) return null;
    return _debits.reduce((a, b) => a.debitAmount < b.debitAmount ? a : b);
  }

  // "Crée un débit rapide (avec date actuelle)"
  Future<bool> createQuickDebit(
      double amount, AccountDTO accountDTO, UserDTO userDTO) async {
    final newDebit = Debit(
      debitDate: DateTime.now(),
      debitAmount: amount,
      accountDTO: accountDTO,
      userDTO: userDTO,
    );

    return await createNewDebit(newDebit);
  }

  // "Vérifie si un compte a des débits en attente"
  bool hasPendingDebits(String accountId) {
    return _debits.any((debit) =>
        debit.accountDTO.accountId == accountId &&
        debit.debitDate
            .isAfter(DateTime.now().subtract(const Duration(days: 30))));
  }

  // "Obtient le solde net (crédits - débits) pour un compte"
  double getNetBalanceForAccount(String accountId, double totalCredits) {
    final totalDebits = getTotalDebitsForAccount(accountId);
    return totalCredits - totalDebits;
  } */
}
