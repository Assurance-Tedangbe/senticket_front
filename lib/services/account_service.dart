/* import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:senticket_front/model/account_model.dart';
import 'package:senticket_front/model/role_model.dart';
import 'package:senticket_front/model/user_model.dart';

/* 
  - Service combiné qui gère :
  - Appels HTTP vers l'API Spring Boot pour les comptes
  - Cache simple des données
  - Logique métier légère
  - Transformation des données 
*/
class AccountApiService {
  static const String baseUrl = 'http://192.168.1.4:8080/api/accounts';

  // Configure HTTP headers for all requests
  static final Map<String, String> headers = {
    'Content-Type': 'application/json', // Indique au serveur "J'envoie du JSON"
    'Accept':
        'application/json', // Indique au serveur "Je veux recevoir du JSON"
  };

  // === CACHE SIMPLE INTÉGRÉ ===
  List<Account> _cachedAccounts = []; // Cache des comptes
  DateTime? _lastFetchTime; // Dernière récupération
  static const Duration cacheDuration = Duration(minutes: 5); // Durée de cache

  // -------------------------
  // 1. CREATE ACCOUNT (POST /api/accounts)
  // -------------------------
  Future<Account> createAccount(Account account) async {
    // "Je vais créer un compte via POST /api/accounts et retourner le compte créé"
    try {
      print("Création d'un nouveau compte: ${account.accountNumber}");

      final response = await http.post(
        // "J'envoie une requête POST :"
        Uri.parse(baseUrl), // Convertit l'URL string en objet Uri
        headers: headers, // Utilise les headers configurés
        body: json.encode(
            account.toJson()), // Convertit l'objet Account → JSON string
      );

      if (response.statusCode == 201) {
        final newAccount = Account.fromJson(json.decode(
            response.body)); // "Convertit la réponse JSON → objet Account"

        print("Compte créé avec ID: ${newAccount.accountId}");

        // Mise à jour du cache
        _cachedAccounts.add(newAccount);

        return newAccount;
      } else {
        throw Exception('Erreur création compte: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur création compte: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 2. READ ALL ACCOUNTS (GET /api/accounts)
  // -------------------------
  // Utilise le cache pour éviter les appels API inutiles
  Future<List<Account>> getAllAccounts({bool forceRefresh = false}) async {
    // "Vérifie si le cache est encore valide"
    final now = DateTime.now();

    final cacheValide = _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < cacheDuration;

    // "Retourne le cache si valide et pas de force refresh"
    if (!forceRefresh && cacheValide && _cachedAccounts.isNotEmpty) {
      print("Retourne ${_cachedAccounts.length} comptes depuis le cache");

      return _cachedAccounts;
    }

    try {
      print("Récupération des comptes depuis l'API");

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // "Convertit la réponse JSON → liste d'objets Account"

        final List<dynamic> jsonList =
            json.decode(response.body); // "JSON string → Liste d'objets Dart"

        _cachedAccounts = jsonList
            .map((json) => Account.fromJson(json))
            .toList(); // "Transforme chaque objet JSON → objet Account"

        _lastFetchTime = DateTime.now(); // "Mise à jour du timestamp"

        print("${_cachedAccounts.length} comptes récupérés");

        return _cachedAccounts;
      } else {
        throw Exception('Erreur récupération comptes: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur récupération comptes: $e");

      // Fallback: retourne le cache même expiré si pas de réseau
      if (_cachedAccounts.isNotEmpty) {
        print("Retourne cache expiré en fallback");
        return _cachedAccounts;
      }

      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 3. READ ACCOUNT BY ID (GET /api/accounts/{accountId})
  // -------------------------
  Future<Account> getAccountById(String accountId) async {
    try {
      print("Récupération du compte ID: $accountId");

      // "D'abord, recherche dans le cache"
      final cachedAccount = _cachedAccounts.firstWhere(
        (account) => account.accountId == accountId,
        orElse: () => Account(
          accountId: -1, // "Marqueur 'non trouvé'"
          accountNumber: '',
          balance: 0.0,
          dateCreation: DateTime.now(),
          user: User(
            username: '',
            password: '',
            firstName: '',
            lastName: '',
            email: '',
            role: Role(roleName: ''),
          ),
          active: false,
        ),
      );

      if (cachedAccount.accountId != -1) {
        print("Compte trouvé dans le cache");
        return cachedAccount;
      }

      /*  can use this if accountId is a String
      if (cachedAccount.accountId.isNotEmpty) {
        print("Compte trouvé dans le cache");
        return cachedAccount;
      } */

      // "Si pas dans le cache, appel API"
      final response = await http.get(
        Uri.parse('$baseUrl/$accountId'),
        headers: headers,
      ); // "GET /api/accounts/{accountId} pour récupérer un compte spécifique"

      if (response.statusCode == 200) {
        final account = Account.fromJson(json.decode(response.body));

        print("Compte récupéré: ${account.accountNumber}");

        return account;
      } else if (response.statusCode == 404) {
        throw Exception('Compte non trouvé');
      } else {
        throw Exception('Erreur récupération compte: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur récupération par ID: $e");

      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 4. UPDATE ACCOUNT (PUT /api/accounts/{accountId})
  // -------------------------
  Future<Account> updateAccount(Account account) async {
    try {
      print("Mise à jour du compte ID: ${account.accountId}");

      final response = await http.put(
        Uri.parse('$baseUrl/${account.accountId}'),
        headers: headers,
        body: json.encode(account.toJson()), // "Envoie les nouvelles données"
      );

      if (response.statusCode == 200) {
        final updatedAccount = Account.fromJson(json.decode(response.body));
        print("Compte mis à jour: ${updatedAccount.accountNumber}");

        // "Met à jour le cache"
        final index =
            _cachedAccounts.indexWhere((a) => a.accountId == account.accountId);
        if (index != -1) {
          _cachedAccounts[index] = updatedAccount;
        }

        return updatedAccount;
      } else {
        throw Exception('Erreur mise à jour compte: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur mise à jour compte: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 5. DELETE ACCOUNT (DELETE /api/accounts/{accountId})
  // -------------------------
  Future<void> deleteAccount(String accountId) async {
    try {
      print("Suppression du compte ID: $accountId");

      final response = await http.delete(
        Uri.parse('$baseUrl/$accountId'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        print("Compte supprimé avec ID: $accountId");

        // "Met à jour le cache"
        _cachedAccounts
            .removeWhere((account) => account.accountId == accountId);
      } else {
        throw Exception('Erreur suppression compte: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur suppression compte: $e");

      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 6. LINK ACCOUNT TO USER (PUT /api/accounts/{accountId}/link/{userId})
  // sans cache
  // -------------------------
  Future<void> linkAccountToUser(String accountId, String userId) async {
    print("Liaison compte : $accountId à l'utilisateur : $userId");

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$accountId/link/$userId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur liaison compte à utilisateur: ${response.statusCode}');
      }

      print("Compte $accountId lié à l'utilisateur $userId");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 7. UNLINK ACCOUNT FROM USER (PUT /api/accounts/{accountId}/unlink/{userId})
  // sans cache
  // -------------------------
  Future<void> unlinkAccountFromUser(String accountId, String userId) async {
    print("Delier compte : $accountId de l'utilisateur : $userId");
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$accountId/unlink/$userId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur déliaison compte-utilisateur: ${response.statusCode}');
      }

      print("Compte $accountId délié de l'utilisateur $userId");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 8. UPDATE ACCOUNT BALANCE (PUT /api/accounts/balance/{accountId})
  // sans cache
  // -------------------------
  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    print("Mise à jour solde du compte ID: $accountId");
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/balance/$accountId'),
        headers: headers,
        body: json.encode(newBalance), // "Envoie seulement le nouveau solde"
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur mise à jour solde: ${response.statusCode}');
      }

      print(
          "Solde mis à jour pour le compte $accountId newBalance:  $newBalance");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 9. UPDATE ACCOUNT NUMBER (PUT /api/accounts/accountNumber/{accountId})
  // sans cache
  // -------------------------
  Future<void> updateAccountNumber(
      String accountId, String newAccountNumber) async {
    print("Mise à jour numero du compte d'ID: $accountId");
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/accountNumber/$accountId'),
        headers: headers,
        body: json.encode(
            newAccountNumber), // "Envoie seulement le nouveau numéro de compte"
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur mise à jour numéro de compte: ${response.statusCode}');
      }

      print(
          "Numéro de compte mis à jour pour $accountId: newAccountNumber: $newAccountNumber");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 10. ACTIVATE ACCOUNT (PUT /api/accounts/activate/{accountId})
  // -------------------------
  Future<void> activateAccount(String accountId) async {
    print("Activation du compte ID: $accountId");
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/activate/$accountId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur activation compte: ${response.statusCode}');
      }

      print("Compte $accountId activé");

      // "Met à jour le cache local"
      final index = _cachedAccounts.indexWhere((a) => a.accountId == accountId);
      if (index != -1) {
        _cachedAccounts[index] = _cachedAccounts[index].copyWith(active: true);
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 11. DEACTIVATE ACCOUNT (PUT /api/accounts/deactivate/{accountId})
  // -------------------------
  Future<void> deactivateAccount(String accountId) async {
    print("Désactivation du compte ID: $accountId");
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/deactivate/$accountId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur désactivation compte: ${response.statusCode}');
      }

      print("Compte $accountId désactivé");

      // "Met à jour le cache local"
      final index = _cachedAccounts.indexWhere((a) => a.accountId == accountId);
      if (index != -1) {
        _cachedAccounts[index] = _cachedAccounts[index].copyWith(active: false);
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 12. TRANSFER FUNDS (PUT /api/accounts/transfer/{fromAccountId}/to/{toAccountId}/amount/{amount})
  // sans cache
  // -------------------------
  Future<void> transferFunds(
      String fromAccountId, String toAccountId, double amount) async {
    try {
      final response = await http.put(
        Uri.parse(
            '$baseUrl/transfer/$fromAccountId/to/$toAccountId/amount/$amount'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur transfert de fonds: ${response.statusCode}');
      }

      print(
          "Transfert effectué de $amount du compte $fromAccountId vers $toAccountId");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 13. CANCEL TRANSFER (PUT /api/accounts/cancelTransfer/{fromAccountId}/to/{toAccountId}/amount/{amount})
  // sans cache
  // -------------------------
  Future<void> cancelTransferFunds(
      String fromAccountId, String toAccountId, double amount) async {
    try {
      final response = await http.put(
        Uri.parse(
            '$baseUrl/cancelTransfer/$fromAccountId/to/$toAccountId/amount/$amount'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur annulation transfert: ${response.statusCode}');
      }

      print(
          "Annulation transfert de $amount du compte $fromAccountId vers $toAccountId");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 14. CREDIT ACCOUNT (PUT /api/accounts/{accountId}/creditAccount/{amount})
  // sans cache
  // -------------------------
  Future<void> creditAccount(String accountId, double amount) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$accountId/creditAccount/$amount'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur crédit compte: ${response.statusCode}');
      }

      print("Compte $accountId crédité de $amount");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 15. CANCEL CREDIT ACCOUNT (PUT /api/accounts/{accountId}/cancelCreditAccount/{amount})
  // sans cache
  // -------------------------
  Future<void> cancelCreditAccount(String accountId, double amount) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$accountId/cancelCreditAccount/$amount'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur annulation crédit: ${response.statusCode}');
      }

      print("Annulation crédit de $amount pour le compte $accountId");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // === MÉTHODES UTILITAIRES AVEC LOGIQUE MÉTIER LÉGÈRE ===

  // "Recherche de comptes dans le cache local"
  List<Account> searchAccounts(String query) {
    print("searching for accounts with query: $query");
    if (query.isEmpty) return _cachedAccounts;

    final queryLower = query.toLowerCase();

    return _cachedAccounts
        .where((account) =>
            account.accountNumber.toLowerCase().contains(queryLower) ||
            account.user.firstName.toLowerCase().contains(queryLower) ||
            account.user.lastName.toLowerCase().contains(queryLower) ||
            account.user.email.toLowerCase().contains(queryLower))
        .toList();
  }

  // "Validation basique des données de compte"
  void validateAccountData(Account account) {
    if (account.accountNumber.length < 3) {
      throw Exception(
          'Le numéro de compte doit contenir au moins 3 caractères');
    }

    // "Validation de la longueur maximale (comme @Size(max = 70))"
    if (account.accountNumber.length > 70) {
      throw Exception('Le numéro de compte ne peut pas dépasser 70 caractères');
    }

    if (account.balance < 0) {
      throw Exception('Le solde ne peut pas être négatif');
    }

    if (account.user.userId == null) {
      throw Exception('L\'utilisateur est requis');
    }

    /* if (account.user.isEmpty) {
      throw Exception('L\'utilisateur est requis');
    } */
  }

  // "Vide le cache (utile pour forcer un rafraîchissement)"
  void clearCache() {
    print("Vider le cache");
    _cachedAccounts.clear();
    _lastFetchTime = null;
    print("Cache comptes vidé");
  }
}
 */