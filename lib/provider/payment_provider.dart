// Provider pour gérer l'état du paiement dans l'application.
// Utilise le pattern ChangeNotifier pour notifier les widgets des changements.

import 'package:flutter/material.dart';
import 'package:senticket_front/model/payment_model.dart';
import 'package:senticket_front/services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentApiService _service;

  // ==================== ÉTATS ====================

  /// Indique si un paiement est en cours de traitement
  bool _isLoading = false;

  /// Message d'erreur (vide si aucune erreur)
  String _error = '';

  // ==================== CONSTRUCTEUR ====================

  PaymentProvider(this._service);

  // ==================== GETTERS ====================

  bool get isLoading => _isLoading;
  String get error => _error;

  // ==================== MÉTHODES ====================

  /// Initialise un nouveau paiement avec PayDunya.
  /// @param request PaymentInitiationDTO avec les informations du panier
  /// @return L'URL de paiement si succès, null sinon
  Future<String?> initiatePayment(PaymentInitiationDTO request) async {
    // Activer l'indicateur de chargement
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Appel au service API
      final response = await _service.initiatePayment(request);

      // Retourner l'URL de paiement
      return response.paymentUrl;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      // Désactiver l'indicateur de chargement
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Réinitialise l'état du provider.
  /// Utilisé après un paiement réussi ou une annulation.
  void reset() {
    _isLoading = false;
    _error = '';
    notifyListeners();
  }
}
