import 'package:flutter/material.dart';
import 'package:senticket_front/model/transaction_history_model.dart';
import 'package:senticket_front/services/transaction_history_api_service.dart';

/// Ce provider gère l'état de l'historique des transactions :
/// - Stockage des transactions chargées
/// - Gestion du chargement (loading states)
/// - Gestion des erreurs
/// - Pagination pour le scroll infini
class TransactionHistoryProvider extends ChangeNotifier {
  final TransactionHistoryApiService _service;
  // CONSTRUCTEUR
  TransactionHistoryProvider(this._service);

  // ==================== ÉTATS INTERNES ====================
  /// Liste des transactions chargées
  List<TransactionHistoryDTO> _transactions = [];
  /// Indique si le chargement est en cours
  bool _isLoading = false;
  /// Message d'erreur (vide si aucune erreur)
  String _error = '';
  /// Indique s'il y a plus de données à charger(scroll infini)
  bool _hasMore = true;
  /// Page courante (0-indexé)
  int _currentPage = 0;
  /// Taille de la page
  final int _pageSize = 20;
  /// invalide les réponses d'un chargement périmé
  int _requestId = 0;

  // ==================== GETTERS ====================
  // Ces getters exposent l'état en lecture seule aux widgets UI
  List<TransactionHistoryDTO> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasMore => _hasMore;

  // ==================== MÉTHODES ====================
  /// Charge les transactions avec les filtres spécifiés
  /// @param transactionType - Type de transaction à filtrer
  /// @param startDate - Date de début (optionnelle)
  /// @param endDate - Date de fin (optionnelle)
  /// @param reset - Si true, réinitialise la liste avant de charger
  /// Historique global (ADMIN)
  /// Historique global (ADMIN)
  Future<void> loadTransactions({
    String transactionType = 'ALL',
    DateTime? startDate,
    DateTime? endDate,
    bool reset = true,
  }) =>
      _load(
        reset: reset,
        fetch: (page) => _service.getTransactionHistory(
          transactionType: transactionType,
          startDate: startDate,
          endDate: endDate,
          page: page,
          size: _pageSize,
        ),
      );

  /// Charge les transactions pour un utilisateur spécifique
  /// @param transactionType - Type de transaction à filtrer
  /// @param startDate - Date de début (optionnelle)
  /// @param endDate - Date de fin (optionnelle)
  /// @param userId - ID de l'utilisateur pour filtrer les transactions
  /// @param reset - Si true, réinitialise la liste avant de charger
  /// Historique d'un utilisateur
  Future<void> loadTransactionsForUser({
    String transactionType = 'ALL',
    DateTime? startDate,
    DateTime? endDate,
    required int? userId,
    bool reset = true,
  }) {
    if (userId == null) {
      _error = 'Utilisateur non identifié';
      notifyListeners();
      return Future.value();
    }
    return _load(
      reset: reset,
      fetch: (page) => _service.getTransactionHistoryForUser(
        userId: userId,
        transactionType: transactionType,
        startDate: startDate,
        endDate: endDate,
        page: page,
        size: _pageSize,
      ),
    );
  }

  Future<void> _load({
    required bool reset,
    required Future<TransactionHistoryResponseDTO> Function(int page) fetch,
  }) async {
    if (reset) {
      _transactions = [];
      _currentPage = 0;
      _hasMore = true;
      _requestId++;
      _isLoading = false; // un ancien chargement ne bloque plus le nouveau
    }
    if (_isLoading || !_hasMore) return;

    final myRequest = _requestId;
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await fetch(_currentPage);
      if (myRequest != _requestId) return; // réponse périmée
      _transactions.addAll(response.content);
      _currentPage++;
      _hasMore = response.hasNext;
    } catch (e) {
      if (myRequest == _requestId) _error = e.toString();
    } finally {
      if (myRequest == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Réinitialise l'état de l'historique
  void reset() {
    _transactions = [];
    _currentPage = 0;
    _hasMore = true;
    _error = '';
    _requestId++;
    _isLoading = false;
    notifyListeners();
  }
}
