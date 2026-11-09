import 'dart:convert';
import 'package:senticket_front/config/network_config.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/http/auth_http_client.dart';
import '../navigation/navigation_service.dart';
import 'package:http/http.dart' as http;
import 'package:senticket_front/core/utils/api_exception.dart';
import 'package:senticket_front/core/utils/error_handler.dart';


/// Appels API des tickets. Plus de cache ni d'achat direct :
/// les tickets sont créés par le backend à la confirmation du paiement.
/// ticket_service.dart: role(Communication API): utilise forApi, fromApi, toBackend, fromBackend
class TicketApiService {
  final baseUrl = '${NetworkConfig.baseUrl}/api/tickets';
  final transactionHistoryBaseUrl = '${NetworkConfig.baseUrl}/api/transactions';

  // Remplacer les headers statiques par le client authentifié
  final AuthHttpClient _authClient = AuthHttpClient(
      onUnauthorized: () => NavigationService.goToLogin()
  );

  // Configure HTTP headers for all requests
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json', // Indique au serveur "J'envoie du JSON"
    'Accept': 'application/json', // Indique au serveur "Je veux recevoir du JSON"
  };

  /// Lève une ApiException au message lisible
  Never _fail(http.Response r, String fallback) =>
      throw ApiException(ErrorHandler.fromResponse(r) ?? fallback);

  // ******************** FOR DEBITACCOUNT OPERATION ************************

  // DEBIT ACCOUNT (PUT /api/tickets/debit)
  // sans cache
  Future<void> debitAccount(
    DebitAccountRequestDTO debitAccountRequestDTO,
  ) async {
    try {
      print(
        "debitAccount de l'utilisateur ID: ${debitAccountRequestDTO.debitStudentDTO.debitStudentId}",
      );

      final response = await _authClient.put(
        Uri.parse('$baseUrl/debit'),
        headers: _jsonHeaders,
        body: json.encode(debitAccountRequestDTO.toJson()),
      );

      print("Status code débit: ${response.statusCode}");
      print("Response body débit: ${response.body}");

      if (response.statusCode == 200) {
        print("Débit effectué avec succès");
        return;
      } else {
        _fail(response, 'Le débit a échoué');
        /*final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Erreur de débit: ${response.statusCode}';
        throw Exception(errorMessage);*/
      }
    } catch (e) {
      print("Erreur debitAccount: $e");
      throw ApiException.from(e);
    }
  }

  // ── Tickets BOOKED d'un étudiant, par type ─────────────────────
  Future<List<Ticket>> getPurchasedTicketsByUser({
    required int userId,
    required String ticketType,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/user/$userId/purchased')
          .replace(queryParameters: {'ticketType': ticketType});
      final response = await _authClient.get(uri, headers: _jsonHeaders);

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        return list.map((j) => Ticket.fromJson(j)).toList();
      }
      else {
        _fail(response, 'Impossible de charger les tickets');
        /*throw Exception(
          'Erreur récupération tickets utilisateur: ${response.statusCode}',
        );*/
      }
    } catch (e) {
      print('Erreur getPurchasedTicketsByUser: $e');
      throw ApiException.from(e);
      //rethrow;
    }
  }

  // ******************** FOR TRANSFER TICKETS OPERATION ************************
  Future<TransactionHistoryDTO> transferTickets(
    TransfertTicketRequestDTO request,
  ) async {
    try {
      print("TRANSFERT DE TICKETS: ${request.numberOfTicketsToTransfer} tickets de Type: ${request.ticketType} de ${request.senderDTO.senderId} vers: ${request.recipentDTO.recipientUsername}");

      final response = await _authClient.put(
        Uri.parse('$baseUrl/transferTickets'),
        headers: _jsonHeaders,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return TransactionHistoryDTO.fromJson(jsonData);
      }
      else if (response.statusCode == 400) {
        final body = json.decode(response.body);
        final message = body['message'] as String? ?? 'Données invalides';

        // Message lisible selon le contenu
        if (message.contains('Invalid password') || message.contains('password')) {
          throw Exception('Mot de passe incorrect');
        } else if (message.contains('enough tickets') || message.contains('Available')) {
          throw Exception('Vous n\'avez pas assez de tickets de ce type');
        } else {
          throw Exception(message);
        }
      } else if (response.statusCode == 422) {
        final body = json.decode(response.body);
        throw Exception(body['message'] ?? 'Opération impossible');
      } else {
        // tout autre code HTTP (500, 403, etc.)
        _fail(response, 'Le transfert a échoué');
        //throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur transferTickets: $e");
      throw ApiException.from(e);
      //rethrow;
    }
  }

  // ******************** FOR GET TRANSACTION_HISTORY BY ID OPERATION ************************
  Future<TransactionHistoryDTO> getTransactionHistoryById(
    int transactionId,
  ) async {
    try {
      final response = await _authClient.get(
        Uri.parse('$transactionHistoryBaseUrl/$transactionId'),
        headers: _jsonHeaders,
      );

      if (response.statusCode == 200) {
        return TransactionHistoryDTO.fromJson(json.decode(response.body));
      } else {
        _fail(response, 'Transaction introuvable');
        /*throw Exception(
          'Erreur récupération historique transaction: ${response.statusCode}',
        );*/
      }
    } catch (e) {
      print("Erreur getTransactionHistoryById: $e");
      throw ApiException.from(e);
      //rethrow;
    }
  }

  // ******************** FOR CANCEL TRANSFER TICKETS OPERATION ************************

  // CANCEL TRANSFER TICKETS (PUT /api/tickets/cancelTransferTickets)
  Future<void> cancelTransfer(CancelTransferTicketsRequestDTO request) async {
    try {
      print("ANNULATION TRANSFERT pour la transaction ID: ${request.cancelTransferDTO.transactionId}");

      final response = await _authClient.put(
        Uri.parse('$baseUrl/cancelTransfer'),
        headers: _jsonHeaders,
        body: json.encode(request.toJson()),
      );
      if (response.statusCode == 200) {
        print("Annulation du transfert réussie");
        return;
      } else {
        _fail(response, "L'annulation a échoué");
        /*final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ?? 'Erreur annulation: ${response.statusCode}';
        throw Exception(errorMessage);*/
      }
    } catch (e) {
      print("Erreur cancelTransfer: $e");
      throw ApiException.from(e);
      //rethrow;
    }
  }

  // ******************** 📊 FOR STATISTICS OPERATION ************************

  /// Récupère les statistiques des tickets
  /// @param userId (optionnel) - ID de l'utilisateur pour les stats spécifiques
  /// @return TicketStatisticsDTO contenant toutes les statistiques
  Future<TicketStatisticsDTO> getTicketStatistics({int? userId}) async {
    try {
      print("************** RÉCUPÉRATION STATISTIQUES pour l'user ID: $userId");

      // Construire l'URL avec paramètre optionnel
      // Si userId est null, on récupère les statistiques globales
      final uri = Uri.parse('$baseUrl/statistics').replace(
        queryParameters: userId != null ? {'userId': '$userId'} : null, );

      final response = await _authClient.get(uri, headers: _jsonHeaders);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return TicketStatisticsDTO.fromJson(jsonData);
      } else {
        _fail(response, 'Impossible de charger les statistiques');
        /*final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ??
            'Erreur récupération statistiques: ${response.statusCode}';
        throw Exception(errorMessage);*/
      }
    } catch (e) {
      print("Erreur getTicketStatistics: $e");
      throw ApiException.from(e);
      //rethrow;
    }
  }
}

