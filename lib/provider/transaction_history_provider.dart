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

  // ==================== GETTERS ====================
  // Ces getters exposent l'état en lecture seule aux widgets UI
  List<TransactionHistoryDTO> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasMore => _hasMore;

  // ==================== CONSTRUCTEUR ====================
  TransactionHistoryProvider(this._service);

  // ==================== MÉTHODES ====================

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

    // Évite les chargements multiples et le chargement si fin des données
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print("========== CHARGEMENT HISTORIQUE ==========");
      print("Type: $transactionType");
      print("Page: $_currentPage");

      // Appel au service API
      final response = await _service.getTransactionHistory(
        transactionType: transactionType,
        startDate: startDate,
        endDate: endDate,
        page: _currentPage,
        size: _pageSize,
      );

      // Ajout des nouvelles transactions à la liste existante
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

  /// Charge les transactions pour un utilisateur spécifique
  /// @param transactionType - Type de transaction à filtrer
  /// @param startDate - Date de début (optionnelle)
  /// @param endDate - Date de fin (optionnelle)
  /// @param userId - ID de l'utilisateur pour filtrer les transactions
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
