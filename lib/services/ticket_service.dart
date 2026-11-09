import 'dart:convert';
import 'package:senticket_front/config/network_config.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/http/auth_http_client.dart';

import '../navigation/navigation_service.dart';

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
        throw Exception(
          'Erreur récupération tickets utilisateur: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erreur récupération tickets utilisateur: $e');
      rethrow;
    }
  }

  // ******************** FOR TRANSFER TICKETS OPERATION ************************
  Future<TransactionHistoryDTO> transferTickets(
    TransfertTicketRequestDTO request,
  ) async {
    try {
      print("************ TRANSFERT DE TICKETS **************");
      print("Expéditeur ID: ${request.senderDTO.senderId}");
      print("Destinataire: ${request.recipentDTO.recipientUsername}");
      print("Type: ${request.ticketType}");
      print("Nbr tickets: ${request.numberOfTicketsToTransfer}");

      final response = await _authClient.put(
        Uri.parse('$baseUrl/transferTickets'),
        headers: _jsonHeaders,
        body: json.encode(request.toJson()),
      );
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

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
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print("Erreur lors du transferTickets: $e");
      rethrow;
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
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return TransactionHistoryDTO.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Erreur récupération historique transaction: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("Erreur getTransactionHistoryById: $e");
      rethrow;
    }
  }

  // ******************** FOR CANCEL TRANSFER TICKETS OPERATION ************************

  // CANCEL TRANSFER TICKETS (PUT /api/tickets/cancelTransferTickets)
  Future<void> cancelTransfer(CancelTransferTicketsRequestDTO request) async {
    try {
      print("************** ANNULATION TRANSFERT **************");
      print("Transaction ID: ${request.cancelTransferDTO.transactionId}");

      final response = await _authClient.put(
        Uri.parse('$baseUrl/cancelTransfer'),
        headers: _jsonHeaders,
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

      final response = await _authClient.get(uri, headers: _jsonHeaders);

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return TicketStatisticsDTO.fromJson(jsonData);
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ??
            'Erreur récupération statistiques: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Erreur getTicketStatistics: $e");
      rethrow;
    }
  }
}

