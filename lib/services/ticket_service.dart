import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:senticket_front/config/network_config.dart';
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
  final transferHistoryBaseUrl = '${NetworkConfig.baseUrl}/api/transferHistory';

  // Configure HTTP headers for all requests
  static final Map<String, String> headers = {
    'Content-Type': 'application/json', // Indique au serveur "J'envoie du JSON"
    'Accept':
        'application/json', // Indique au serveur "Je veux recevoir du JSON"
  };

  // CACHE SIMPLE INTÉGRÉ
  List<Ticket> _cachedTickets = []; // Cache des tickets
  DateTime? _lastFetchTime; // Dernière récupération
  static const Duration cacheDuration = Duration(minutes: 5); // Durée de cache

  // ******************** FOR GET ALL TICKETS OPERATION ************************

  // READ ALL TICKETS (GET /api/tickets). Using cache
  Future<List<Ticket>> getAllTickets({bool forceRefresh = false}) async {
    // "Vérifie si le cache est encore valide"
    final now = DateTime.now();

    final cacheValide =
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!) < cacheDuration;

    // "Retourne le cache si valide et pas de force refresh"
    if (!forceRefresh && cacheValide && _cachedTickets.isNotEmpty) {
      print("Retourne ${_cachedTickets.length} tickets depuis le cache");

      return _cachedTickets;
    }

    try {
      print("Récupération des tickets depuis l'API");

      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      if (response.statusCode == 200) {
        // "Convertit la réponse JSON → liste d'objets Ticket"
        print("JSON reçu : ${response.body}"); // <- Ajoutez ceci

        final List<dynamic> jsonList = json.decode(
          response.body,
        ); // "JSON string → Liste d'objets Dart"

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

  // ******************** FOR PURCHASE TICKETS OPERATION ************************

  // PURCHASE TICKETS (PUT /api/tickets/purchase)
  Future<List<Ticket>> purchaseTickets(
    PurchaseTicketsRequestDTO purchaseTicketsRequestDTO,
  ) async {
    try {
      print(
        "Achat de tickets par: ${purchaseTicketsRequestDTO.purchaseUserDTO.username}",
      );
      print("URL: $baseUrl/purchase");
      print("PurchaseUserDTO: ${purchaseTicketsRequestDTO.purchaseUserDTO.toJson()}",);
      print("Ticket IDs count: ${purchaseTicketsRequestDTO.selectedTicketIds.length}",);
      print("Ticket IDs: ${purchaseTicketsRequestDTO.selectedTicketIds}");

      final response = await http.put(
        Uri.parse('$baseUrl/purchase'),
        headers: headers,
        body: json.encode(({
          'purchaseUserDTO': {
            'userId': purchaseTicketsRequestDTO.purchaseUserDTO.userId,
            'username': purchaseTicketsRequestDTO.purchaseUserDTO.username,
          },
          'selectedTicketIds': purchaseTicketsRequestDTO.selectedTicketIds,
        })),
      );

      print("Status code: ${response.statusCode}");
      print("Response headers: ${response.headers}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        // ICI - La conversion se fait dans Ticket.fromJson()
        final purchasedTickets = jsonList
            .map((json) => Ticket.fromJson(json))
            .toList();

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

  // ******************** FOR DEBITACCOUNT OPERATION ************************

  // DEBIT ACCOUNT (PUT /api/tickets/debit)
  // sans cache
  Future<void> debitAccount(
    DebitAccountRequestDTO debitAccountRequestDTO,
  ) async {
    try {
      print(
        "Debiter le compte de l'utilisateur ID: ${debitAccountRequestDTO.debitStudentDTO.debitStudentId}",
      );

      final response = await http.put(
        Uri.parse('$baseUrl/debit'),
        headers: headers,
        body: json.encode(debitAccountRequestDTO.toJson()),
      );

      print("Status code débit: ${response.statusCode}");
      print("Response body débit: ${response.body}");
      /*       if (response.statusCode != 200) {
        throw Exception('Erreur débit compte: ${response.statusCode}');
      }

      print("Compte ${debitAccountRequestDTO.debitStudentDTO.username} débité");
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    } */
      if (response.statusCode == 200) {
        print("Débit effectué avec succès");
        return;
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Erreur de débit: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Erreur lors du débit: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<List<Ticket>> getPurchasedTicketsByUser({
    required int userId,
    bool? booked,
    String? ticketStatus,
    String? ticketType,
  }) async {
    try {
      print(
        "Récupération des tickets de type: $ticketType achetés par l'utilisateur: $userId",
      );

      // Build query parameters
      final params = <String, String>{'userId': userId.toString()};

      if (booked != null) {
        params['booked'] = booked.toString();
      }

      if (ticketStatus != null) {
        params['status'] = ticketStatus;
      }

      if (ticketType != null) {
        params['ticketType'] = ticketType;
      }
      final uri = Uri.parse(
        '$baseUrl/user/$userId/purchased',
      ).replace(queryParameters: params);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final tickets = jsonList.map((json) => Ticket.fromJson(json)).toList();

        print("${tickets.length} tickets trouvés pour l'utilisateur $userId");
        return tickets;
      } else {
        throw Exception(
          'Erreur récupération tickets utilisateur: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("Erreur récupération tickets utilisateur: $e");
      throw Exception('Erreur réseau: $e');
    }
  }

  // ******************** FOR TRANSFER TICKETS OPERATION ************************

  Future<TransfertHistoryDTO> transferTickets(
    TransfertTicketRequestDTO request,
  ) async {
    try {
      print("************ TRANSFERT DE TICKETS **************");
      print("Expéditeur ID: ${request.senderDTO.senderId}");
      print("Destinataire: ${request.recipentDTO.recipientUsername}");
      print("Type: ${request.ticketType}");
      print("Nbr tickets: ${request.numberOfTicketsToTransfer}");

      final response = await http.put(
        Uri.parse('$baseUrl/transferTickets'),
        headers: headers,
        body: json.encode(request.toJson()),
      );
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return TransfertHistoryDTO.fromJson(jsonData);
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ??
            'Erreur de transfert: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Erreur lors du transferTickets: $e");
      rethrow;
    }
  }
  // ******************** FOR GET TRANSFER_HISTORY BY ID OPERATION ************************

  Future<TransfertHistoryDTO> getTransferHistoryById(int transactionId) async {
    try {
      final response = await http.get(
        Uri.parse('$transferHistoryBaseUrl/$transactionId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return TransfertHistoryDTO.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Erreur récupération historique: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("Erreur getTransferHistoryById: $e");
      rethrow;
    }
  }

  // ******************** FOR CANCEL TRANSFER TICKETS OPERATION ************************

  // CANCEL TRANSFER TICKETS (PUT /api/tickets/cancelTransferTickets)
  Future<void> cancelTransfer(CancelTransferTicketsRequestDTO request) async {
    try {
      print("************** ANNULATION TRANSFERT **************");
      print("Transaction ID: ${request.cancelTransferDTO.transactionId}");

      final response = await http.put(
        Uri.parse('$baseUrl/cancelTransfer'),
        headers: headers,
        body: json.encode(request.toJson()),
      );
      if (response.statusCode == 200) {
        print("Annulation du transfert réussie");
        return;
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Erreur annulation: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Erreur annulation: $e");
      rethrow;
    }
  }

// ******************** 📊 FOR STATISTICS OPERATION ************************

  /// Récupère les statistiques des tickets
  /// @param userId (optionnel) - ID de l'utilisateur pour les stats spécifiques
  /// @return TicketStatisticsDTO contenant toutes les statistiques
  Future<TicketStatisticsDTO> getTicketStatistics({int? userId}) async {
    try {
      print("************** RÉCUPÉRATION STATISTIQUES **************");
      print("User ID: $userId");

      // Construire l'URL avec paramètre optionnel
      // Si userId est null, on récupère les statistiques globales
      final uri = userId != null
          ? Uri.parse('$baseUrl/statistics?userId=$userId')
          : Uri.parse('$baseUrl/statistics');

      final response = await http.get(uri, headers: headers);

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return TicketStatisticsDTO.fromJson(jsonData);
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Erreur récupération statistiques: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Erreur getTicketStatistics: $e");
      rethrow;
    }
  }
}

/*
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
          purchaseUserDTO: PurchaseUserDTO(userId: 0, username: ''),
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
      );

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
      } else {
        throw Exception(
          'Erreur récupération tickets par statut: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
*/


