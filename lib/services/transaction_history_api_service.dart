import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:senticket_front/config/network_config.dart';
import 'package:senticket_front/model/transaction_history_model.dart';

/// Service pour les appels API liés à l'historique des transactions
class TransactionHistoryApiService {
  final baseUrl = '${NetworkConfig.baseUrl}/api/transactions';

  /// Headers HTTP pour les requêtes
  static final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Récupère l'historique des transactions avec filtres
  /// @param transactionType - Type de transaction ("ALL", "PURCHASE", "DEBIT", "TRANSFER")
  /// @param startDate - Date de début (optionnelle)
  /// @param endDate - Date de fin (optionnelle)
  /// @param page - Numéro de la page (défaut 0)
  /// @param size - Taille de la page (défaut 20)
  /// @return TransactionHistoryResponseDTO contenant les transactions paginées
  Future<TransactionHistoryResponseDTO> getTransactionHistory({
    String transactionType = 'ALL',
    DateTime? startDate,
    DateTime? endDate,
    int page = 0,
    int size = 20,
  }) async {
    try {
      print("========== RÉCUPÉRATION HISTORIQUE ==========");
      print("Type: $transactionType");
      print("Page: $page, Size: $size");
      if (startDate != null) print("Date début: $startDate");
      if (endDate != null) print("Date fin: $endDate");

      // Construire les paramètres de la requête
      final params = <String, String>{
        'transactionType': transactionType,
        'page': page.toString(),
        'size': size.toString(),
      };

      if (startDate != null) {
        params['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        params['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      // Construire l'URI avec les paramètres
      final uri = Uri.parse(baseUrl).replace(queryParameters: params);

      print("URL: $uri");

      // Envoyer la requête GET
      final response = await http.get(uri, headers: headers);

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print("========== FIN RÉCUPÉRATION HISTORIQUE ==========");
        return TransactionHistoryResponseDTO.fromJson(jsonData);
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ??
            'Erreur récupération historique: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Erreur getTransactionHistory: $e");
      rethrow;
    }
  }

  /// Récupère l'historique des transactions pour un utilisateur spécifique
  /// @param userId - ID de l'utilisateur (portier pour ses débits, ou étudiant pour ses transactions)
  /// @param transactionType - Type de transaction ("ALL", "PURCHASE", "DEBIT", "TRANSFER")
  /// @param startDate - Date de début (optionnelle)
  /// @param endDate - Date de fin (optionnelle)
  /// @param page - Numéro de la page (défaut 0)
  /// @param size - Taille de la page (défaut 20)
  /// @return TransactionHistoryResponseDTO contenant les transactions paginées
  Future<TransactionHistoryResponseDTO> getTransactionHistoryForUser({
    required int? userId,
    String transactionType = 'ALL',
    DateTime? startDate,
    DateTime? endDate,
    int page = 0,
    int size = 20,
  }) async {
    try {
      print("========== RÉCUPÉRATION HISTORIQUE POUR UTILISATEUR ==========");
      print("User ID: $userId");
      print("Type: $transactionType");
      print("Page: $page, Size: $size");

      // Construire les paramètres de la requête
      final params = <String, String>{
        'userId': userId.toString(),
        'transactionType': transactionType,
        'page': page.toString(),
        'size': size.toString(),
      };

      if (startDate != null) {
        params['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        params['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final uri = Uri.parse('$baseUrl/user').replace(queryParameters: params);

      print("URL: $uri");

      final response = await http.get(uri, headers: headers);

      print("Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print("========== FIN RÉCUPÉRATION HISTORIQUE ==========");
        return TransactionHistoryResponseDTO.fromJson(jsonData);
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ??
            'Erreur récupération historique: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Erreur getTransactionHistoryForUser: $e");
      rethrow;
    }
  }
}
