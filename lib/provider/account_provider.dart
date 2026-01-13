/* import 'package:flutter/foundation.dart';
import 'package:senticket_front/model/account_model.dart';
import 'package:senticket_front/services/account_service.dart';

/*
  Rôle Principal: Gestionnaire d'état centralisé pour les comptes
  Votre AccountProvider sert de cerveau central qui :
   - Stocke l'état de tous les comptes / gère l'état de l'interface utilisateur 
   - Coordonne les opérations CRUD / actions sur les comptes 
   - Gère le loading et les erreurs
   - Notifie l'UI des changements / notifie les changements aux écouteurs

  Gère l'état de toutes les opérations du AccountApiService
*/
class AccountProvider with ChangeNotifier {
  // "Crée une classe qui peut notifier ses écouteurs des changements"

  // "_" signifie que ces variables sont privées

  final AccountApiService _service;

  // === INTERNAL STATE FOR ALL OPERATIONS ===

  // "État principal"
  List<Account> _accounts = []; // "Liste vide pour stocker tous les comptes"
  Account?
      _currentAccount; // "Compte actuellement sélectionné (peut être null)"
  bool _isLoading = false; // "Indicateur de chargement (initialement false)"
  String _error = ''; // "Stocke les messages d'erreur (initialement vide)"

  // "État pour les opérations spécifiques"
  bool _isCreatingAccount = false; // "Création en cours"
  bool _isUpdatingAccount = false; // "Mise à jour en cours"
  bool _isDeletingAccount = false; // "Suppression en cours"
  bool _isLinkingAccount = false; // "Liaison en cours"
  bool _isUnlinkingAccount = false; // "Déliaison en cours"
  bool _isUpdatingBalance = false; // "Mise à jour solde en cours"
  bool _isUpdatingAccountNumber = false; // "Mise à jour numéro en cours"
  bool _isActivatingAccount = false; // "Activation en cours"
  bool _isDeactivatingAccount = false; // "Désactivation en cours"
  bool _isTransferringFunds = false; // "Transfert en cours"
  bool _isCancelingTransfer = false; // "Annulation transfert en cours"
  bool _isCreditingAccount = false; // "Crédit en cours"
  bool _isCancelingCredit = false; // "Annulation crédit en cours"

  AccountProvider(this._service);

  // === GETTERS - Accès contrôlé à l'état ===

  // "Getters principaux"
  List<Account> get accounts =>
      _accounts; // "Permet à d'autres classes de lire `_accounts` mais pas de le modifier"
  Account? get currentAccount => _currentAccount;
  bool get isLoading => _isLoading;
  String get error => _error;

  // "Getters pour les états spécifiques"
  bool get isCreatingAccount => _isCreatingAccount;
  bool get isUpdatingAccount => _isUpdatingAccount;
  bool get isDeletingAccount => _isDeletingAccount;
  bool get isLinkingAccount => _isLinkingAccount;
  bool get isUnlinkingAccount => _isUnlinkingAccount;
  bool get isUpdatingBalance => _isUpdatingBalance;
  bool get isUpdatingAccountNumber => _isUpdatingAccountNumber;
  bool get isActivatingAccount => _isActivatingAccount;
  bool get isDeactivatingAccount => _isDeactivatingAccount;
  bool get isTransferringFunds => _isTransferringFunds;
  bool get isCancelingTransfer => _isCancelingTransfer;
  bool get isCreditingAccount => _isCreditingAccount;
  bool get isCancelingCredit => _isCancelingCredit;

  // === MÉTHODES D'ACTION - Gestion complète des états ===

  // "Charge tous les comptes depuis le service"
  Future<void> loadAllAccounts({bool forceRefresh = false}) async {
    // "charge les comptes, cela va prendre du temps (async)"

    _isLoading = true; // "active le chargement"
    _error = ''; // "efface les erreurs précédentes"
    notifyListeners(); // "notifie l'UI du début du chargement"

    try {
      _accounts = await _service.getAllAccounts(
          forceRefresh:
              forceRefresh); // "Demande au service de me donner tous les comptes"
      _error = ''; // "Confirme qu'il n'y a pas d'erreurs"
      print("Chargement réussi : ${_accounts.length} comptes");
    } catch (e) {
      _error = e.toString(); // "Stocke l'erreur"
      print("Erreur loadAllAccounts: $e");
    } finally {
      _isLoading = false; // "arrête le chargement"
      notifyListeners(); // "notifie l'UI de la fin du chargement"
    }
  }

  // "Crée un nouveau compte"
  Future<bool> createNewAccount(Account account) async {
    // "Je vais créer un compte et je vous dirai si ça a fonctionné (bool)"
    _isCreatingAccount = true;
    _isLoading = true;
    notifyListeners(); // "démarre le travail et notifie l'interface"

    try {
      // "Valide les données avant la création"
      _service.validateAccountData(account);

      final newAccount = await _service.createAccount(
          account); // "demande au service de créer ce compte dans l'API"
      _accounts.add(
          newAccount); // "Si ça fonctionne, ajoute le nouveau compte à ma liste locale"
      _error = ''; // "Efface les erreurs"
      print("Compte créé avec succès: ${newAccount.accountNumber}");
      return true; // "Succès"
    } catch (e) {
      _error = 'Erreur création: ${e.toString()}';
      print("Erreur createNewAccount: $e");
      return false; // "Échec"
    } finally {
      _isCreatingAccount = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Met à jour un compte existant"
  Future<bool> updateExistingAccount(Account account) async {
    _isUpdatingAccount = true;
    _isLoading = true;
    notifyListeners();

    try {
      _service.validateAccountData(account);

      final updatedAccount = await _service.updateAccount(
          account); // "demande à l'API de mettre à jour ce compte"

      // "Met à jour dans la liste locale"
      final index = _accounts.indexWhere((a) =>
          a.accountId ==
          account
              .accountId); // "cherche la position de ce compte dans ma liste"
      if (index != -1) {
        _accounts[index] =
            updatedAccount; // "Si j'ai trouvé le compte (index != -1), je remplace l'ancienne version par la nouvelle"
      }

      _error = '';
      print("Compte mis à jour avec succès: ${updatedAccount.accountNumber}");
      return true;
    } catch (e) {
      _error = 'Erreur mise à jour compte: ${e.toString()}';
      print("Erreur updateExistingAccount: $e");
      return false;
    } finally {
      _isUpdatingAccount = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Supprime un compte"
  Future<bool> deleteExistingAccount(String accountId) async {
    _isDeletingAccount = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteAccount(
          accountId); // "demande à l'API de supprimer le compte avec cet ID"

      // "supprime le compte de la liste locale"
      _accounts.removeWhere((account) => account.accountId == accountId);

      _error = '';
      print("Compte avec cet ID supprimé: $accountId");
      return true;
    } catch (e) {
      _error = 'Erreur suppression: ${e.toString()}';
      print("Erreur deleteExistingAccount: $e");
      return false;
    } finally {
      _isDeletingAccount = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /* Charge un compte spécifique par son ID
     Cette méthode retourne void car le résultat est stocké dans _currentAccount */
  Future<void> loadAccountById(String accountId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _currentAccount = await _service.getAccountById(
          accountId); // "demande un compte spécifique par son id à l'API et le stocke dans _currentAccount"
      _error = '';
      print("Compte chargé par ID: $accountId");
    } catch (e) {
      _error = 'Erreur chargement compte: ${e.toString()}';
      print("Erreur loadAccountById: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Lie un compte à un utilisateur"
  Future<bool> linkAccountToUser(String accountId, String userId) async {
    _isLinkingAccount = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.linkAccountToUser(accountId,
          userId); // "demande à l'API de lier le compte à l'utilisateur"

      _error = '';
      print("Compte $accountId lié à l'utilisateur $userId");
      return true;
    } catch (e) {
      _error = 'Erreur liaison compte-utilisateur: ${e.toString()}';
      print("Erreur linkAccountToUser: $e");
      return false;
    } finally {
      _isLinkingAccount = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Délie un compte d'un utilisateur"
  Future<bool> unlinkAccountFromUser(String accountId, String userId) async {
    _isUnlinkingAccount = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.unlinkAccountFromUser(accountId,
          userId); // "demande à l'API de délier le compte de l'utilisateur"

      _error = '';
      print("Compte $accountId délié de l'utilisateur $userId");
      return true;
    } catch (e) {
      _error = 'Erreur déliaison compte-utilisateur: ${e.toString()}';
      print("Erreur unlinkAccountFromUser: $e");
      return false;
    } finally {
      _isUnlinkingAccount = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Met à jour le solde d'un compte"
  Future<bool> updateAccountBalance(String accountId, double newBalance) async {
    _isUpdatingBalance = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateAccountBalance(accountId,
          newBalance); // "demande à l'API de mettre à jour le solde de ce compte"

      _error = '';
      print(
          "Solde mis à jour avec succès pour le compte $accountId newBalance: $newBalance");
      return true;
    } catch (e) {
      _error = 'Erreur mise à jour solde: ${e.toString()}';
      print("Erreur updateAccountBalance: $e");
      return false;
    } finally {
      _isUpdatingBalance = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Met à jour le numéro de compte"
  Future<bool> updateAccountNumber(
      String accountId, String newAccountNumber) async {
    _isUpdatingAccountNumber = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateAccountNumber(accountId,
          newAccountNumber); // "demande à l'API de mettre à jour le numéro de compte"

      _error = '';
      print(
          "Numéro de compte mis à jour avec succès pour $accountId ewAccountNumber: $newAccountNumber");
      return true;
    } catch (e) {
      _error = 'Erreur mise à jour numéro de compte: ${e.toString()}';
      print("Erreur updateAccountNumber: $e");
      return false;
    } finally {
      _isUpdatingAccountNumber = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Active un compte"
  Future<bool> activateAccount(String accountId) async {
    _isActivatingAccount = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service
          .activateAccount(accountId); // "demande à l'API d'activer ce compte"

      _error = '';
      print("Compte $accountId activé");
      return true;
    } catch (e) {
      _error = 'Erreur activation compte: ${e.toString()}';
      print("Erreur activateAccount: $e");
      return false;
    } finally {
      _isActivatingAccount = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Désactive un compte"
  Future<bool> deactivateAccount(String accountId) async {
    _isDeactivatingAccount = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deactivateAccount(
          accountId); // "demande à l'API de désactiver ce compte"

      _error = '';
      print("Compte $accountId désactivé");
      return true;
    } catch (e) {
      _error = 'Erreur désactivation compte: ${e.toString()}';
      print("Erreur deactivateAccount: $e");
      return false;
    } finally {
      _isDeactivatingAccount = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Transfert de fonds entre comptes"
  Future<bool> transferFunds(
      String fromAccountId, String toAccountId, double amount) async {
    _isTransferringFunds = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.transferFunds(fromAccountId, toAccountId,
          amount); // "demande à l'API d'effectuer le transfert"

      _error = '';
      print("Transfert de $amount du compte $fromAccountId vers $toAccountId");
      return true;
    } catch (e) {
      _error = 'Erreur transfert de fonds: ${e.toString()}';
      print("Erreur transferFundsBetweenAccounts: $e");
      return false;
    } finally {
      _isTransferringFunds = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Annule un transfert de fonds"
  Future<bool> cancelTransferFunds(
      String fromAccountId, String toAccountId, double amount) async {
    _isCancelingTransfer = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.cancelTransferFunds(fromAccountId, toAccountId,
          amount); // "demande à l'API d'annuler le transfert"

      _error = '';
      print(
          "Annulation transfert de $amount du compte $fromAccountId vers $toAccountId");
      return true;
    } catch (e) {
      _error = 'Erreur annulation transfert: ${e.toString()}';
      print("Erreur cancelTransferBetweenAccounts: $e");
      return false;
    } finally {
      _isCancelingTransfer = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Crédite un compte"
  Future<bool> creditAccount(String accountId, double amount) async {
    _isCreditingAccount = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.creditAccount(
          accountId, amount); // "demande à l'API de créditer le compte"

      _error = '';
      print("Compte $accountId crédité de $amount");
      return true;
    } catch (e) {
      _error = 'Erreur crédit compte: ${e.toString()}';
      print("Erreur creditAccount: $e");
      return false;
    } finally {
      _isCreditingAccount = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // "Annule un crédit de compte"
  Future<bool> cancelCreditAccount(String accountId, double amount) async {
    _isCancelingCredit = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.cancelCreditAccount(
          accountId, amount); // "demande à l'API d'annuler le crédit"

      _error = '';
      print("Annulation crédit de $amount pour le compte $accountId");
      return true;
    } catch (e) {
      _error = 'Erreur annulation crédit: ${e.toString()}';
      print("Erreur cancelCreditAccount: $e");
      return false;
    } finally {
      _isCancelingCredit = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // === MÉTHODES UTILITAIRES ===

  // "Recherche de comptes (utilise le cache local du service)"
  List<Account> searchAccounts(String query) {
    return _service.searchAccounts(query);
  }

  // "Efface le message d'erreur et notifie l'UI"
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // "Efface le compte courant et notifie l'UI"
  void clearCurrentAccount() {
    _currentAccount = null;
    notifyListeners();
  }

  // "Force le rafraîchissement des données"
  Future<void> refreshData() async {
    await loadAllAccounts(forceRefresh: true);
  }
}
 */