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
class TicketProvider with ChangeNotifier {
  // "Crée une classe qui peut notifier ses écouteurs des changements"
  // Le mot-clé 'with' permet d'utiliser ChangeNotifier comme mixin
  // Cela permet à la classe de notifier les écouteurs quand l'état change
  // Le "_" rend ces variables privées à cette classe

  final TicketApiService _service;
  // Instance du service qui gère les appels API - injectée via le constructeur
  // Pas besoin de stocker UserProvider ici, on le récupère via Provider.of dans les méthodes

  // Remplacer la liste unique par deux listes séparées
  List<Ticket> _ticketsTypeA = [];
  List<Ticket> _ticketsTypeB = [];

  Ticket?
  _currentTicket; // ticket currently selected (null if any ticket selected)"

  bool _isLoading =
      false; // "Indicateur global de chargement (initialement false)"
  // true quand une opération asynchrone est en cours

  String _error = ''; // "Stocke les messages d'erreur (initialement vide)"
  // Stocke le dernier message d'erreur rencontré, vide string signifie aucune erreur

  // Ces booléens permettent de savoir quelle opération est en cours
  bool _isDebitingAccount = false;
  bool _isTransferringTickets = false;
  bool _isCancelingTransfer = false;

  // Le constructeur reçoit une instance de TicketApiService en paramètre (dependency injection)
  TicketProvider(this._service);

  // State for debit operation
  List<Ticket> _studentTicketsForDebit = [];
  TicketType? _selectedTicketTypeForDebit;
  List<int> _selectedTicketIdsForDebit = [];
  bool _isLoadingStudentTickets = false;

  // State for transferTickets operation
  String?
  _numberOfTicketsError; // Stocke les erreurs liées au nombre de tickets à transférer

  // State pour cancelTransfer operation
  TransactionHistoryDTO? _lastTransfer;
  String? _transactionIdError;

  // State for statistics
  TicketStatisticsDTO? _ticketStatistics;
  bool _isLoadingStatistics = false;

  // ******************** GETTERS *********************
  List<Ticket> get ticketsTypeA => _ticketsTypeA;
  List<Ticket> get ticketsTypeB => _ticketsTypeB;

  // Permet à d'autres classes de lire `_tickets` mais pas de le modifier
  Ticket? get currentTicket =>
      _currentTicket; // Retourne le ticket actuellement sélectionné (peut être null)
  bool get isLoading =>
      _isLoading; // Indique si une opération globale est en cours de chargement
  String get error => _error; // Retourne le dernier message d'erreur rencontré

  // Getters pour les booléens
  bool get isTransferringTickets => _isTransferringTickets;
  bool get isDebitingAccount => _isDebitingAccount;
  bool get isCancelingTransfer => _isCancelingTransfer;

  // Getters for debit operation
  List<Ticket> get studentTicketsForDebit => _studentTicketsForDebit;
  TicketType? get selectedTicketTypeForDebit => _selectedTicketTypeForDebit;
  List<int> get selectedTicketIdsForDebit => _selectedTicketIdsForDebit;
  int get selectedTicketsCount => _selectedTicketIdsForDebit.length;
  bool get isLoadingStudentTickets => _isLoadingStudentTickets;

  // Getters for transfer operation
  String? get numberOfTicketsError => _numberOfTicketsError;

  // Getters for cancelTransfer operation
  String? get transactionIdError => _transactionIdError;
  TransactionHistoryDTO? get lastTransfer => _lastTransfer;

  // Getters for statistics
  TicketStatisticsDTO? get ticketStatistics => _ticketStatistics;
  bool get isLoadingStatistics => _isLoadingStatistics;

  // Getter pour les statistiques de l'user connecté (pour StudentBody)
  UserTicketStats? get currentUserStats {
    if (_ticketStatistics == null) return null;
    // Le backend retourne les stats sous forme de Map avec le username comme clé
    // On récupère les stats du 1er user (si userId est passé) ou chercher par username
    final userStats = _ticketStatistics!.userStats;
    if (userStats.isEmpty) return null;
    // Retourner la 1ère entrée (celle de l'user connecté)
    return userStats.values.first;
  }

  // Getter pour les statistiques globales
  GlobalTicketStats? get globalStats => _ticketStatistics?.globalStats;

  // ******************** SETTERS ********************

  // Setters for transfer operation
  void setNumberOfTicketsError(String error) {
    _numberOfTicketsError = error;
    notifyListeners();
  }

  void setTransactionIdError(String error) {
    _transactionIdError = error;
    notifyListeners();
  }

  void setNumberOfTicketsIsInvalid(String error) {
    _numberOfTicketsError = error;
    notifyListeners();
  }

  void clearNumberOfTicketsError() {
    _numberOfTicketsError = '';
    notifyListeners();
  }

  // ******************** FOR DEBIT ACCOUNT OPERATION *******************
  // Fetch student's purchased tickets by user
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

      // ✅ Stocker dans la bonne liste selon le type (pour MyTicketsPage)
      if (type == TicketType.a) {
        _ticketsTypeA = tickets;
      } else if (type == TicketType.b) {
        _ticketsTypeB = tickets;
      }

      // ✅ Mettre aussi à jour studentTicketsForDebit (pour DebitPage)
      _studentTicketsForDebit = tickets;
      // Réinitialiser les sélections quand on change de type
      _selectedTicketIdsForDebit = [];

      _error = '';
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      print('[TicketProvider] getPurchasedTicketsByUser error: $e');
    } finally {
      _isLoading = false;
      _isLoadingStudentTickets = false;
      notifyListeners();
    }
  }

  // Ajouter une méthode pour injecter depuis le cache (mode hors-ligne)
  void setTicketsFromCache(List<Ticket> tickets) {
    _ticketsTypeA = tickets.where((t) => t.type == TicketType.a).toList();
    _ticketsTypeB = tickets.where((t) => t.type == TicketType.b).toList();
    notifyListeners();
  }

  // Toggle ticket selection for debit
  void toggleTicketSelectionForDebit(int ticketId) {
    final index = _studentTicketsForDebit.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      final ticket = _studentTicketsForDebit[index];
      final updatedTicket = ticket.copyWith(isSelected: !ticket.isSelected);
      _studentTicketsForDebit[index] = updatedTicket;

      if (updatedTicket.isSelected) {
        _selectedTicketIdsForDebit.add(ticketId);
      } else {
        _selectedTicketIdsForDebit.remove(ticketId);
      }
      notifyListeners();
    }
  }

  // Select all tickets for debit
  void selectAllTicketsForDebit() {
    for (var i = 0; i < _studentTicketsForDebit.length; i++) {
      _studentTicketsForDebit[i] = _studentTicketsForDebit[i].copyWith(
        isSelected: true,
      );
      _selectedTicketIdsForDebit.add(_studentTicketsForDebit[i].id!);
    }
    notifyListeners();
  }

  // Deselect all tickets for debit
  void deselectAllTicketsForDebit() {
    for (var i = 0; i < _studentTicketsForDebit.length; i++) {
      _studentTicketsForDebit[i] = _studentTicketsForDebit[i].copyWith(
        isSelected: false,
      );
    }
    _selectedTicketIdsForDebit.clear();
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

      // Clear selection after successful debit
      _selectedTicketIdsForDebit.clear();
      _studentTicketsForDebit = _studentTicketsForDebit
          .map((ticket) => ticket.copyWith(isSelected: false))
          .toList();

      _error = '';
      print("Compte de ${request.debitStudentDTO.username} débité avec succès");
      return true;
    } catch (e) {
      _error = 'Erreur débit compte: ${e.toString()}';
      print("Erreur debitAccount: $e");
      return false;
    } finally {
      _isDebitingAccount = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset debit state
  void resetDebitState() {
    _studentTicketsForDebit.clear();
    _selectedTicketTypeForDebit = null;
    _selectedTicketIdsForDebit.clear();
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
      _error = 'Erreur lors du transfert des tickets: ${e.toString()}';
      print("Erreur transferTickets: $e");
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
      final history = await _service.getTransactionHistoryById(transactionId);
      return history;
    } catch (e) {
      _error = 'Erreur lors de la récupération: ${e.toString()}';
      print("Erreur getTransactionHistoryById: $e");
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
      _error = 'Erreur lors de l\'annulation: ${e.toString()}';
      print("Erreur cancelTransfer: $e");
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

  // Méthode pour charger les statistiques
  Future<bool> loadTicketStatistics({int? userId}) async {
    _isLoadingStatistics = true;
    _error = '';
    notifyListeners();

    try {
      print("---------- CHARGEMENT DES STATISTIQUES ----------");
      print("User ID passé: $userId");

      _ticketStatistics = await _service.getTicketStatistics(userId: userId);
      // _error = '';
      /// Statistiques par utilisateur
      if (_ticketStatistics!.userStats.isNotEmpty) {
        print("--- STATISTIQUES UTILISATEUR ---");
        _ticketStatistics!.userStats.forEach((username, stats) {
          print("Utilisateur: $username");
          print("  - User ID: ${stats.userId}");
          print("  - Tickets achetés: ${stats.purchasedTicketsCount}");
          print("  - Tickets débités: ${stats.debitedTicketsCount}");
          print("  - Total tickets: ${stats.totalTicketsCount}");
        });
      } else {
        print("Aucune statistique utilisateur disponible");
      }

      /// Statistiques globales
      print("--- STATISTIQUES GLOBALES ---");
      print(
        "TT achetés (tous utilisateurs): ${_ticketStatistics!.globalStats.totalPurchasedTickets}",
      );
      print(
        "TT débités (tous comptes): ${_ticketStatistics!.globalStats.totalDebitedTickets}",
      );
      print(
        "TT traités (achetés + débités): ${_ticketStatistics!.globalStats.totalTicketsProcessed}",
      );
      _error = '';
      return true;
    } catch (e) {
      _error = 'Erreur lors du chargement des statistiques: ${e.toString()}';
      print("Erreur loadTicketStatistics: $e");
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

  // ==================== ACHAT — NOUVEAU SYSTÈME ====================

  int _countA = 0; // Nombre de tickets Type A à acheter
  int _countB = 0; // Nombre de tickets Type B à acheter

  int get countA => _countA;
  int get countB => _countB;
  double get totalAmount => _countA * 100.0 + _countB * 150.0;
  bool get hasSelection => (_countA + _countB) > 0;

  void incrementA() {
    _countA++;
    notifyListeners();
  }

  void decrementA() {
    if (_countA > 0) {
      _countA--;
      notifyListeners();
    }
  }

  void incrementB() {
    _countB++;
    notifyListeners();
  }

  void decrementB() {
    if (_countB > 0) {
      _countB--;
      notifyListeners();
    }
  }

  void resetSelection() {
    _countA = 0;
    _countB = 0;
    notifyListeners();
  }
}