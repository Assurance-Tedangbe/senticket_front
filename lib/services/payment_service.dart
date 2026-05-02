// Service responsable des appels HTTP vers le backend pour les paiements.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:senticket_front/config/network_config.dart';
import 'package:senticket_front/model/payment_model.dart';

class PaymentApiService {
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
