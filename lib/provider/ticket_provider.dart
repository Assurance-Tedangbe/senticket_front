import 'package:flutter/material.dart';
import 'package:senticket_front/enums/ticket_type.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/services/ticket_service.dart';

/*
  Rôle Principal: Gestionnaire d'état centralisé pour les tickets
  Il sert de cerveau central:
   - Stocke l'état des tickets/gère l'état de l'UI
   - Coordonne les opérations sur les tickets 
   - Gère le loading et les erreurs
   - Notifie l'UI des changements/notifie les changements aux écouteurs
  Il sert d'intermédiaire entre l'UI et les services backend
  role(État UI + Coordination). Le Provider travaille avec les enums Dart, pas les conversions
*/

// "Crée une classe qui peut notifier ses écouteurs des changements"
// Le mot-clé 'with' permet d'utiliser ChangeNotifier comme mixin
// Cela permet à la classe de notifier les écouteurs quand l'état change
// Le "_" rend ces variables privées à cette classe
class TicketProvider with ChangeNotifier {
  // Instance du service qui gère les appels API - injectée via le constructeur
  // Pas besoin de stocker UserProvider ici, on le récupère via Provider.of dans les méthodes
  final TicketApiService _service;
  // Le constructeur reçoit une instance de TicketApiService en paramètre (dependency injection)
  TicketProvider(this._service);

  // ── Mes tickets (BOOKED) ───────────────────────────────────────
  List<Ticket> _ticketsTypeA = [];
  List<Ticket> _ticketsTypeB = [];

  // ── États généraux ─────────────────────────────────────────────
  // true quand une opération asynchrone est en cours
  bool _isLoading = false; // "Indicateur global de chargement (initialement false)"
  // Stocke le dernier message d'erreur rencontré, vide string signifie aucune erreur
  String _error = ''; // "Stocke les messages d'erreur (initialement vide)"
  // Ces booléens permettent de savoir quelle opération est en cours
  bool _isDebitingAccount = false;
  bool _isTransferringTickets = false;
  bool _isCancelingTransfer = false;

  // State for Débit ──────────────────────────────────────────────────────
  List<Ticket> _studentTicketsForDebit = [];
  bool _isLoadingStudentTickets = false;

  // State for Transfert ─────────────────────────────────────
  String? _numberOfTicketsError; // Stocke les erreurs liées au nombre de tickets à transférer

  // State pour cancelTransfer ─────────────────────────────────────
  TransactionHistoryDTO? _lastTransfer;
  String? _transactionIdError;

  // State for statistics ─────────────────────────────────────
  TicketStatisticsDTO? _ticketStatistics;
  bool _isLoadingStatistics = false;

  // *************** GETTERS *****************
  List<Ticket> get ticketsTypeA => _ticketsTypeA;
  List<Ticket> get ticketsTypeB => _ticketsTypeB;
  bool get isLoading => _isLoading; // Indique si une opération globale est en cours de chargement
  String get error => _error; // Retourne le dernier message d'erreur rencontré
  bool get isTransferringTickets => _isTransferringTickets;
  bool get isDebitingAccount => _isDebitingAccount;
  bool get isCancelingTransfer => _isCancelingTransfer;

  // Getters for debit operation
  List<Ticket> get studentTicketsForDebit => _studentTicketsForDebit;
  bool get isLoadingStudentTickets => _isLoadingStudentTickets;
  /// Calculé depuis la liste
  List<int> get selectedTicketIdsForDebit => _studentTicketsForDebit
      .where((t) => t.isSelected && t.id != null)
      .map((t) => t.id!)
      .toList();
  int get selectedTicketsCount => selectedTicketIdsForDebit.length;

  // Getters for transfer operation
  String? get numberOfTicketsError => _numberOfTicketsError;
  // Getters for cancelTransfer operation
  String? get transactionIdError => _transactionIdError;
  TransactionHistoryDTO? get lastTransfer => _lastTransfer;

  // Getters for statistics
  TicketStatisticsDTO? get ticketStatistics => _ticketStatistics;
  bool get isLoadingStatistics => _isLoadingStatistics;
  /// Getter pour les statistiques globales
  GlobalTicketStats? get globalStats => _ticketStatistics?.globalStats;
  /// Stats de l'utilisateur connecté (le backend ne renvoie que la sienne)
  UserTicketStats? get currentUserStats {
    if (_ticketStatistics == null) return null;
    // Le backend retourne les stats sous forme de Map avec le username comme clé
    // On récupère les stats du 1er user (si userId est passé) ou chercher par username
    final userStats = _ticketStatistics!.userStats;
    if (userStats.isEmpty) return null;
    // Retourner la 1ère entrée (celle de l'user connecté)
    return userStats.values.first;
  }

  // ****************** SETTERS ********************
  // Setters for transfer operation
  void setNumberOfTicketsError(String error) {
    _numberOfTicketsError = error;
    notifyListeners();
  }
  void setNumberOfTicketsIsInvalid(String error) => setNumberOfTicketsError(error);

  void setTransactionIdError(String error) {
    _transactionIdError = error;
    notifyListeners();
  }

  void clearNumberOfTicketsError() {
    _numberOfTicketsError = '';
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // *************** MES TICKETS *****************
  /// Charge les tickets A et B de l'étudiant (écran "Mes tickets", après paiement).
  /// Retourne false en cas d'erreur, pour permettre le repli sur le cache hors-ligne.
  Future<bool> loadMyTickets(int userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getPurchasedTicketsByUser(userId: userId, ticketType: TicketType.a.toBackend),
        _service.getPurchasedTicketsByUser(userId: userId, ticketType: TicketType.b.toBackend),
      ]);
      _ticketsTypeA = results[0];
      _ticketsTypeB = results[1];
      return true;
    } catch (e) {
      _error = e.toString();
      print('[TicketProvider] loadMyTickets: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ******************** FOR DEBIT ACCOUNT OPERATION *******************
  /// Fetch student's purchased tickets by user: charge un seul type dans "Mes tickets"
  Future<void> getPurchasedTicketsByUser({
    required int studentId,
    TicketType? type,
  }) async {
    _isLoading = true;
    _isLoadingStudentTickets = true;
    _error = '';
    notifyListeners();

    try {
      final tickets = await _service.getPurchasedTicketsByUser(
        userId: studentId,
        ticketType: type!.toBackend,
      );

      // ✅ Stocker dans la bonne liste selon le type
      if (type == TicketType.a) {
        _ticketsTypeA = tickets;
      } else {
        _ticketsTypeB = tickets;
      }

      _error = '';
     // return true;
    } catch (e) {
      _error = e.toString();
      //return false;
    } finally {
      _isLoading = false;
      _isLoadingStudentTickets = false;
      notifyListeners();
    }
  }

  /// injecter ticktes depuis le cache (mode hors-ligne)
  void setTicketsFromCache(List<Ticket> tickets) {
    _ticketsTypeA = tickets.where((t) => t.type == TicketType.a).toList();
    _ticketsTypeB = tickets.where((t) => t.type == TicketType.b).toList();
    notifyListeners();
  }

  /// Charge les tickets d'un étudiant pour le portier (liste séparée de "Mes tickets")
  Future<bool> getTicketsForDebit({
    required int studentId,
    required TicketType type,
  }) async {
    _isLoadingStudentTickets = true;
    _error = '';
    notifyListeners();
    try {
      _studentTicketsForDebit = await _service.getPurchasedTicketsByUser(
          userId: studentId, ticketType: type.toBackend);
      return true;
    } catch (e) {
      _studentTicketsForDebit = [];
      _error = e.toString();
      return false;
    } finally {
      _isLoadingStudentTickets = false;
      notifyListeners();
    }
  }

  // Toggle ticket selection for debit
  void toggleTicketSelectionForDebit(int ticketId) {
    final i = _studentTicketsForDebit.indexWhere((t) => t.id == ticketId);
    if (i == -1) return;
    final t = _studentTicketsForDebit[i];
    _studentTicketsForDebit[i] = t.copyWith(isSelected: !t.isSelected);
    notifyListeners();
  }

  // Select all tickets for debit
  void selectAllTicketsForDebit() {
    _studentTicketsForDebit =
        _studentTicketsForDebit.map((t) => t.copyWith(isSelected: true)).toList();
    notifyListeners();
  }

  void deselectAllTicketsForDebit() {
    _studentTicketsForDebit =
        _studentTicketsForDebit.map((t) => t.copyWith(isSelected: false)).toList();
    notifyListeners();
  }

  // Perform debit operation
  Future<bool> debitAccount(DebitAccountRequestDTO request) async {
    _isDebitingAccount = true;
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      await _service.debitAccount(request);
      // Les tickets débités disparaissent de la liste immédiatement
      final debited = request.ticketIds.toSet();
      _studentTicketsForDebit =
          _studentTicketsForDebit.where((t) => !debited.contains(t.id)).toList();
      _error = '';
      print("Compte de ${request.debitStudentDTO.username} débité avec succès");
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isDebitingAccount = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset debit state
  void resetDebitState() {
    _studentTicketsForDebit = [];
    _error = '';
    notifyListeners();
  }

  // ******************** FOR TRANSFER TICKETS OPERATION ************************
  Future<TransactionHistoryDTO?> transferTickets(
    TransfertTicketRequestDTO request,
  ) async {
    _isTransferringTickets = true;
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final history = await _service.transferTickets(request);
      _lastTransfer = history;
      _error = '';
      print("Transfert réussi, transaction ID: ${history.id}");
      return history;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isTransferringTickets = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ******************** FOR GET TRANSACTION HISTORY BY ID OPERATION ************************
  Future<TransactionHistoryDTO?> getTransactionHistoryById(
    int transactionId,
  ) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      return await _service.getTransactionHistoryById(transactionId);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ******************** ↩️ FOR CANCEL_TRANSFER OPERATION ************************
  // ANNULATION D'UN TRANSFERT DE TICKETS
  Future<bool> cancelTransfer(CancelTransferTicketsRequestDTO request) async {
    _isCancelingTransfer = true;
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      await _service.cancelTransfer(request);
      _error = '';
      print(
        "Annulation réussie pour transaction ID: ${request.cancelTransferDTO.transactionId}",
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isCancelingTransfer = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour effacer le dernier transfert
  void clearLastTransfer() {
    _lastTransfer = null;
    notifyListeners();
  }

  /// ******************** 📊 FOR STATISTICS OPERATION ************************
  Future<bool> loadTicketStatistics({int? userId}) async {
    _isLoadingStatistics = true;
    _error = '';
    notifyListeners();
    try {
      _ticketStatistics = await _service.getTicketStatistics(userId: userId);
      if (_ticketStatistics!.userStats.isNotEmpty) {
        print("--- STATS USER ---");
        _ticketStatistics!.userStats.forEach((username, stats) {
          print("  - User ID: ${stats.userId}, tickets achetés: ${stats.purchasedTicketsCount}, tickets débités: ${stats.debitedTicketsCount}, total tickets: ${stats.totalTicketsCount}");
        });
      } else {
        print("Aucune stat utilisateur disponible");
      }
      print("--- STATS GLOBALES ---");
      print("Total achetés (tous utilisateurs): ${_ticketStatistics!.globalStats.totalPurchasedTickets}");
      print("Total débités (tous comptes): ${_ticketStatistics!.globalStats.totalDebitedTickets}");
      print("Total traités (achetés + débités): ${_ticketStatistics!.globalStats.totalTicketsProcessed}");
      _error = '';
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoadingStatistics = false;
      notifyListeners();
    }
  }

  // Méthode pour réinitialiser les statistiques
  void clearStatistics() {
    _ticketStatistics = null;
    _error = '';
    notifyListeners();
  }
}