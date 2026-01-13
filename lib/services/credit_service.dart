import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:senticket_front/model/credit_model.dart';

/* 
  - Service combiné qui gère :
  - Appels HTTP vers l'API Spring Boot pour les crédits
  - Cache simple des données
  - Logique métier légère
  - Transformation des données 
*/
class CreditApiService {
  /* Use the IP address of the Android emulator (10.0.2.2)
  or your machine's IP address for other emulators/devices. */
  static const String baseUrl = 'http://10.0.2.2:8080/api/credits';

  // Configure HTTP headers for all requests
  static final Map<String, String> headers = {
    'Content-Type': 'application/json', // Indique au serveur "J'envoie du JSON"
    'Accept':
        'application/json', // Indique au serveur "Je veux recevoir du JSON"
  };

  // === CACHE SIMPLE INTÉGRÉ ===
  List<Credit> _cachedCredits = []; // Cache des crédits
  DateTime? _lastFetchTime; // Dernière récupération
  static const Duration cacheDuration = Duration(minutes: 5); // Durée de cache

  // -------------------------
  // 1. CREATE CREDIT (POST /api/credits)
  // -------------------------
  Future<Credit> createCredit(Credit credit) async {
    // "Je vais créer un crédit via POST /api/credits et retourner le crédit créé"
    try {
      print(
          "Création d'un nouveau crédit: ${credit.creditAmount} pour le compte ${credit.accountDTO.accountNumber}");

      final response = await http.post(
        // "J'envoie une requête POST :"
        Uri.parse(baseUrl), // Convertit l'URL string en objet Uri
        headers: headers, // Utilise les headers configurés
        body: json
            .encode(credit.toJson()), // Convertit l'objet Credit → JSON string
      );

      if (response.statusCode == 201) {
        final newCredit = Credit.fromJson(json.decode(
            response.body)); // "Convertit la réponse JSON → objet Credit"

        print("Crédit créé avec ID: ${newCredit.creditId}");

        // Mise à jour du cache
        _cachedCredits.add(newCredit);

        return newCredit;
      } else {
        throw Exception('Erreur création crédit: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur création crédit: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 2. READ ALL CREDITS (GET /api/credits)
  // -------------------------
  // Utilise le cache pour éviter les appels API inutiles
  Future<List<Credit>> getAllCredits({bool forceRefresh = false}) async {
    // "Vérifie si le cache est encore valide"
    final now = DateTime.now();

    final cacheValide = _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < cacheDuration;

    // "Retourne le cache si valide et pas de force refresh"
    if (!forceRefresh && cacheValide && _cachedCredits.isNotEmpty) {
      print("Retourne ${_cachedCredits.length} crédits depuis le cache");

      return _cachedCredits;
    }

    try {
      print("Récupération des crédits depuis l'API");

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // "Convertit la réponse JSON → liste d'objets Credit"

        final List<dynamic> jsonList =
            json.decode(response.body); // "JSON string → Liste d'objets Dart"

        _cachedCredits = jsonList
            .map((json) => Credit.fromJson(json))
            .toList(); // "Transforme chaque objet JSON → objet Credit"

        _lastFetchTime = DateTime.now(); // "Mise à jour du timestamp"

        print("${_cachedCredits.length} crédits récupérés");

        return _cachedCredits;
      } else {
        throw Exception('Erreur récupération crédits: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur récupération crédits: $e");

      // Fallback: retourne le cache même expiré si pas de réseau
      if (_cachedCredits.isNotEmpty) {
        print("Retourne cache expiré en fallback");
        return _cachedCredits;
      }

      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 3. READ CREDIT BY ID (GET /api/credits/{creditId})
  // -------------------------
  Future<Credit> getCreditById(String creditId) async {
    try {
      print("Récupération du crédit ID: $creditId");

      // "D'abord, recherche dans le cache"
      final cachedCredit = _cachedCredits.firstWhere(
        (credit) => credit.creditId == creditId,
        orElse: () => Credit(
          creditId:
              -1, // Marqueur "non trouvé" - valeur spéciale pour indiquer l'absence
          creditDate: DateTime.now(),
          creditAmount: 0.0,
          accountDTO: AccountDTO(
            accountNumber: '',
            balance: 0.0,
          ),
          userDTO: UserDTO(
            firstName: '',
            lastName: '',
            username: '',
          ),
        ),
      );

      if (cachedCredit.creditId != -1) {
        print("Crédit trouvé dans le cache");
        return cachedCredit;
      }

      // "Si pas dans le cache, appel API"
      final response = await http.get(
        Uri.parse('$baseUrl/$creditId'),
        headers: headers,
      ); // "GET /api/credits/{creditId} pour récupérer un crédit spécifique"

      if (response.statusCode == 200) {
        final credit = Credit.fromJson(json.decode(response.body));

        print("Crédit récupéré: ${credit.creditId}");

        return credit;
      } else if (response.statusCode == 404) {
        throw Exception('Crédit non trouvé');
      } else {
        throw Exception('Erreur récupération crédit: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur récupération par ID: $e");

      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 4. UPDATE CREDIT (PUT /api/credits/{creditId})
  // -------------------------
  Future<Credit> updateCredit(String creditId, Credit credit) async {
    try {
      print("Mise à jour du crédit ID: $creditId");

      final response = await http.put(
        Uri.parse('$baseUrl/$creditId'),
        headers: headers,
        body: json.encode(credit.toJson()), // "Envoie les nouvelles données"
      ); // "PUT /api/credits/{creditId} pour modifier un crédit existant"

      if (response.statusCode == 200) {
        final updatedCredit = Credit.fromJson(json.decode(response.body));
        print("Crédit mis à jour: ${updatedCredit.creditId}");

        // "Met à jour le cache"
        final index = _cachedCredits.indexWhere((c) => c.creditId == creditId);
        if (index != -1) {
          _cachedCredits[index] = updatedCredit;
        }

        return updatedCredit;
      } else {
        throw Exception('Erreur mise à jour crédit: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur mise à jour crédit: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 5. DELETE CREDIT (DELETE /api/credits/{creditId})
  // -------------------------
  Future<void> deleteCredit(String creditId) async {
    try {
      print("Suppression du crédit ID: $creditId");

      final response = await http.delete(
        Uri.parse('$baseUrl/$creditId'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        print("Crédit supprimé avec ID: $creditId");

        // "Met à jour le cache"
        _cachedCredits.removeWhere((credit) => credit.creditId == creditId);
      } else {
        throw Exception('Erreur suppression crédit: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur suppression crédit: $e");

      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 6. LINK CREDIT TO ACCOUNT (POST /api/credits/{creditId}/link/{accountId})
  // sans cache
  // -------------------------
  Future<void> linkCreditToAccount(String creditId, String accountId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$creditId/link/$accountId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur liaison crédit-compte: ${response.statusCode}');
      }

      print("Crédit $creditId lié au compte $accountId");

      // "Met à jour le cache local"
      final index = _cachedCredits.indexWhere((c) => c.creditId == creditId);
      if (index != -1) {
        // "On pourrait mettre à jour les informations du compte ici si nécessaire"
        print("Cache mis à jour pour le crédit $creditId");
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 7. UNLINK CREDIT FROM ACCOUNT (POST /api/credits/{creditId}/unlink/{accountId})
  // sans cache
  // -------------------------
  Future<void> unlinkCreditFromAccount(
      String creditId, String accountId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$creditId/unlink/$accountId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur déliaison crédit-compte: ${response.statusCode}');
      }

      print("Crédit $creditId délié du compte $accountId");

      // "Met à jour le cache local"
      final index = _cachedCredits.indexWhere((c) => c.creditId == creditId);
      if (index != -1) {
        // "On pourrait mettre à jour les informations du compte ici si nécessaire"
        print("Cache mis à jour pour le crédit $creditId");
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // === MÉTHODES UTILITAIRES AVEC LOGIQUE MÉTIER LÉGÈRE ===

  // "Recherche de crédits dans le cache local"
  List<Credit> searchCredits(String query) {
    if (query.isEmpty) return _cachedCredits;

    final queryLower = query.toLowerCase();

    return _cachedCredits
        .where((credit) =>
            credit.accountDTO.accountNumber
                .toLowerCase()
                .contains(queryLower) ||
            credit.userDTO.firstName.toLowerCase().contains(queryLower) ||
            credit.userDTO.lastName.toLowerCase().contains(queryLower) ||
            credit.userDTO.username.toLowerCase().contains(queryLower) ||
            credit.creditAmount.toString().contains(queryLower) ||
            _formatDate(credit.creditDate).contains(queryLower))
        .toList();
  }

  // "Validation basique des données de crédit"
  void validateCreditData(Credit credit) {
    if (credit.creditAmount <= 0) {
      throw Exception('Le montant du crédit doit être positif');
    }

    if (credit.creditDate.isAfter(DateTime.now())) {
      throw Exception('La date du crédit ne peut pas être dans le futur');
    }

    if (credit.accountDTO.accountId == null) {
      throw Exception('Le compte est requis');
    }

    if (credit.userDTO.userId == null) {
      throw Exception('L\'utilisateur est requis');
    }

    /*  if (credit.userDTO.userId.isEmpty) {
      throw Exception('L\'utilisateur est requis');
    } */
  }

  // "Vide le cache (utile pour forcer un rafraîchissement)"
  void clearCache() {
    _cachedCredits.clear();
    _lastFetchTime = null;
    print("Cache crédits vidé");
  }

  // "Filtre les crédits par compte"
  List<Credit> filterCreditsByAccountId(String accountId) {
    return _cachedCredits
        .where((credit) => credit.accountDTO.accountId == accountId)
        .toList();
  }

  // "Filtre les crédits par utilisateur"
  List<Credit> filterCreditsByUserId(String userId) {
    return _cachedCredits
        .where((credit) => credit.userDTO.userId == userId)
        .toList();
  }

  // "Filtre les crédits par date"
  List<Credit> filterCreditsByDate(DateTime date) {
    return _cachedCredits
        .where((credit) =>
            credit.creditDate.year == date.year &&
            credit.creditDate.month == date.month &&
            credit.creditDate.day == date.day)
        .toList();
  }

  // "Filtre les crédits par période"
  List<Credit> filterCreditsByDateRange(DateTime startDate, DateTime endDate) {
    return _cachedCredits
        .where((credit) =>
            credit.creditDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            credit.creditDate.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  // "Filtre les crédits par montant minimum"
  List<Credit> filterCreditsByMinAmount(double minAmount) {
    return _cachedCredits
        .where((credit) => credit.creditAmount >= minAmount)
        .toList();
  }

  // "Filtre les crédits par montant maximum"
  List<Credit> filterCreditsByMaxAmount(double maxAmount) {
    return _cachedCredits
        .where((credit) => credit.creditAmount <= maxAmount)
        .toList();
  }

  // "Trie les crédits par date (récentes ou anciennes en premier)"
  List<Credit> sortCreditsByDate(bool ascending) {
    final sortedCredits = List<Credit>.from(_cachedCredits);
    sortedCredits.sort((a, b) => ascending
        ? a.creditDate.compareTo(b.creditDate)
        : b.creditDate.compareTo(a.creditDate));
    return sortedCredits;
  }

  // "Trie les crédits par montant"
  List<Credit> sortCreditsByAmount(bool ascending) {
    final sortedCredits = List<Credit>.from(_cachedCredits);
    sortedCredits.sort((a, b) => ascending
        ? a.creditAmount.compareTo(b.creditAmount)
        : b.creditAmount.compareTo(a.creditAmount));
    return sortedCredits;
  }

  // "Trie les crédits par nom d'utilisateur"
  List<Credit> sortCreditsByUserName(bool ascending) {
    final sortedCredits = List<Credit>.from(_cachedCredits);
    sortedCredits.sort((a, b) {
      final aName = '${a.userDTO.firstName} ${a.userDTO.lastName}';
      final bName = '${b.userDTO.firstName} ${b.userDTO.lastName}';
      return ascending ? aName.compareTo(bName) : bName.compareTo(aName);
    });
    return sortedCredits;
  }

  // "Trie les crédits par numéro de compte"
  List<Credit> sortCreditsByAccountNumber(bool ascending) {
    final sortedCredits = List<Credit>.from(_cachedCredits);
    sortedCredits.sort((a, b) => ascending
        ? a.accountDTO.accountNumber.compareTo(b.accountDTO.accountNumber)
        : b.accountDTO.accountNumber.compareTo(a.accountDTO.accountNumber));
    return sortedCredits;
  }

  // "Méthode utilitaire pour formater une date"
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // "Obtient les statistiques des crédits"
  Map<String, dynamic> getCreditStatistics() {
    final statistics = <String, dynamic>{};

    // "Nombre total de crédits"
    statistics['totalCredits'] = _cachedCredits.length;

    // "Montant total des crédits"
    statistics['totalAmount'] =
        _cachedCredits.fold(0.0, (sum, credit) => sum + credit.creditAmount);

    // "Moyenne des crédits"
    statistics['averageAmount'] = _cachedCredits.isEmpty
        ? 0.0
        : statistics['totalAmount'] / statistics['totalCredits'];

    // "Crédit le plus élevé"
    statistics['maxCredit'] = _cachedCredits.isEmpty
        ? 0.0
        : _cachedCredits
            .map((c) => c.creditAmount)
            .reduce((a, b) => a > b ? a : b);

    // "Crédit le plus bas"
    statistics['minCredit'] = _cachedCredits.isEmpty
        ? 0.0
        : _cachedCredits
            .map((c) => c.creditAmount)
            .reduce((a, b) => a < b ? a : b);

    // "Crédits par compte"
    final creditsByAccount = <String, int>{};
    final amountsByAccount = <String, double>{};
    for (final credit in _cachedCredits) {
      final accountNumber = credit.accountDTO.accountNumber;
      creditsByAccount[accountNumber] =
          (creditsByAccount[accountNumber] ?? 0) + 1;
      amountsByAccount[accountNumber] =
          (amountsByAccount[accountNumber] ?? 0.0) + credit.creditAmount;
    }
    statistics['creditsByAccount'] = creditsByAccount;
    statistics['amountsByAccount'] = amountsByAccount;

    // "Crédits par utilisateur"
    final creditsByUser = <String, int>{};
    final amountsByUser = <String, double>{};
    for (final credit in _cachedCredits) {
      final userName = '${credit.userDTO.firstName} ${credit.userDTO.lastName}';
      creditsByUser[userName] = (creditsByUser[userName] ?? 0) + 1;
      amountsByUser[userName] =
          (amountsByUser[userName] ?? 0.0) + credit.creditAmount;
    }
    statistics['creditsByUser'] = creditsByUser;
    statistics['amountsByUser'] = amountsByUser;

    // "Crédits par date"
    final creditsByDate = <String, int>{};
    final amountsByDate = <String, double>{};
    for (final credit in _cachedCredits) {
      final dateKey = _formatDate(credit.creditDate);
      creditsByDate[dateKey] = (creditsByDate[dateKey] ?? 0) + 1;
      amountsByDate[dateKey] =
          (amountsByDate[dateKey] ?? 0.0) + credit.creditAmount;
    }
    statistics['creditsByDate'] = creditsByDate;
    statistics['amountsByDate'] = amountsByDate;

    return statistics;
  }

  // "Obtient le total des crédits pour un compte spécifique"
  double getTotalCreditsForAccount(String accountId) {
    return _cachedCredits
        .where((credit) => credit.accountDTO.accountId == accountId)
        .fold(0.0, (sum, credit) => sum + credit.creditAmount);
  }

  // "Obtient le total des crédits pour un utilisateur spécifique"
  double getTotalCreditsForUser(String userId) {
    return _cachedCredits
        .where((credit) => credit.userDTO.userId == userId)
        .fold(0.0, (sum, credit) => sum + credit.creditAmount);
  }

  // "Obtient le compte avec le plus de crédits"
  String getAccountWithMostCredits() {
    if (_cachedCredits.isEmpty) return 'Aucun crédit';

    final accountCounts = <String, int>{};
    for (final credit in _cachedCredits) {
      final accountNumber = credit.accountDTO.accountNumber;
      accountCounts[accountNumber] = (accountCounts[accountNumber] ?? 0) + 1;
    }

    return accountCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // "Obtient l'utilisateur avec le plus de crédits"
  String getUserWithMostCredits() {
    if (_cachedCredits.isEmpty) return 'Aucun utilisateur';

    final userCounts = <String, int>{};
    for (final credit in _cachedCredits) {
      final userName = '${credit.userDTO.firstName} ${credit.userDTO.lastName}';
      userCounts[userName] = (userCounts[userName] ?? 0) + 1;
    }

    return userCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
