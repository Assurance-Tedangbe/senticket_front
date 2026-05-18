// Provider pour gérer l'état du paiement dans l'application.
// Utilise le pattern ChangeNotifier pour notifier les widgets des changements.

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:senticket_front/enums/payment_state.dart';
import 'package:senticket_front/enums/payment_status.dart';
import 'package:senticket_front/model/payment_model.dart';
import 'package:senticket_front/services/payment_service.dart';

// PAYMENT PROVIDER
// Gestionnaire d'état central pour tout le flux de paiement PayDunya.
// Suit le même pattern que TicketProvider (ChangeNotifier + service injecté).
//
// Flux complet géré :
//   1. initiatePayment()  → appelle backend, passe en webViewOpen
//   2. onWebViewClosed()  → déclenche le polling
//   3. _startPolling()    → vérifie le statut toutes les 5s (max 5 min)
//   4. État terminal      → notifie l'UI du résultat (success/cancelled/failed)
class PaymentProvider with ChangeNotifier {
  final PaymentApiService _service;

  // ===== ÉTAT INTERNE =====
  PaymentState _state = PaymentState.idle;
  PaymentResponseDTO? _paymentResponse; // Réponse d'initiation (URL + token)
  String _error = ''; // Message d'erreur pour l'UI
  int _pollingAttempts = 0; // Compteur de tentatives de polling
  Timer? _pollingTimer; // Timer périodique (annulé dans dispose())

  // ===== CONSTANTES DE POLLING =====
  // 60 tentatives × 5s = 5 minutes maximum d'attente de confirmation
  static const int _maxPollingAttempts = 60;
  static const Duration _pollingInterval = Duration(seconds: 5);

  // ===== GETTERS PUBLICS =====

  PaymentState get state => _state;
  String get error => _error;
  int get pollingAttempts => _pollingAttempts;

  // Raccourcis pour les états (utilisés dans RequestSection)
  bool get isLoading => _state == PaymentState.loading;
  bool get isPolling => _state == PaymentState.polling;
  bool get isSuccess => _state == PaymentState.success;
  bool get isCancelled => _state == PaymentState.cancelled;
  bool get isFailed => _state == PaymentState.failed;
  bool get isWebViewOpen => _state == PaymentState.webViewOpen;
  bool get isIdle => _state == PaymentState.idle;

  // URL de paiement PayDunya (disponible quand état = webViewOpen)
  String? get paymentUrl => _paymentResponse?.paymentUrl;

  // Token de la transaction (utilisé pour le polling)
  String? get transactionId => _paymentResponse?.transactionId;

  // Constructeur : injection du service API de paiement
  PaymentProvider(this._service);

  // INITIER UN PAIEMENT AVEC PAYDUNYA
  // Appelée par RequestSection quand l'étudiant clique "Payer".
  // Prend les tickets sélectionnés du TicketProvider et initie le paiement.
  //
  // @param userId            ID de l'étudiant connecté (depuis UserProvider)
  // @param selectedTicketIds IDs des tickets sélectionnés (depuis TicketProvider)
  // @param totalAmount       Montant calculé par RequestSection
  // @param countA            Nombre de tickets Type A à regenérer (pour le backend)
  // @param countB            Nombre de tickets Type B à regenérer (pour le backend)
  Future<void> initiatePayment({
    required int userId,
    required List<int> selectedTicketIds,
    required double totalAmount,
    required int countA,
    required int countB,
  }) async {
    // Annuler tout paiement en cours (sécurité)
    _cancelPolling();
    _setState(PaymentState.loading);
    _error = '';

    try {
      // Construction de la requête d'initiation
      final request = PaymentInitiationDTO(
        userId: userId,
        selectedTicketIds: selectedTicketIds,
        totalAmount: totalAmount,
        countA: countA,
        countB: countB,
      );

      print('[PaymentProvider] Initiation paiement: $request');

      // Appel HTTP vers le backend Spring Boot
      _paymentResponse = await _service.initiatePayment(request);

      print('[PaymentProvider] URL reçue: ${_paymentResponse!.paymentUrl}');
      print('[PaymentProvider] Token: ${_paymentResponse!.transactionId}');

      // Signal à l'UI d'ouvrir le WebView avec l'URL PayDunya
      _setState(PaymentState.webViewOpen);
    } on PaymentServiceException catch (e) {
      print('[PaymentProvider] Erreur initiation: $e');
      _error = e.message;
      _setState(PaymentState.failed);
    } catch (e) {
      print('[PaymentProvider] Erreur inattendue: $e');
      _error = 'Une erreur inattendue s\'est produite. Réessayez.';
      _setState(PaymentState.failed);
    }
  }

  // FERMETURE DU WEBVIEW
  // Appelée par PaymentWebViewPage quand le WebView se ferme.
  // Deux cas :
  //   - cancelled=true  : URL /cancel détectée → état cancelled
  //   - cancelled=false : URL /return détectée → démarrer le polling
  //
  // @param cancelled  true si l'URL /cancel a été détectée
  void onWebViewClosed({bool cancelled = false}) {
    if (cancelled) {
      print('[PaymentProvider] Paiement annulé par l\'utilisateur');
      _setState(PaymentState.cancelled);
      return;
    }

    // L'utilisateur a potentiellement payé → démarrer la vérification
    print('[PaymentProvider] WebView fermé → démarrage polling...');
    _startPolling();
  }

  // DÉMARRAGE DU POLLING PÉRIODIQUE
  // Vérifie le statut du paiement toutes les 5 secondes.
  // Maximum 60 tentatives (5 minutes) avant d'abandonner.
  void _startPolling() {
    _pollingAttempts = 0;
    _setState(PaymentState.polling);

    // Vérification immédiate (sans attendre le premier timer)
    _checkStatus();

    // Timer périodique pour les vérifications suivantes
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _checkStatus();
    });
  }

  // Vérifie le statut actuel du paiement auprès du backend
  // Méthode privée appelée par le timer de polling
  Future<void> _checkStatus() async {
    // Sécurité : vérifier qu'on a un token valide
    if (_paymentResponse?.transactionId == null ||
        _paymentResponse!.transactionId.isEmpty) {
      _cancelPolling();
      return;
    }

    _pollingAttempts++;
    print(
      '[PaymentProvider] Polling #$_pollingAttempts/${_maxPollingAttempts}',
    );

    // Timeout : limite de tentatives atteinte
    if (_pollingAttempts > _maxPollingAttempts) {
      print(
        '[PaymentProvider] Timeout polling après $_pollingAttempts tentatives',
      );
      _cancelPolling();
      _error =
          'Délai d\'attente dépassé. Vérifiez votre solde mobile money '
          'et relancez l\'application si nécessaire.';
      _setState(PaymentState.failed);
      return;
    }

    try {
      // Appel au backend pour vérifier le statut PayDunya
      final result = await _service.checkPaymentStatus(
        _paymentResponse!.transactionId,
      );

      print('[PaymentProvider] Statut reçu: ${result.status}');

      // Traitement selon le statut
      switch (result.status) {
        case PaymentStatus.completed:
          // ✅ Succès : tickets attribués par le backend via le webhook
          _cancelPolling();
          _setState(PaymentState.success);
          break;

        case PaymentStatus.cancelled:
          // Annulé côté PayDunya (différent du cas /cancel détecté dans le WebView)
          _cancelPolling();
          _setState(PaymentState.cancelled);
          break;

        case PaymentStatus.failed:
          // Échec du paiement (solde insuffisant, etc.)
          _cancelPolling();
          _error = 'Le paiement a échoué. Vérifiez votre solde et réessayez.';
          _setState(PaymentState.failed);
          break;

        case PaymentStatus.pending:
        case PaymentStatus.unknown:
          // En attente ou statut inconnu → continuer le polling
          print(
            '[PaymentProvider] En attente... '
            '(tentative $_pollingAttempts/$_maxPollingAttempts)',
          );
          // Pas de setState ici, on continue le polling
          break;
      }
    } on PaymentServiceException catch (e) {
      // Erreur de service → logger mais ne pas arrêter le polling
      print('[PaymentProvider] Erreur service polling #$_pollingAttempts: $e');
    } catch (e) {
      // Erreur inattendue → logger mais continuer
      print('[PaymentProvider] Erreur polling inattendue: $e');
    }
  }

  // Arrête proprement le timer de polling
  void _cancelPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _pollingAttempts = 0;
  }

  // RÉINITIALISATION COMPLÈTE DE L'ÉTAT
  // Appelée quand :
  //   - L'utilisateur veut réessayer après un échec
  //   - L'utilisateur quitte la page de résultat
  //   - L'opération est complète et on revient à l'état initial
  void reset() {
    _cancelPolling();
    _paymentResponse = null;
    _error = '';
    _pollingAttempts = 0;
    _setState(PaymentState.idle);
    print('[PaymentProvider] État réinitialisé');
  }

  // Efface uniquement l'erreur (même pattern que TicketProvider.clearError())
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Met à jour l'état et déclenche la reconstruction des widgets écouteurs
  void _setState(PaymentState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    // Nettoyage obligatoire : annuler le timer pour éviter les memory leaks
    _cancelPolling();
    super.dispose();
  }
}

/*
class PaymentProvider extends ChangeNotifier {
  final PaymentApiService _service;

  /// Indique si un paiement est en cours de traitement
  bool _isLoading = false;
  String _error = '';

  PaymentProvider(this._service);

  bool get isLoading => _isLoading;
  String get error => _error;

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
*/
