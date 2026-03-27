import 'package:flutter/material.dart';
import 'package:senticket_front/enums/ticket_status.dart';
import 'package:senticket_front/enums/ticket_type.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/services/ticket_service.dart';
import 'package:provider/provider.dart';

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

  List<Ticket> _tickets =
      []; // "Liste vide pour stocker tous les tickets chargés depuis l'API"

  Ticket? _currentTicket; // ticket currently selected (null if any ticket selected)"

  bool _isLoading = false; // "Indicateur global de chargement (initialement false)"
  // true quand une opération asynchrone est en cours

  String _error = ''; // "Stocke les messages d'erreur (initialement vide)"
  // Stocke le dernier message d'erreur rencontré, vide string signifie aucune erreur

  // Ces booléens permettent de savoir quelle opération est en cours
  bool _isPurchasingTickets =
      false; // Achat en cours. True only during purchase operation
  bool _isDebitingAccount = false;
  bool _isTransferringTickets = false;
  bool _isCancelingTransfer = false;
  /*    
  bool _isCreatingTickets = false;
  bool _isUpdatingTicket = false;
  bool _isDeletingTicket = false;
  bool _isUpdatingTicketStatus = false;
  bool _isBookingTicket = false;
  bool _isUnbookingTicket = false;
 ; */

  // Le constructeur reçoit une instance de TicketApiService en paramètre (dependency injection)
  TicketProvider(this._service);

  // State for debit operation
  List<Ticket> _studentTicketsForDebit = [];
  TicketType? _selectedTicketTypeForDebit;
  List<int> _selectedTicketIdsForDebit = [];
  bool _isLoadingStudentTickets = false;

  // State for transferTickets operation
  String? _numberOfTicketsError; // Stocke les erreurs liées au nombre de tickets à transférer

  // State pour cancelTransfer operation
  TransfertHistoryDTO? _lastTransfer;
  String? _transactionIdError;
  SenderDTO? _lastSenderDTO;
  RecipientDTO? _lastRecipientDTO;
  List<int> _lastTicketIds = [];

  // State for statistics
  TicketStatisticsDTO? _ticketStatistics;
  bool _isLoadingStatistics = false;

  // ******************** GETTERS *********************

  // Getters principaux
  List<Ticket> get tickets =>
      _tickets; // Retourne la liste complète des tickets
  // Permet à d'autres classes de lire `_tickets` mais pas de le modifier
  Ticket? get currentTicket =>
      _currentTicket; // Retourne le ticket actuellement sélectionné (peut être null)
  bool get isLoading =>
      _isLoading; // Indique si une opération globale est en cours de chargement
  String get error => _error; // Retourne le dernier message d'erreur rencontré

  // Getters pour les booléens
  bool get isPurchasingTickets =>
      _isPurchasingTickets; // Indique si un achat est en cours
  bool get isTransferringTickets => _isTransferringTickets;
  bool get isDebitingAccount => _isDebitingAccount;
  bool get isCancelingTransfer => _isCancelingTransfer;
  /* bool get isCreatingTickets => _isCreatingTickets;
  bool get isUpdatingTicket => _isUpdatingTicket;
  bool get isDeletingTicket => _isDeletingTicket;
  bool get isUpdatingTicketStatus => _isUpdatingTicketStatus;
  bool get isBookingTicket => _isBookingTicket; */

  // Getters pour les tickets filtrés - buyTicket
  List<Ticket> get availableTickets => _tickets
      .where((ticket) => ticket.status == TicketStatus.available)
      .toList();

  List<Ticket> get ticketsA =>
      availableTickets.where((ticket) => ticket.type == TicketType.a).toList();

  List<Ticket> get ticketsB =>
      availableTickets.where((ticket) => ticket.type == TicketType.b).toList();

  List<Ticket> get selectedTickets =>
      _tickets.where((ticket) => ticket.isSelected).toList();

  // Getters for debit operation
  List<Ticket> get studentTicketsForDebit => _studentTicketsForDebit;
  TicketType? get selectedTicketTypeForDebit => _selectedTicketTypeForDebit;
  List<int> get selectedTicketIdsForDebit => _selectedTicketIdsForDebit;
  int get selectedTicketsCount => _selectedTicketIdsForDebit.length;
  bool get isLoadingStudentTickets => _isLoadingStudentTickets;

  // Getters for transfer operation
  String? get numberOfTicketsError => _numberOfTicketsError;

  // Getters for cancelTransfer operation
  TransfertHistoryDTO? get lastTransfer => _lastTransfer;
  String? get transactionIdError => _transactionIdError;
  // SenderDTO? get lastSenderDTO => _lastSenderDTO;
  // RecipientDTO? get lastRecipientDTO => _lastRecipientDTO;
  // List<int> get lastTicketIds => _lastTicketIds;

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

  // Getter pour les statistiques des tickets disponibles
  AvailableTicketsStats? get availableStats => _ticketStatistics?.availableStats;

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

  // ******************** FOR LOADING ALL TICKETS OPERATION *************************

  /* @param forceRefresh : si true, ignore le cache et force le rechargement */
  Future<void> loadAllTickets({bool forceRefresh = false}) async {
    _isLoading = true; // active le chargement
    _error = ''; // efface les erreurs précédentes
    notifyListeners(); // notifie tous les écouteurs (UI) que l'état a changé/du début du chargement
    // Notifie tous les widgets écoutant ce provider

    try {
      _tickets = await _service.getAllTickets(
        forceRefresh: forceRefresh,
      ); // "récupère tous les tickets depuis l'API via le service"

      // Si succès : mise à jour de la liste et effacement des erreurs
      _error = ''; // "Confirme qu'il n'y a pas d'erreurs"
      print("Chargement réussi : ${_tickets.length} tickets");
    } catch (e) {
      _error = e.toString(); // "Stocke l'erreur"
      print("Erreur loadAllTickets: $e");
    } finally {
      _isLoading = false; // "arrête le chargement"
      notifyListeners(); // "notifie l'UI de la fin du chargement"
    }
  }

  // ********************* FOR PURCHASING TICKETS OPERATION ***********************

  Future<bool> purchaseTicketsWithContext(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Vérifier si l'utilisateur est connecté
    if (userProvider.currentUser == null) {
      _error = 'Vous devez être connecté pour acheter des tickets';
      notifyListeners();
      return false;
    }
    // Vérifier si l'utilisateur a le rôle ETUDIANT
    final user = userProvider.currentUser!;
    final isStudent = user.role.name.toUpperCase() == 'ETUDIANT';
    if (!isStudent) {
      _error = 'Seuls les étudiants peuvent acheter des tickets';
      notifyListeners();
      return false;
    }
    final selected = selectedTickets;
    if (selected.isEmpty) {
      _error = 'Veuillez sélectionner des tickets';
      notifyListeners();
      return false;
    }
    _isPurchasingTickets = true;
    _error = '';
    notifyListeners();
    try {
      final ticketIds = selected.map((t) => t.id!).toList();

      // Créer le PurchaseUserDTO avec l'utilisateur connecté
      final purchaseUserDTO = PurchaseUserDTO(
        userId: user.userId!, // userId ne doit pas être null
        username: user.username,
      );

      final purchaseRequest = PurchaseTicketsRequestDTO(
        purchaseUserDTO: purchaseUserDTO,
        selectedTicketIds: ticketIds,
      );
      print("Envoi de la requête d'achat...");
      print("PurchaseUserDTO: ${purchaseUserDTO.toJson()}");
      print("Ticket IDs: $ticketIds");
      // print("Request JSON: ${purchaseRequest.toJsonString()}");

      final purchasedTickets = await _service.purchaseTickets(purchaseRequest);

      if (purchasedTickets.isNotEmpty) {
        // Recharger les tickets après achat réussi
        await loadAllTickets(forceRefresh: true);
        _error = '';
        return true;
      } else {
        _error = 'Aucun ticket n\'a été acheté';
        return false;
      }
    } catch (e) {
      _error = 'Erreur lors de l\'achat: $e';
      print("Erreur détaillée: $e");
      return false;
    } finally {
      _isPurchasingTickets = false;
      notifyListeners();
    }
  }

  // Pour gérer la sélection/désélection
  void toggleTicketSelection(int ticketId) {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      _tickets[index] = _tickets[index].copyWith(
        isSelected: !(_tickets[index].isSelected),
      );
      notifyListeners();
    }
  }

  void selectAllTicketsA() {
    for (var ticket in _tickets) {
      if (ticket.type == TicketType.a &&
          ticket.status == TicketStatus.available) {
        final index = _tickets.indexWhere((t) => t.id == ticket.id);
        if (index != -1) {
          _tickets[index] = _tickets[index].copyWith(isSelected: true);
        }
      }
    }
    notifyListeners();
  }

  void selectAllTicketsB() {
    for (var ticket in _tickets) {
      if (ticket.type == TicketType.b &&
          ticket.status == TicketStatus.available) {
        final index = _tickets.indexWhere((t) => t.id == ticket.id);
        if (index != -1) {
          _tickets[index] = _tickets[index].copyWith(isSelected: true);
        }
      }
    }
    notifyListeners();
  }

  void clearAllSelections() {
    for (var i = 0; i < _tickets.length; i++) {
      if (_tickets[i].isSelected == true) {
        _tickets[i] = _tickets[i].copyWith(isSelected: false);
      }
    }
    notifyListeners();
  }

  //🧹 Nettoie l'erreur courante et notifie l'UI
  void clearError() {
    _error = '';
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
    _selectedTicketTypeForDebit = type;
    notifyListeners();

    try {
      _studentTicketsForDebit = await _service.getPurchasedTicketsByUser(
        userId: studentId,
        booked: true,
        ticketStatus: 'BOOKED',
        ticketType: type?.toBackend,
      );

      // Filter only booked and BOOKED status tickets
      _studentTicketsForDebit = _studentTicketsForDebit
          .where(
            (ticket) => ticket.booked && ticket.status == TicketStatus.booked,
          )
          .toList();

      // Reset selection
      _selectedTicketIdsForDebit.clear();
      _studentTicketsForDebit = _studentTicketsForDebit
          .map((ticket) => ticket.copyWith(isSelected: false))
          .toList();

      _error = '';
      print("Tickets trouvés pour débit: ${_studentTicketsForDebit.length}");
    } catch (e) {
      _error = 'Erreur lors du chargement des tickets: $e';
      _studentTicketsForDebit.clear();
    } finally {
      _isLoading = false;
      _isLoadingStudentTickets = false;
      notifyListeners();
    }
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

  Future<TransfertHistoryDTO?> transferTickets(
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

  // ******************** FOR GET TRANSFER_HISTORY BY ID OPERATION ************************

  Future<TransfertHistoryDTO?> getTransferHistoryById(int transactionId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final history = await _service.getTransferHistoryById(transactionId);
      return history;
    } catch (e) {
      _error = 'Erreur lors de la récupération: ${e.toString()}';
      print("Erreur getTransferHistoryById: $e");
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
      print("TT achetés (tous utilisateurs): ${_ticketStatistics!.globalStats.totalPurchasedTickets}");
      print("TT débités (tous comptes): ${_ticketStatistics!.globalStats.totalDebitedTickets}");
      print("TT traités (achetés + débités): ${_ticketStatistics!.globalStats.totalTicketsProcessed}");

      /// Statistiques des tickets disponibles
      print("--- STATISTIQUES TICKETS DISPONIBLES ---");
      print("T. Type A disponibles: ${_ticketStatistics!.availableStats.typeATicketsAvailable}");
      print("T. Type B disponibles: ${_ticketStatistics!.availableStats.typeBTicketsAvailable}");
      print("TT disponibles: ${_ticketStatistics!.availableStats.totalTicketsAvailable}");

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
}

  /*
  // retourne void car le résultat est stocké dans _currentTicket
  Future<void> loadTicketById(int ticketId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _currentTicket = await _service.getTicketById(
        ticketId,
      ); // "demande un ticket spécifique par son id à l'API et le stocke dans _currentTicket"
      _error = '';
      print("Ticket chargé par ID: $ticketId");
    } catch (e) {
      _error = 'Erreur chargement ticket: ${e.toString()}';
      print("Erreur loadTicketById: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTicketsByStatus(TicketStatus ticketStatus) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      _tickets = await _service.getTicketsByStatus(ticketStatus);
      _error = '';
      print(
        "Tickets chargés par statut $ticketStatus: ${_tickets.length} tickets",
      );
    } catch (e) {
      _error = 'Erreur chargement tickets par statut: ${e.toString()}';
      print("Erreur loadTicketsByStatus: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FILTRAGE DES TICKETS PAR STATUT
  List<Ticket> filterTicketsByStatus(TicketStatus status) {
    return _service.filterTicketsByStatus(status);
  }

   // 💰 CALCUL DU REVENU TOTAL
  double getTotalRevenue() {
    return _tickets.fold(0.0, (sum, ticket) => sum + ticket.ticketPrice);
  }
  // OBTENTION DE LA COULEUR D'UN STATUT
  Color getStatusColor(TicketStatus status) {
    return status.displayColor;
  }
  // OBTENTION DE LA COULEUR D'UN TYPE
  Color getTypeColor(TicketType type) {
    return type.displayColor;
  }
  // OBTENTION DU LIBELLÉ FRANÇAIS D'UN STATUT
  String getStatusDisplayName(TicketStatus status) {
    return status.frenchLabel; // "Disponible", "Réservé", "Utilisé"
  }
*/