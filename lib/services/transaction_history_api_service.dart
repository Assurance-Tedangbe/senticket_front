import 'dart:convert';
import 'package:senticket_front/config/network_config.dart';
import 'package:senticket_front/model/transaction_history_model.dart';
import 'package:senticket_front/http/auth_http_client.dart';
import '../navigation/navigation_service.dart';
import 'package:http/http.dart' as http;
import 'package:senticket_front/core/utils/api_exception.dart';
import 'package:senticket_front/core/utils/error_handler.dart';

/// Service pour les appels API liés à l'historique des transactions
/// Ce service est responsable de toutes les communications HTTP avec le backend
/// pour récupérer l'historique des transactions.
class TransactionHistoryApiService {
  /// URL de base pour les endpoints d'historique

  final baseUrl = '${NetworkConfig.baseUrl}/api/transactions';

  // Remplacer http.Client() par AuthHttpClient
  final AuthHttpClient _authClient = AuthHttpClient(
      onUnauthorized: () => NavigationService.goToLogin()
  );

  /// Headers HTTP communs à toutes les requêtes
  /// Indiquent que nous envoyons et attendons du JSON
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static String _day(DateTime d) => d.toIso8601String().split('T')[0];

  Map<String, String> _params({
    required String type,
    required int page,
    required int size,
    DateTime? start,
    DateTime? end,
  }) =>
      {
        'transactionType': type,
        'page': '$page',
        'size': '$size',
        if (start != null) 'startDate': _day(start),
        if (end != null) 'endDate': _day(end),
      };

  Future<TransactionHistoryResponseDTO> _fetch(Uri uri) async {
    try {
      final http.Response response =
      await _authClient.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return TransactionHistoryResponseDTO.fromJson(
            json.decode(response.body));
      }
      throw ApiException(ErrorHandler.fromResponse(response) ??
          "Impossible de charger l'historique");
    } catch (e) {
      print('Erreur historique: $e');
      throw ApiException.from(e);
    }
  }

  /// Historique global (ADMIN)
  /// MÉTHODE PRINCIPALE : RÉCUPÉRATION DE L'HISTORIQUE AVEC FILTRES
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
  }) =>
      _fetch(Uri.parse(baseUrl).replace(
        queryParameters: _params(
            type: transactionType,
            page: page,
            size: size,
            start: startDate,
            end: endDate),
      ));

  /// Historique d'un utilisateur
  /// Récupère l'historique des transactions pour un utilisateur spécifique
  /// @param userId - ID de l'utilisateur
  /// @param transactionType - Type de transaction
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
  }) =>
      _fetch(Uri.parse('$baseUrl/user').replace(
        queryParameters: {
          'userId': '$userId',
          ..._params(
              type: transactionType,
              page: page,
              size: size,
              start: startDate,
              end: endDate),
        },
      ));
}
