import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:senticket_front/model/debit_model.dart';

/* 
  - Service combiné qui gère :
  - Appels HTTP vers l'API Spring Boot pour les débits
  - Cache simple des données
  - Logique métier légère
  - Transformation des données 
*/
class DebitApiService {
  static const String baseUrl = 'http://192.168.1.4:8080/api/debits';

  // Configure HTTP headers for all requests
  static final Map<String, String> headers = {
    'Content-Type': 'application/json', // Indique au serveur "J'envoie du JSON"
    'Accept':
        'application/json', // Indique au serveur "Je veux recevoir du JSON"
  };

  // === CACHE SIMPLE INTÉGRÉ ===
  List<Debit> _cachedDebits = []; // Cache des débits
  DateTime? _lastFetchTime; // Dernière récupération
  static const Duration cacheDuration = Duration(minutes: 5); // Durée de cache

  // -------------------------
  // 1. CREATE DEBIT (POST /api/debits)
  // -------------------------
  Future<Debit> createDebit(Debit debit) async {
    // "Je vais créer un débit via POST /api/debits et retourner le débit créé"
    try {
      print(
          "Création d'un nouveau débit: ${debit.debitAmount} pour le compte ${debit.accountDTO.accountNumber}");

      final response = await http.post(
        // "J'envoie une requête POST :"
        Uri.parse(baseUrl), // Convertit l'URL string en objet Uri
        headers: headers, // Utilise les headers configurés
        body: json
            .encode(debit.toJson()), // Convertit l'objet Debit → JSON string
      );

      if (response.statusCode == 201) {
        final newDebit = Debit.fromJson(json.decode(
            response.body)); // "Convertit la réponse JSON → objet Debit"

        print("Débit créé avec ID: ${newDebit.debitId}");

        // Mise à jour du cache
        _cachedDebits.add(newDebit);

        return newDebit;
      } else {
        throw Exception('Erreur création débit: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur création débit: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 2. READ ALL DEBITS (GET /api/debits)
  // -------------------------
  // Utilise le cache pour éviter les appels API inutiles
  Future<List<Debit>> getAllDebits({bool forceRefresh = false}) async {
    // "Vérifie si le cache est encore valide"
    final now = DateTime.now();

    final cacheValide = _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < cacheDuration;

    // "Retourne le cache si valide et pas de force refresh"
    if (!forceRefresh && cacheValide && _cachedDebits.isNotEmpty) {
      print("Retourne ${_cachedDebits.length} débits depuis le cache");

      return _cachedDebits;
    }

    try {
      print("Récupération des débits depuis l'API");

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // "Convertit la réponse JSON → liste d'objets Debit"

        final List<dynamic> jsonList =
            json.decode(response.body); // "JSON string → Liste d'objets Dart"

        _cachedDebits = jsonList
            .map((json) => Debit.fromJson(json))
            .toList(); // "Transforme chaque objet JSON → objet Debit"

        _lastFetchTime = DateTime.now(); // "Mise à jour du timestamp"

        print("${_cachedDebits.length} débits récupérés");

        return _cachedDebits;
      } else {
        throw Exception('Erreur récupération débits: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur récupération débits: $e");

      // Fallback: retourne le cache même expiré si pas de réseau
      if (_cachedDebits.isNotEmpty) {
        print("Retourne cache expiré en fallback");
        return _cachedDebits;
      }

      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 3. READ DEBIT BY ID (GET /api/debits/{debitId})
  // -------------------------
  Future<Debit> getDebitById(String debitId) async {
    try {
      print("Récupération du débit ID: $debitId");

      // "D'abord, recherche dans le cache"
      final cachedDebit = _cachedDebits.firstWhere(
        (debit) => debit.debitId == debitId,
        orElse: () => Debit(
          debitId: -1, // "Marqueur 'non trouvé'"
          debitDate: DateTime.now(),
          debitAmount: 0.0,
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

      if (cachedDebit.debitId != -1) {
        print("Débit trouvé dans le cache");
        return cachedDebit;
      }

      // "Si pas dans le cache, appel API"
      final response = await http.get(
        Uri.parse('$baseUrl/$debitId'),
        headers: headers,
      ); // "GET /api/debits/{debitId} pour récupérer un débit spécifique"

      if (response.statusCode == 200) {
        final debit = Debit.fromJson(json.decode(response.body));

        print("Débit récupéré: ${debit.debitId}");

        return debit;
      } else if (response.statusCode == 404) {
        throw Exception('Débit non trouvé');
      } else {
        throw Exception('Erreur récupération débit: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur récupération par ID: $e");

      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 4. UPDATE DEBIT (PUT /api/debits/{debitId})
  // -------------------------
  Future<Debit> updateDebit(String debitId, Debit debit) async {
    try {
      print("Mise à jour du débit ID: $debitId");

      final response = await http.put(
        Uri.parse('$baseUrl/$debitId'),
        headers: headers,
        body: json.encode(debit.toJson()), // "Envoie les nouvelles données"
      ); // "PUT /api/debits/{debitId} pour modifier un débit existant"

      if (response.statusCode == 200) {
        final updatedDebit = Debit.fromJson(json.decode(response.body));
        print("Débit mis à jour: ${updatedDebit.debitId}");

        // "Met à jour le cache"
        final index = _cachedDebits.indexWhere((d) => d.debitId == debitId);
        if (index != -1) {
          _cachedDebits[index] = updatedDebit;
        }

        return updatedDebit;
      } else {
        throw Exception('Erreur mise à jour débit: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur mise à jour débit: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 5. DELETE DEBIT (DELETE /api/debits/{debitId})
  // -------------------------
  Future<void> deleteDebit(String debitId) async {
    try {
      print("Suppression du débit ID: $debitId");

      final response = await http.delete(
        Uri.parse('$baseUrl/$debitId'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        print("Débit supprimé avec ID: $debitId");

        // "Met à jour le cache"
        _cachedDebits.removeWhere((debit) => debit.debitId == debitId);
      } else {
        throw Exception('Erreur suppression débit: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur suppression débit: $e");

      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 6. LINK DEBIT TO ACCOUNT (POST /api/debits/{debitId}/link/{accountId})
  // sans cache
  // -------------------------
  Future<void> linkDebitToAccount(String debitId, String accountId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$debitId/link/$accountId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur liaison débit-compte: ${response.statusCode}');
      }

      print("Débit $debitId lié au compte $accountId");

      // "Met à jour le cache local"
      final index = _cachedDebits.indexWhere((d) => d.debitId == debitId);
      if (index != -1) {
        // "On pourrait mettre à jour les informations du compte ici si nécessaire"
        print("Cache mis à jour pour le débit $debitId");
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // -------------------------
  // 7. UNLINK DEBIT FROM ACCOUNT (POST /api/debits/{debitId}/unlink/{accountId})
  // sans cache
  // -------------------------
  Future<void> unlinkDebitFromAccount(String debitId, String accountId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$debitId/unlink/$accountId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur déliaison débit-compte: ${response.statusCode}');
      }

      print("Débit $debitId délié du compte $accountId");

      // "Met à jour le cache local"
      final index = _cachedDebits.indexWhere((d) => d.debitId == debitId);
      if (index != -1) {
        // "On pourrait mettre à jour les informations du compte ici si nécessaire"
        print("Cache mis à jour pour le débit $debitId");
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // === MÉTHODES UTILITAIRES AVEC LOGIQUE MÉTIER LÉGÈRE ===

  // "Recherche de débits dans le cache local"
  List<Debit> searchDebits(String query) {
    if (query.isEmpty) return _cachedDebits;

    final queryLower = query.toLowerCase();

    return _cachedDebits
        .where((debit) =>
            debit.accountDTO.accountNumber.toLowerCase().contains(queryLower) ||
            debit.userDTO.firstName.toLowerCase().contains(queryLower) ||
            debit.userDTO.lastName.toLowerCase().contains(queryLower) ||
            debit.userDTO.username.toLowerCase().contains(queryLower) ||
            debit.debitAmount.toString().contains(queryLower) ||
            _formatDate(debit.debitDate).contains(queryLower))
        .toList();
  }

  // "Validation basique des données de débit"
  void validateDebitData(Debit debit) {
    if (debit.debitAmount <= 0) {
      throw Exception('Le montant du débit doit être positif');
    }

    if (debit.debitDate.isAfter(DateTime.now())) {
      throw Exception('La date du débit ne peut pas être dans le futur');
    }

    if (debit.accountDTO.accountId == null) {
      throw Exception('Le compte est requis');
    }

    if (debit.userDTO.userId == null) {
      throw Exception('L\'utilisateur est requis');
    }

    /* if (debit.userDTO.userId.isEmpty) {
      throw Exception('L\'utilisateur est requis');
    } */
  }

  // "Vide le cache (utile pour forcer un rafraîchissement)"
  void clearCache() {
    _cachedDebits.clear();
    _lastFetchTime = null;
    print("Cache débits vidé");
  }

  // "Filtre les débits par compte"
  List<Debit> filterDebitsByAccountId(String accountId) {
    return _cachedDebits
        .where((debit) => debit.accountDTO.accountId == accountId)
        .toList();
  }

  // "Filtre les débits par utilisateur"
  List<Debit> filterDebitsByUserId(String userId) {
    return _cachedDebits
        .where((debit) => debit.userDTO.userId == userId)
        .toList();
  }

  // "Filtre les débits par date"
  List<Debit> filterDebitsByDate(DateTime date) {
    return _cachedDebits
        .where((debit) =>
            debit.debitDate.year == date.year &&
            debit.debitDate.month == date.month &&
            debit.debitDate.day == date.day)
        .toList();
  }

  // "Filtre les débits par période"
  List<Debit> filterDebitsByDateRange(DateTime startDate, DateTime endDate) {
    return _cachedDebits
        .where((debit) =>
            debit.debitDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            debit.debitDate.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  // "Filtre les débits par montant minimum"
  List<Debit> filterDebitsByMinAmount(double minAmount) {
    return _cachedDebits
        .where((debit) => debit.debitAmount >= minAmount)
        .toList();
  }

  // "Filtre les débits par montant maximum"
  List<Debit> filterDebitsByMaxAmount(double maxAmount) {
    return _cachedDebits
        .where((debit) => debit.debitAmount <= maxAmount)
        .toList();
  }

  // "Trie les débits par date (récentes ou anciennes en premier)"
  List<Debit> sortDebitsByDate(bool ascending) {
    final sortedDebits = List<Debit>.from(_cachedDebits);
    sortedDebits.sort((a, b) => ascending
        ? a.debitDate.compareTo(b.debitDate)
        : b.debitDate.compareTo(a.debitDate));
    return sortedDebits;
  }

  // "Trie les débits par montant"
  List<Debit> sortDebitsByAmount(bool ascending) {
    final sortedDebits = List<Debit>.from(_cachedDebits);
    sortedDebits.sort((a, b) => ascending
        ? a.debitAmount.compareTo(b.debitAmount)
        : b.debitAmount.compareTo(a.debitAmount));
    return sortedDebits;
  }

  // "Trie les débits par nom d'utilisateur"
  List<Debit> sortDebitsByUserName(bool ascending) {
    final sortedDebits = List<Debit>.from(_cachedDebits);
    sortedDebits.sort((a, b) {
      final aName = '${a.userDTO.firstName} ${a.userDTO.lastName}';
      final bName = '${b.userDTO.firstName} ${b.userDTO.lastName}';
      return ascending ? aName.compareTo(bName) : bName.compareTo(aName);
    });
    return sortedDebits;
  }

  // "Trie les débits par numéro de compte"
  List<Debit> sortDebitsByAccountNumber(bool ascending) {
    final sortedDebits = List<Debit>.from(_cachedDebits);
    sortedDebits.sort((a, b) => ascending
        ? a.accountDTO.accountNumber.compareTo(b.accountDTO.accountNumber)
        : b.accountDTO.accountNumber.compareTo(a.accountDTO.accountNumber));
    return sortedDebits;
  }

  // "Méthode utilitaire pour formater une date"
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // "Obtient les statistiques des débits"
  Map<String, dynamic> getDebitStatistics() {
    final statistics = <String, dynamic>{};

    // "Nombre total de débits"
    statistics['totalDebits'] = _cachedDebits.length;

    // "Montant total des débits"
    statistics['totalAmount'] =
        _cachedDebits.fold(0.0, (sum, debit) => sum + debit.debitAmount);

    // "Moyenne des débits"
    statistics['averageAmount'] = _cachedDebits.isEmpty
        ? 0.0
        : statistics['totalAmount'] / statistics['totalDebits'];

    // "Débit le plus élevé"
    statistics['maxDebit'] = _cachedDebits.isEmpty
        ? 0.0
        : _cachedDebits
            .map((d) => d.debitAmount)
            .reduce((a, b) => a > b ? a : b);

    // "Débit le plus bas"
    statistics['minDebit'] = _cachedDebits.isEmpty
        ? 0.0
        : _cachedDebits
            .map((d) => d.debitAmount)
            .reduce((a, b) => a < b ? a : b);

    // "Débits par compte"
    final debitsByAccount = <String, int>{};
    final amountsByAccount = <String, double>{};
    for (final debit in _cachedDebits) {
      final accountNumber = debit.accountDTO.accountNumber;
      debitsByAccount[accountNumber] =
          (debitsByAccount[accountNumber] ?? 0) + 1;
      amountsByAccount[accountNumber] =
          (amountsByAccount[accountNumber] ?? 0.0) + debit.debitAmount;
    }
    statistics['debitsByAccount'] = debitsByAccount;
    statistics['amountsByAccount'] = amountsByAccount;

    // "Débits par utilisateur"
    final debitsByUser = <String, int>{};
    final amountsByUser = <String, double>{};
    for (final debit in _cachedDebits) {
      final userName = '${debit.userDTO.firstName} ${debit.userDTO.lastName}';
      debitsByUser[userName] = (debitsByUser[userName] ?? 0) + 1;
      amountsByUser[userName] =
          (amountsByUser[userName] ?? 0.0) + debit.debitAmount;
    }
    statistics['debitsByUser'] = debitsByUser;
    statistics['amountsByUser'] = amountsByUser;

    // "Débits par date"
    final debitsByDate = <String, int>{};
    final amountsByDate = <String, double>{};
    for (final debit in _cachedDebits) {
      final dateKey = _formatDate(debit.debitDate);
      debitsByDate[dateKey] = (debitsByDate[dateKey] ?? 0) + 1;
      amountsByDate[dateKey] =
          (amountsByDate[dateKey] ?? 0.0) + debit.debitAmount;
    }
    statistics['debitsByDate'] = debitsByDate;
    statistics['amountsByDate'] = amountsByDate;

    return statistics;
  }

  // "Obtient le total des débits pour un compte spécifique"
  double getTotalDebitsForAccount(String accountId) {
    return _cachedDebits
        .where((debit) => debit.accountDTO.accountId == accountId)
        .fold(0.0, (sum, debit) => sum + debit.debitAmount);
  }

  // "Obtient le total des débits pour un utilisateur spécifique"
  double getTotalDebitsForUser(String userId) {
    return _cachedDebits
        .where((debit) => debit.userDTO.userId == userId)
        .fold(0.0, (sum, debit) => sum + debit.debitAmount);
  }

  // "Obtient le compte avec le plus de débits"
  String getAccountWithMostDebits() {
    if (_cachedDebits.isEmpty) return 'Aucun débit';

    final accountCounts = <String, int>{};
    for (final debit in _cachedDebits) {
      final accountNumber = debit.accountDTO.accountNumber;
      accountCounts[accountNumber] = (accountCounts[accountNumber] ?? 0) + 1;
    }

    return accountCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // "Obtient l'utilisateur avec le plus de débits"
  String getUserWithMostDebits() {
    if (_cachedDebits.isEmpty) return 'Aucun utilisateur';

    final userCounts = <String, int>{};
    for (final debit in _cachedDebits) {
      final userName = '${debit.userDTO.firstName} ${debit.userDTO.lastName}';
      userCounts[userName] = (userCounts[userName] ?? 0) + 1;
    }

    return userCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
