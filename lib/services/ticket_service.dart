import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:senticket_front/config/network_config.dart';
import 'package:senticket_front/enums/ticket_status.dart';
import 'package:senticket_front/enums/ticket_type.dart';
import 'package:senticket_front/model/ticket_model.dart';

/* 
  - Service combiné qui gère :
  - Appels HTTP vers l'API Spring Boot pour les tickets
  - Cache simple des données
  - Logique métier légère
  - Transformation des données 
    ticket_service.dart: role(Communication API): utilise forApi, fromApi, toBackend, fromBackend
*/
class TicketApiService {
  final baseUrl = '${NetworkConfig.baseUrl}/api/tickets';

  // Configure HTTP headers for all requests
  static final Map<String, String> headers = {
    'Content-Type': 'application/json', // Indique au serveur "J'envoie du JSON"
    'Accept':
        'application/json', // Indique au serveur "Je veux recevoir du JSON"
  };

  // === CACHE SIMPLE INTÉGRÉ ===
  List<Ticket> _cachedTickets = []; // Cache des tickets
  DateTime? _lastFetchTime; // Dernière récupération
  static const Duration cacheDuration = Duration(minutes: 5); // Durée de cache

  // 1. READ ALL TICKETS (GET /api/tickets)
  // Using cache
  Future<List<Ticket>> getAllTickets({bool forceRefresh = false}) async {
    // "Vérifie si le cache est encore valide"
    final now = DateTime.now();

    final cacheValide = _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < cacheDuration;

    // "Retourne le cache si valide et pas de force refresh"
    if (!forceRefresh && cacheValide && _cachedTickets.isNotEmpty) {
      print("Retourne ${_cachedTickets.length} tickets depuis le cache");

      return _cachedTickets;
    }

    try {
      print("Récupération des tickets depuis l'API");

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // "Convertit la réponse JSON → liste d'objets Ticket"

        final List<dynamic> jsonList =
            json.decode(response.body); // "JSON string → Liste d'objets Dart"

        // ICI - La conversion se fait dans Ticket.fromJson()
        _cachedTickets = jsonList
            .map((json) => Ticket.fromJson(json))
            .toList(); // "Transforme chaque objet JSON → objet Ticket"

        _lastFetchTime = DateTime.now(); // "Mise à jour du timestamp"

        print("${_cachedTickets.length} tickets récupérés");

        return _cachedTickets;
      } else {
        throw Exception('Erreur récupération tickets: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur récupération tickets: $e");

      // Fallback: retourne le cache même expiré si pas de réseau
      if (_cachedTickets.isNotEmpty) {
        print("Retourne cache expiré en fallback");
        return _cachedTickets;
      }

      throw Exception('Erreur réseau: $e');
    }
  }

  // 2. CREATE TICKETS (POST /api/tickets)
  Future<List<Ticket>> createTickets(
      CreationTicketsRequestDTO creationTicketsRequestDTO) async {
    // "Je vais créer des tickets via POST /api/tickets et retourner les tickets créés"
    try {
      print(
          "Création de nouveaux tickets: ${creationTicketsRequestDTO.countA} de type A et ${creationTicketsRequestDTO.countB} de type B");

      final response = await http.post(
        // "J'envoie une requête POST :"
        Uri.parse(baseUrl), // Convertit l'URL string en objet Uri
        headers: headers, // Utilise les headers configurés
        body: json.encode(creationTicketsRequestDTO
            .toJson()), // Convertit la requête → JSON string
      );

      if (response.statusCode == 201) {
        final List<dynamic> jsonList = json.decode(response.body);

        /* ICI - La conversion se fait dans Ticket.fromJson()
           Utilise fromBackend et fromApi via Ticket.fromJson() */
        final newTickets = jsonList
            .map((json) => Ticket.fromJson(json))
            .toList(); // "Convertit la réponse JSON → liste d'objets Ticket"

        print("Tickets créés avec IDs: ${newTickets.map((t) => t.ticketId)}");

        // Mise à jour du cache
        _cachedTickets.addAll(newTickets);

        return newTickets;
      } else {
        throw Exception('Erreur création tickets: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur création tickets: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // 3. READ TICKET BY ID (GET /api/tickets/{ticketId})
  Future<Ticket> getTicketById(int ticketId) async {
    try {
      print("Récupération du ticket via son id: $ticketId");

      // Recherche d'abord dans le cache local pour éviter un appel API inutile
      final cachedTicket = _cachedTickets.firstWhere(
        // Condition de recherche : cherche un ticket avec l'ID correspondant
        (ticket) => ticket.ticketId == ticketId,

        // Si aucun ticket n'est trouvé dans le cache, retourne un ticket "vide" avec ticketId = -1
        orElse: () => Ticket(
          ticketId:
              -1, // Marqueur "non trouvé" - valeur spéciale pour indiquer l'absence
          ticketType: TicketType.a,
          ticketPrice: 0.0,
          paymentCode: '',
          booked: false,
          ticketStatus: TicketStatus.available,
          ticketCreationDate: DateTime.now(),
          ticketDescription: '',
          userDTO: UserDTO(firstName: '', lastName: ''),
          isSelected: false,
        ),
      );

      // Vérifie si le ticket a été trouvé dans le cache
      // cachedTicket.ticketId != -1 signifie qu'on a trouvé un ticket valide dans le cache
      if (cachedTicket.ticketId != -1) {
        print("Ticket trouvé dans le cache");
        return cachedTicket;
      }

      // Si le ticket n'est pas dans le cache, on fait un appel API
      final response = await http.get(
        Uri.parse('$baseUrl/$ticketId'),
        headers: headers,
      ); // "GET /api/tickets/{ticketId} pour récupérer un ticket spécifique"

      if (response.statusCode == 200) {
        // ICI - La conversion se fait dans Ticket.fromJson()
        final ticket = Ticket.fromJson(json.decode(response.body));

        print("Ticket récupéré: ${ticket.ticketId}");

        return ticket;
      } else if (response.statusCode == 404) {
        throw Exception('Ticket non trouvé');
      } else {
        throw Exception('Erreur récupération ticket: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur récupération par ID: $e");

      throw Exception('Erreur réseau: $e');
    }
  }

  // 4. UPDATE TICKET (PUT /api/tickets/{ticketId})
  Future<Ticket> updateTicket(Ticket ticket) async {
    try {
      print("Mise à jour du ticket avec ID: ${ticket.ticketId}");

      final response = await http.put(
        Uri.parse('$baseUrl/${ticket.ticketId}'),
        headers: headers,
        body: json.encode(ticket
            .toJson()), // Envoie les nouvelles données, ← Utilise le toJson() qui appelle forApi et toBackend
      ); // "PUT /api/tickets/{ticketId} pour modifier un ticket existant"

      if (response.statusCode == 200) {
        final updatedTicket = Ticket.fromJson(json.decode(response.body));
        print("Ticket mis à jour: ${updatedTicket.ticketId}");

        // "Met à jour le cache"
        final index =
            _cachedTickets.indexWhere((t) => t.ticketId == ticket.ticketId);
        if (index != -1) {
          _cachedTickets[index] = updatedTicket;
        }

        return updatedTicket;
      } else {
        throw Exception('Erreur mise à jour ticket: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur mise à jour ticket: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // 5. DELETE TICKET (DELETE /api/tickets/{ticketId})
  Future<void> deleteTicket(int ticketId) async {
    try {
      print("Suppression du ticket avec ID: $ticketId");

      final response = await http.delete(
        Uri.parse('$baseUrl/$ticketId'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        print("Ticket supprimé avec ID: $ticketId");

        // "Met à jour le cache"
        _cachedTickets.removeWhere((ticket) => ticket.ticketId == ticketId);
      } else {
        throw Exception('Erreur suppression ticket: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur suppression ticket: $e");

      throw Exception('Erreur réseau: $e');
    }
  }

  // 6. PURCHASE TICKETS (POST /api/tickets/{purchase})
  Future<List<Ticket>> purchaseTickets(
      PurchaseTicketsRequestDTO purchaseTicketsRequestDTO) async {
    try {
      print(
          "Achat de tickets pour l'utilisateur: ${purchaseTicketsRequestDTO.userDTO.firstName}");

      final response = await http.post(
        Uri.parse('$baseUrl/purchase'),
        headers: headers,
        body: json.encode(purchaseTicketsRequestDTO.toJson()),
      );

      if (response.statusCode == 201) {
        final List<dynamic> jsonList = json.decode(response.body);

        // ICI - La conversion se fait dans Ticket.fromJson()
        final purchasedTickets =
            jsonList.map((json) => Ticket.fromJson(json)).toList();

        print("Tickets achetés: ${purchasedTickets.length}");

        // Met à jour le cache
        _cachedTickets.addAll(purchasedTickets);

        return purchasedTickets;
      } else {
        throw Exception('Erreur achat tickets: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur lors de l\'achat des tickets: $e");

      throw Exception('Erreur réseau: $e');
    }
  }

  // 7. TRANSFER TICKETS (PUT /api/tickets/transferTickets)
  // sans cache
  Future<void> transferTickets(
      TransferTicketsRequestDTO transferTicketsRequestDTO) async {
    try {
      print(
          "Transfert de(s) tickets(s) vers toStudentId: ${transferTicketsRequestDTO.toStudentId}");

      final response = await http.put(
        Uri.parse('$baseUrl/transferTickets'),
        headers: headers,
        body: json.encode(transferTicketsRequestDTO.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur transfert tickets: ${response.statusCode}');
      }

      print(
          "Tickets transférés de ${transferTicketsRequestDTO.fromStudentId} vers ${transferTicketsRequestDTO.toStudentId}");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // 8. CANCEL TRANSFER TICKETS (PUT /api/tickets/cancelTransferTickets)
  // sans cache
  Future<void> cancelTransferTickets(
      CancelTransferTicketsRequestDTO cancelTransferTicketsRequestDTO) async {
    try {
      print(
          "Annuler transfert de(s) tickets(s) pour currentOwnerUserId: ${cancelTransferTicketsRequestDTO.currentOwnerUserId}");

      final response = await http.put(
        Uri.parse('$baseUrl/cancelTransferTickets'),
        headers: headers,
        body: json.encode(cancelTransferTicketsRequestDTO.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur annulation transfert tickets: ${response.statusCode}');
      }

      print(
          "Transfert de tickets annulé entre ${cancelTransferTicketsRequestDTO.currentOwnerUserId} et ${cancelTransferTicketsRequestDTO.originalSenderUserId}");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // 9. DEBIT ACCOUNT (PUT /api/tickets/debitAccount)
  // sans cache
  Future<void> debitAccount(
      DebitAccountRequestDTO debitAccountRequestDTO) async {
    try {
      print(
          "Debiter le compte dont l'ID est: ${debitAccountRequestDTO.studentId}");

      final response = await http.put(
        Uri.parse('$baseUrl/debitAccount'),
        headers: headers,
        body: json.encode(debitAccountRequestDTO.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur débit compte: ${response.statusCode}');
      }

      print("Compte ${debitAccountRequestDTO.studentId} débité");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // 10. UPDATE TICKET STATUS (PUT /api/tickets/ticketStatus/{ticketId})
  // sans cache
  Future<void> updateTicketStatus(
      int ticketId, TicketStatus ticketStatus) async {
    try {
      print("Mise à jour du statut de ticket avec ID : $ticketId");

      final response = await http.put(
        Uri.parse('$baseUrl/ticketStatus/$ticketId'),
        headers: headers,

        // CORRECTION: Utiliser forApi pour envoyer la valeur au backend au lieu de json.encode direct
        body: json.encode(
            ticketStatus.forApi), // ← ICI "Envoie seulement le nouveau statut"
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur mise à jour statut ticket: ${response.statusCode}');
      }

      print("Statut du ticket $ticketId mis à jour à: $ticketStatus");

      // "Met à jour le cache local"
      final index = _cachedTickets.indexWhere((t) => t.ticketId == ticketId);
      if (index != -1) {
        _cachedTickets[index] =
            _cachedTickets[index].copyWith(ticketStatus: ticketStatus);
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // 11. BOOK TICKET (PUT /api/tickets/book/{ticketId})
  Future<void> bookTicket(int ticketId) async {
    try {
      print("Réservation ticket avec ID: $ticketId");

      final response = await http.put(
        Uri.parse('$baseUrl/book/$ticketId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur réservation ticket: ${response.statusCode}');
      }

      print("Ticket $ticketId réservé");

      // "Met à jour le cache local"
      final index = _cachedTickets.indexWhere((t) => t.ticketId == ticketId);
      if (index != -1) {
        _cachedTickets[index] = _cachedTickets[index].copyWith(booked: true);
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // 12. UNBOOK TICKET (PUT /api/tickets/unbook/{ticketId})
  Future<void> unbookTicket(int ticketId) async {
    try {
      print("Annuler réservation du ticket avec ID: $ticketId");

      final response = await http.put(
        Uri.parse('$baseUrl/unbook/$ticketId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur annulation réservation ticket: ${response.statusCode}');
      }

      print("Réservation ticket $ticketId annulée");

      // "Met à jour le cache local"
      final index = _cachedTickets.indexWhere((t) => t.ticketId == ticketId);
      if (index != -1) {
        _cachedTickets[index] = _cachedTickets[index].copyWith(booked: false);
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // 13. READ TICKETS BY STATUS (GET /api/tickets/ticketStatus/{ticketStatus})
  Future<List<Ticket>> getTicketsByStatus(TicketStatus ticketStatus) async {
    try {
      print("Récupération du ticket via son statut: $ticketStatus");

      final response = await http.get(
        // CORRECTION : Utiliser forApi pour l'URL
        Uri.parse('$baseUrl/ticketStatus/${ticketStatus.forApi}'), // ← ICI
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        // ✅ Conversion correcte utilisant fromJson qui appelle lui-même fromApi
        return jsonList.map((json) => Ticket.fromJson(json)).toList();

        // ✅ CORRECTION : Utiliser fromApi pour convertir la réponse
        /* return jsonList.map((json) {
          // Supposons que le JSON contient un champ "ticketStatus"
          final statusFromApi = json['ticketStatus'] as String;
          final ticket = Ticket.fromJson(json);
          return ticket.copyWith(
              ticketStatus: TicketStatusExtension.fromApi(statusFromApi));
        }).toList(); */
      } else {
        throw Exception(
            'Erreur récupération tickets par statut: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // 14. READ TICKETS BY USER ID (GET /api/tickets/userId/{userId})
  Future<List<Ticket>> getTicketsByUserId(int userId) async {
    try {
      print("Récupération des tickets par usedId: $userId");

      final response = await http.get(
        Uri.parse('$baseUrl/userId/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Ticket.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur récupération tickets par utilisateur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // === MÉTHODES UTILITAIRES AVEC LOGIQUE MÉTIER LÉGÈRE ===

  // Recherche de tickets dans le cache local
  List<Ticket> searchTickets(String query) {
    print("Recherche de tickets avec clé: $query");

    if (query.isEmpty) return _cachedTickets;

    final queryLower = query.toLowerCase();

    // Recherche sur les noms d'affichage des enums
    return _cachedTickets
        .where((ticket) =>
                ticket.ticketType.displayName
                    .toLowerCase()
                    .contains(queryLower) ||
                /* ticket.ticketType
                    .toString()
                    .toLowerCase()
                    .contains(queryLower) || 
                 ticket.ticketStatus
                    .toString()
                    .toLowerCase()
                    .contains(queryLower) || */
                ticket.paymentCode.toLowerCase().contains(queryLower) ||
                ticket.ticketStatus.frenchLabel.toLowerCase().contains(
                    queryLower) || // → "Disponible", "Réservé", "Utilisé"
                ticket.ticketStatus.displayName
                    .toLowerCase()
                    .contains(queryLower) || // → "available", "booked", "used"
                ticket.userDTO.firstName.toLowerCase().contains(queryLower) ||
                ticket.userDTO.lastName.toLowerCase().contains(queryLower)
            // ticket.menu.menuName.toLowerCase().contains(queryLower)
            )
        .toList();

    /*  Resultat: exemple de recherche :
          "dispo" → trouve les tickets "Disponible"
          "réserv" → trouve les tickets "Réservé"  */
  }

  // Validation basique des données de ticket
  void validateTicketData(Ticket ticket) {
    // Vérifie que le type de ticket est valide (non null)
    // Les enums Dart ne peuvent pas être null si définis, mais bonne pratique
    if (ticket.ticketType == null) {
      throw Exception('Le type de ticket est requis');
    }
    /*  if (ticket.ticketType.toString().isEmpty) {
             throw Exception('Le type de ticket est requis');
          }
      */

    if (ticket.ticketPrice <= 0) {
      throw Exception('Le prix du ticket doit être positif');
    }

    if (ticket.ticketDescription.length < 3) {
      throw Exception('La description doit contenir au moins 3 caractères');
    }

    if (ticket.ticketDescription.length > 100) {
      throw Exception('La description ne peut pas dépasser 100 caractères');
    }
    // ✅ VALIDATION COHÉRENCE PRIX/TYPE
    if (ticket.ticketType == TicketType.a && ticket.ticketPrice < 100.0) {
      throw Exception('Le ticket type A doit coûter au moins 100F');
    }

    if (ticket.ticketType == TicketType.b && ticket.ticketPrice < 150.0) {
      throw Exception('Le ticket type B doit coûter au moins 150F');
    }
  }

  // Vide le cache (utile pour forcer un rafraîchissement)
  void clearCache() {
    _cachedTickets.clear();
    _lastFetchTime = null;
    print("Cache tickets vidé");
  }

  // "Filtre les tickets par statut"
  List<Ticket> filterTicketsByStatus(TicketStatus status) {
    // ICI: Filtrage local avec enums Dart purs
    return _cachedTickets
        .where((ticket) => ticket.ticketStatus == status)
        .toList();
  }

  // "Filtre les tickets par type"
  List<Ticket> filterTicketsByType(TicketType type) {
    // ICI: Filtrage local avec enums Dart purs
    return _cachedTickets
        .where((ticket) => ticket.ticketType == type)
        // (ticket) => ticket.ticketType.toLowerCase() == type.toLowerCase())
        .toList();
  }

  // "Filtre les tickets réservés/non réservés"
  List<Ticket> filterTicketsByBookedStatus(bool booked) {
    return _cachedTickets.where((ticket) => ticket.booked == booked).toList();
  }

  // "Trie les tickets par prix"
  List<Ticket> sortTicketsByPrice(bool ascending) {
    final sortedTickets = List<Ticket>.from(_cachedTickets);
    sortedTickets.sort((a, b) => ascending
        ? a.ticketPrice.compareTo(b.ticketPrice)
        : b.ticketPrice.compareTo(a.ticketPrice));
    return sortedTickets;
  }

  // "Trie les tickets par date de création"
  List<Ticket> sortTicketsByCreationDate(bool ascending) {
    final sortedTickets = List<Ticket>.from(_cachedTickets);
    sortedTickets.sort((a, b) => ascending
        ? a.ticketCreationDate.compareTo(b.ticketCreationDate)
        : b.ticketCreationDate.compareTo(a.ticketCreationDate));
    return sortedTickets;
  }

  /*
   * 📊 OBTENTION DES STATISTIQUES DES TICKETS
   * Logique de calcul pure - indépendante de l'état UI
   */
  Map<String, int> getTicketStatistics(List<Ticket> tickets) {
    final statistics = <String, int>{
      'total': tickets.length,
      'booked': tickets.where((t) => t.booked).length,
      'available': tickets.where((t) => !t.booked).length,
      'used': tickets.where((t) => t.ticketStatus == TicketStatus.used).length,
    };

    // Comptage par statut
    for (final ticket in tickets) {
      final statusKey = ticket.ticketStatus.forApi;
      statistics[statusKey] = (statistics[statusKey] ?? 0) + 1;
    }

    // Comptage par type
    for (final ticket in tickets) {
      final typeKey = ticket.ticketType.toBackend;
      statistics[typeKey] = (statistics[typeKey] ?? 0) + 1;
    }

    return statistics;
    /*
    exemple de resultat attendu 
    {
      'total': 15,
      'booked': 5,
      'available': 8,
      'used': 2,
      'AVAILABLE': 8,    // ← Clé cohérente avec le backend
      'BOOKED': 5,       // ← Clé cohérente avec le backend  
      'USED': 2,         // ← Clé cohérente avec le backend
      'A': 10,           // ← Clé cohérente avec le backend
      'B': 5             // ← Clé cohérente avec le backend
    }
    */
  }
}

  /*
    // READ TICKETS BY ACCOUNT ID (GET /api/tickets/accountId/{accountId})
  Future<List<Ticket>> getTicketsByAccountId(int accountId) async {
    try {
      print("Récupération des tickets par accountId: $accountId");

      final response = await http.get(
        Uri.parse('$baseUrl/accountId/$accountId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        return jsonList.map((json) => Ticket.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur récupération tickets par compte: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  } 

  // READ TICKETS BY MENU ID AND USER ID (GET /api/tickets/menuId/{menuId}/userId/{userId})
  Future<List<Ticket>> getTicketsByMenuIdAndUserId(
      int menuId, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menuId/$menuId/userId/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Ticket.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur récupération tickets par menu et utilisateur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // READ TICKETS BY MENU ID, USER ID AND STATUS (GET /api/tickets/menuId/{menuId}/userId/{userId}/status/{ticketStatus})
  Future<List<Ticket>> getTicketsByMenuIdAndUserIdAndStatus(
      String menuId, String userId, String ticketStatus) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/menuId/$menuId/userId/$userId/status/$ticketStatus'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Ticket.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur récupération tickets par menu, utilisateur et statut: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
  */
