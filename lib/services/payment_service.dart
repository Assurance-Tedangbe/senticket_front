// Service responsable des appels HTTP vers le backend pour les paiements.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:senticket_front/config/network_config.dart';
import 'package:senticket_front/model/payment_model.dart';
import 'package:senticket_front/http/auth_http_client.dart';

import '../navigation/navigation_service.dart';


// SERVICE HTTP PAIEMENT
// Responsable de TOUTES les communications HTTP avec les
// endpoints paiement du backend Spring Boot.
//
// Suit exactement le même pattern que TicketApiService :
//   - Utilise NetworkConfig.baseUrl pour l'URL de base
//   - Utilise les mêmes headers HTTP
//   - Gère les erreurs de la même façon
//
// Endpoints couverts :
//   POST /api/payments/initiate       → initiatePayment()
//   GET  /api/payments/status/{token} → checkPaymentStatus()
//
// NB : Le webhook (/api/payments/webhook) est appelé par PayDunya
//   directement sur le backend (serveur→serveur), pas par Flutter.
class PaymentApiService {
  // URL de base pour les endpoints de paiement
  final String _baseUrl = '${NetworkConfig.baseUrl}/api/payments';
  static const Duration _timeout = Duration(seconds: 30);

  // Remplacer http.Client() par AuthHttpClient
  final AuthHttpClient _authClient = AuthHttpClient(
      onUnauthorized: () => NavigationService.goToLogin()
  );

  // Headers HTTP communs à toutes les requêtes (application/json)
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // INITIER UN PAIEMENT PAYDUNYA
  //
  // Appelée par PaymentProvider.initiatePayment() quand l'utilisateur
  // clique sur "Confirmer le paiement" dans RequestSection.
  //
  // Flux :
  //   Flutter → POST /api/payments/initiate
  //   Backend → crée facture PayDunya → retourne URL + token
  //   Flutter ← PaymentResponse (paymentUrl + transactionId)
  //
  // @param request  Détails du panier (userId, tickets, montant)
  // @return PaymentResponse avec l'URL de paiement et le token PayDunya
  // @throws PaymentServiceException si erreur HTTP ou réseau
  Future<PaymentResponseDTO> initiatePayment(
    PaymentInitiationDTO request,
  ) async {
    final url = Uri.parse('$_baseUrl/initiate');

    try {
      print('============ INITIATION PAIEMENT PAYDUNYA ============');
      print('URL: $url');
      print('Payload: ${jsonEncode(request.toJson())}');

      // Envoi de la requête POST avec le payload JSON sérialisé
      // _authClient.post au lieu de http.post
      final response = await _authClient
          .post(url, headers: _headers, body: jsonEncode(request.toJson()))
          .timeout(_timeout);

      print('Status code initiation: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Succès HTTP 200 → désérialiser la réponse
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(
          utf8.decode(
            response.bodyBytes,
          ), // Décodage UTF-8 pour les accents français
        );
        final paymentResponse = PaymentResponseDTO.fromJson(jsonData);
        print('Transaction ID: ${paymentResponse.transactionId}');
        print('Payment URL: ${paymentResponse.paymentUrl}');
        return paymentResponse;
      }

      // Erreur métier du backend (400, 422, 500, etc.)
      // Extraire le message d'erreur du corps de la réponse si disponible
      String errorMessage = 'Erreur serveur [${response.statusCode}]';
      try {
        final errorJson = jsonDecode(response.body);
        errorMessage = errorJson['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw PaymentServiceException(
        errorMessage,
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw PaymentServiceException(
        'Le serveur ne répond pas. Vérifiez votre connexion internet.',
        statusCode: 408,
      );
    } on SocketException {
      throw PaymentServiceException(
        'Impossible de joindre le serveur. Vérifiez votre connexion réseau.',
        statusCode: 0,
      );
    } on PaymentServiceException {
      rethrow; // Re-propager sans wrapper
    } catch (e) {
      throw PaymentServiceException('Erreur inattendue: $e');
    }
  }

  // VÉRIFIER LE STATUT D'UN PAIEMENT (POLLING)
  //
  // Appelée périodiquement par PaymentProvider._checkStatus() toutes les 5s.
  // Le backend interroge PayDunya et retourne le statut actuel.
  //
  // Flux :
  //   Flutter → GET /api/payments/status/{token}
  //   Backend → interroge PayDunya → retourne String statut
  //   Flutter ← "COMPLETED" / "PENDING" / "CANCELLED" / etc.
  //
  // En cas d'erreur réseau temporaire, retourne UNKNOWN plutôt que
  // de lancer une exception (le polling continuera à la prochaine tentative).
  //
  // @param transactionId  Token PayDunya (ex: "test_H5vmmOaMa1")
  // @return PaymentStatusResult avec le statut parsé
  Future<PaymentStatusResult> checkPaymentStatus(String transactionId) async {
    final url = Uri.parse('$_baseUrl/status/$transactionId');

    try {
      print('Polling statut - Token: $transactionId');

      final response = await _authClient.get(url, headers: _headers).timeout(_timeout);

      print(
        'Polling - Status code: ${response.statusCode}, Body: ${response.body}',
      );

      if (response.statusCode == 200) {
        // Le backend retourne une simple String (ex: "COMPLETED")
        // sans encapsulation JSON supplémentaire
        final statusStr = response.body.trim();
        return PaymentStatusResult.fromString(transactionId, statusStr);
      }

      // En cas d'erreur HTTP pendant le polling, retourner PENDING
      // pour éviter d'interrompre le polling prématurément
      print('Polling erreur HTTP ${response.statusCode}, continuation...');
      return PaymentStatusResult.fromString(transactionId, 'PENDING');
    } on TimeoutException {
      // Timeout réseau : retourner PENDING pour continuer le polling
      print('Polling timeout, continuation...');
      return PaymentStatusResult.fromString(transactionId, 'PENDING');
    } on SocketException {
      // Pas de connexion : retourner UNKNOWN mais continuer le polling
      print('Polling SocketException, continuation...');
      return PaymentStatusResult.fromString(transactionId, 'UNKNOWN');
    } catch (e) {
      print('Polling erreur inattendue: $e, continuation...');
      return PaymentStatusResult.fromString(transactionId, 'UNKNOWN');
    }
  }
}

// EXCEPTION PERSONNALISÉE PAIEMENT
// Suit le même pattern que les exceptions levées dans TicketApiService.
// Permet à PaymentProvider de distinguer les erreurs paiement
// et d'afficher des messages adaptés dans l'UI.
class PaymentServiceException implements Exception {
  final String message; // Message lisible pour l'utilisateur
  final int? statusCode; // Code HTTP si disponible (null si erreur réseau)

  PaymentServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'PaymentServiceException[$statusCode]: $message';
}

///////////////////////////////////////////////////////////////
/* class PaymentApiService {
  /// URL de base pour les endpoints de paiement
  final String baseUrl = '${NetworkConfig.baseUrl}/api/payments';

  /// Headers HTTP communs
  static final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Appelle le backend pour initier un paiement PayDunya.
  /// @param request PaymentInitiationDTO contenant les informations du panier
  /// @return PaymentResponseDTO contenant l'URL de paiement et l'ID de transaction
  /// @throws Exception en cas d'erreur
  Future<PaymentResponseDTO> initiatePayment(
    PaymentInitiationDTO request,
  ) async {
    try {
      print("========== INITIATION PAIEMENT ==========");
      print("User ID: ${request.userId}");
      print("Montant: ${request.totalAmount} FCFA");

      // Envoi de la requête POST au backend
      final response = await http.post(
        Uri.parse('$baseUrl/initiate'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // Succès: décoder la réponse JSON
        return PaymentResponseDTO.fromJson(json.decode(response.body));
      } else {
        // Erreur: extraire le message d'erreur
        final errorBody = json.decode(response.body);
        throw Exception(
          errorBody['message'] ?? 'Erreur d\'initiation du paiement',
        );
      }
    } catch (e) {
      print("Erreur initiatePayment: $e");
      rethrow;
    }
  }
}
 */
