import 'package:flutter/material.dart';
import 'package:senticket_front/model/transaction_history_model.dart';
import 'package:senticket_front/services/transaction_history_api_service.dart';

/// Provider pour gérer l'état de l'historique des transactions
class TransactionHistoryProvider extends ChangeNotifier {
  final TransactionHistoryApiService _service;

  // ==================== ÉTATS ====================

  /// Liste des transactions chargées
  List<TransactionHistoryDTO> _transactions = [];

  /// Indique si le chargement est en cours
  bool _isLoading = false;

  /// Message d'erreur éventuel
  String _error = '';

  /// Indique s'il y a plus de données à charger
  bool _hasMore = true;

  /// Page courante
  int _currentPage = 0;

  /// Taille de la page
  final int _pageSize = 20;

  // ==================== GETTERS ====================

  List<TransactionHistoryDTO> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasMore => _hasMore;

  // ==================== MÉTHODES ====================

  TransactionHistoryProvider(this._service);

  /// Charge les transactions avec les filtres spécifiés
  /// @param transactionType - Type de transaction à filtrer
  /// @param startDate - Date de début (optionnelle)
  /// @param endDate - Date de fin (optionnelle)
  /// @param reset - Si true, réinitialise la liste avant de charger
  Future<void> loadTransactions({
    String transactionType = 'ALL',
    DateTime? startDate,
    DateTime? endDate,
    bool reset = true,
  }) async {
    if (reset) {
      _transactions.clear();
      _currentPage = 0;
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print("========== CHARGEMENT HISTORIQUE ==========");
      print("Type: $transactionType");
      print("Page: $_currentPage");

      final response = await _service.getTransactionHistory(
        transactionType: transactionType,
        startDate: startDate,
        endDate: endDate,
        page: _currentPage,
        size: _pageSize,
      );

      // Ajouter les nouvelles transactions
      _transactions.addAll(response.content);
      _currentPage++;
      _hasMore = response.hasNext;

      print("Transactions chargées: ${response.content.length}");
      print("Total éléments: ${response.totalElements}");
      print("A plus de données: $_hasMore");

      _error = '';
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
      print("Erreur loadTransactions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Réinitialise l'état de l'historique
  void reset() {
    _transactions.clear();
    _currentPage = 0;
    _hasMore = true;
    _error = '';
    notifyListeners();
  }

  /// Charge les transactions pour un utilisateur spécifique (pour PORTIER)
  /// @param transactionType - Type de transaction à filtrer
  /// @param startDate - Date de début (optionnelle)
  /// @param endDate - Date de fin (optionnelle)
  /// @param userId - ID de l'utilisateur pour filtrer les transactions (portier)
  /// @param reset - Si true, réinitialise la liste avant de charger
  Future<void> loadTransactionsForUser({
    String transactionType = 'ALL',
    DateTime? startDate,
    DateTime? endDate,
    required int? userId,
    bool reset = true,
  }) async {
    if (reset) {
      _transactions.clear();
      _currentPage = 0;
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print("========== CHARGEMENT HISTORIQUE POUR UTILISATEUR ==========");
      print("Type: $transactionType");
      print("User ID: $userId");
      print("Page: $_currentPage");

      // Appel à l'API avec userId
      final response = await _service.getTransactionHistoryForUser(
        userId: userId,
        transactionType: transactionType,
        startDate: startDate,
        endDate: endDate,
        page: _currentPage,
        size: _pageSize,
      );

      _transactions.addAll(response.content);
      _currentPage++;
      _hasMore = response.hasNext;

      print("Transactions chargées: ${response.content.length}");
      print("Total éléments: ${response.totalElements}");
      print("A plus de données: $_hasMore");

      _error = '';
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
      print("Erreur loadTransactionsForUser: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
