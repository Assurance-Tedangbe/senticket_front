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

  Ticket?
  _currentTicket; // "Ticket actuellement sélectionné (peut être null si aucun ticket n'est sélectionné)"

  bool _isLoading = false; // "Indicateur de chargement (initialement false)"
  // Indicateur global de chargement - true quand une opération asynchrone est en cours

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

  // CONSTRUCTEUR
  TicketProvider(this._service);
  // Le constructeur reçoit une instance de TicketApiService en paramètre (dependency injection)

  // State for debit operation
  List<Ticket> _studentTicketsForDebit = [];
  TicketType? _selectedTicketTypeForDebit;
  List<int> _selectedTicketIdsForDebit = [];
  bool _isLoadingStudentTickets = false;

  // State for transferTickets operation
  String? _numberOfTicketsError;
  String?
  _numberOfTicketsIsInvalid; // Stocke les erreurs liées au nombre de tickets à transférer

  // State pour cancelTransfer operation
  TransfertHistoryDTO? _lastTransfer;
  SenderDTO? _lastSenderDTO; // pour annulation
  RecipientDTO? _lastRecipientDTO;
  List<int> _lastTicketIds = [];

  String? _transactionIdError;

  // ******************** GETTERS ********************
  // GETTERS PRINCIPAUX
  List<Ticket> get tickets =>
      _tickets; // Retourne la liste complète des tickets
  // Permet à d'autres classes de lire `_tickets` mais pas de le modifier
  Ticket? get currentTicket =>
      _currentTicket; // Retourne le ticket actuellement sélectionné (peut être null)
  bool get isLoading =>
      _isLoading; // Indique si une opération globale est en cours de chargement
  String get error => _error; // Retourne le dernier message d'erreur rencontré

  // GETTERS POUR LES ETATS SPECIFIQUES
  bool get isPurchasingTickets =>
      _isPurchasingTickets; // Indique si un achat est en cours
  bool get isTransferringTickets => _isTransferringTickets;
  bool get isDebitingAccount => _isDebitingAccount;
  bool get isCancelingTransfer => _isCancelingTransfer;
  /*  
  bool get isCreatingTickets => _isCreatingTickets;
  bool get isUpdatingTicket => _isUpdatingTicket;
  bool get isDeletingTicket => _isDeletingTicket;
  bool get isUpdatingTicketStatus => _isUpdatingTicketStatus;
  bool get isBookingTicket => _isBookingTicket;
  bool get isUnbookingTicket => _isUnbookingTicket; */

  // Getters for debit operation
  List<Ticket> get studentTicketsForDebit => _studentTicketsForDebit;
  TicketType? get selectedTicketTypeForDebit => _selectedTicketTypeForDebit;
  List<int> get selectedTicketIdsForDebit => _selectedTicketIdsForDebit;
  int get selectedTicketsCount => _selectedTicketIdsForDebit.length;
  bool get isLoadingStudentTickets => _isLoadingStudentTickets;

  // Getters for transfer operation
  String? get numberOfTicketsError => _numberOfTicketsError;
  String? get numberOfTicketsIsInvalid => _numberOfTicketsIsInvalid;

  // Getters for cancelTransfer operation
  TransfertHistoryDTO? get lastTransfer => _lastTransfer;
  SenderDTO? get lastSenderDTO => _lastSenderDTO;
  RecipientDTO? get lastRecipientDTO => _lastRecipientDTO;
  List<int> get lastTicketIds => _lastTicketIds;

  String? get transactionIdError => _transactionIdError;

  // GETTERS POUR LES TICKETS FILTRÉS
  List<Ticket> get availableTickets => _tickets
      .where((ticket) => ticket.status == TicketStatus.available)
      .toList();

  List<Ticket> get ticketsA =>
      availableTickets.where((ticket) => ticket.type == TicketType.a).toList();

  List<Ticket> get ticketsB =>
      availableTickets.where((ticket) => ticket.type == TicketType.b).toList();

  List<Ticket> get selectedTickets =>
      _tickets.where((ticket) => ticket.isSelected).toList();

  // Setters for transfer operation
  void setNumberOfTicketsError(String error) {
    _numberOfTicketsError = error;
    notifyListeners();
  }

  void setNumberOfTicketsIsInvalid(String error) {
    _numberOfTicketsIsInvalid = error;
    notifyListeners();
  }

  void setTransactionIdError(String error) {
    _transactionIdError = error;
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
        username: user.username, // username ne doit pas être null
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

  // ******************** FOR CANCEL_TRANSFER OPERATION ************************

  // ↩️ ANNULATION D'UN TRANSFERT DE TICKETS
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
}

  /*
    // Set selected ticket type for debit
  void setSelectedTicketTypeForDebit(TicketType? type) {
    _selectedTicketTypeForDebit = type;
    notifyListeners();
  }

  /*➕ CREATION DE NOUVEAUX TICKETS */
  Future<bool> createNewTickets(
    CreationTicketsRequestDTO creationTicketsRequestDTO,
  ) async {
    _isCreatingTickets = true;
    _isLoading = true;
    notifyListeners(); // "démarre le travail et notifie l'interface"

    try {
      final newTickets = await _service.createTickets(
        creationTicketsRequestDTO,
      ); // "Appel au service de créer ces tickets dans l'API"

      // Ajout des nouveaux tickets à la liste locale
      _tickets.addAll(
        newTickets,
      ); // "Si ça fonctionne, ajoute les nouveaux tickets à ma liste locale"
      _error = ''; // "Efface les erreurs"
      print("Tickets créés avec succès: ${newTickets.length} tickets");
      return true; // "Succès"
    } catch (e) {
      _error = 'Erreur création tickets: ${e.toString()}';
      print("Erreur createNewTickets: $e");
      return false; // "Échec"
    } finally {
      // Nettoyage final
      _isCreatingTickets = false;
      _isLoading = false;
      notifyListeners(); // Notifie la fin de l'opération
    }
  }

  /* ✏️ MISE A JOUR D'UN TICKET EXISTANT */
  Future<bool> updateExistingTicket(Ticket ticket) async {
    _isUpdatingTicket = true;
    _isLoading = true;
    notifyListeners();

    try {
      // Validation des données avant envoi
      _service.validateTicketData(ticket);

      // Appel API pour mettre à jour le ticket
      final updatedTicket = await _service.updateTicket(ticket);

      // Recherche de l'index du ticket dans la liste locale
      final index = _tickets.indexWhere(
        (t) => t.ticketId == ticket.ticketId,
      ); // "cherche la position de ce ticket dans ma liste"

      // Mise à jour dans la liste locale si trouvé
      if (index != -1) {
        _tickets[index] =
            updatedTicket; // "Si j'ai trouvé le ticket (index != -1), je remplace l'ancienne version par la nouvelle"
      }

      _error = '';
      print("Ticket mis à jour avec succès: ${updatedTicket.ticketId}");
      return true;
    } catch (e) {
      _error = 'Erreur mise à jour ticket: ${e.toString()}';
      print("Erreur updateExistingTicket: $e");
      return false;
    } finally {
      _isUpdatingTicket = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🗑️ SUPPRESSION D'UN TICKET
  Future<bool> deleteExistingTicket(int ticketId) async {
    _isDeletingTicket = true;
    _isLoading = true;
    notifyListeners();

    try {
      // Appel API pour supprimer le ticket
      await _service.deleteTicket(
        ticketId,
      ); // "demande à l'API de supprimer le ticket avec cet ID"

      // "supprime le ticket de la liste locale"
      _tickets.removeWhere((ticket) => ticket.ticketId == ticketId);

      _error = '';
      print("Ticket avec cet ID supprimé: $ticketId");
      return true;
    } catch (e) {
      _error = 'Erreur suppression: ${e.toString()}';
      print("Erreur deleteExistingTicket: $e");
      return false;
    } finally {
      _isDeletingTicket = false;
      _isLoading = false;
      notifyListeners();
    }
  }

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


  void clearCurrentTicket() {
    _currentTicket = null;
    notifyListeners();
  }

  // 🔄 FORCE LE RAFRAICHISSEMENT DES DONNEES depuis l'API
  Future<void> refreshData() async {
    await loadAllTickets(forceRefresh: true);
  }

  // 📊 OBTENTION DES STATISTIQUES DES TICKETS
  Map<String, int> getTicketStatistics() {
    return _service.getTicketStatistics(_tickets);
  }

  // OBTENTION DES STATISTIQUES FORMATÉES POUR L'UI
  Map<String, int> getFrenchStatistics() {
    final stats = getTicketStatistics();
    return {
      'Total': stats['total'] ?? 0,
      'Réservés': stats['booked'] ?? 0,
      'Disponibles': stats['available'] ?? 0,
      'Utilisés': stats['used'] ?? 0,
      'Type A': stats['A'] ?? 0,
      'Type B': stats['B'] ?? 0,
    };
    /*
      Exple de résultat attendu:
      {
        'Total': 150,
        'Réservés': 80,
        'Disponibles': 70,
        'Utilisés': 45,
        'Type A': 90,
        'Type B': 60
      }
    */
  }

  /*
   * 🔄 MISE A JOUR DU STATUT D'UN TICKET
   * @param ticketStatus : le nouveau statut à appliquer
   *  Le provider utilise les enums DIRECTEMENT
   */
  Future<bool> updateTicketStatus(
    int ticketId,
    TicketStatus ticketStatus,
  ) async {
    _isUpdatingTicketStatus = true;
    _isLoading = true;
    notifyListeners();

    try {
      // Appel API pour changer le statut
      // Il passe l'enum Dart au service, qui se charge de la conversion
      await _service.updateTicketStatus(
        ticketId,
        ticketStatus,
      ); // "demande à l'API de mettre à jour le statut du ticket"

      _error = '';
      print("Statut du ticket $ticketId mis à jour: $ticketStatus");
      return true;
    } catch (e) {
      _error = 'Erreur mise à jour statut ticket: ${e.toString()}';
      print("Erreur updateTicketStatus: $e");
      return false;
    } finally {
      _isUpdatingTicketStatus = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /*
   * 📅 RESERVATION D'UN TICKET
   * @param ticketId : l'identifiant du ticket à réserver
   * @return Future<bool> : true si succès, false si échec
   */
  Future<bool> bookTicket(int ticketId) async {
    _isBookingTicket = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.bookTicket(
        ticketId,
      ); // "demande à l'API de réserver le ticket"

      _error = '';
      print("Ticket $ticketId réservé");
      return true;
    } catch (e) {
      _error = 'Erreur réservation ticket: ${e.toString()}';
      print("Erreur bookTicket: $e");
      return false;
    } finally {
      _isBookingTicket = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /*
   * ANNULATION DE RESERVATION D'UN TICKET
   * @param ticketId : l'identifiant du ticket à désactiver
   * @return Future<bool> : true si succès, false si échec
   */
  Future<bool> unbookTicket(int ticketId) async {
    _isUnbookingTicket = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.unbookTicket(
        ticketId,
      ); // "demande à l'API d'annuler la réservation du ticket"

      _error = '';
      print("Réservation du ticket $ticketId annulée");
      return true;
    } catch (e) {
      _error = 'Erreur annulation réservation ticket: ${e.toString()}';
      print("Erreur unbookTicket: $e");
      return false;
    } finally {
      _isUnbookingTicket = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // === MÉTHODES DE RECHERCHE ET FILTRAGE ===
  /* CHARGEMENT DES TICKETS PAR STATUT
   * @param ticketStatus : le statut des tickets à charger
   */
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

  /*
   * 👥 CHARGEMENT DES TICKETS PAR UTILISATEUR
   * @param userId : l'identifiant de l'utilisateur
   */
  Future<void> loadTicketsByUserId(int userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _tickets = await _service.getTicketsByUserId(userId);
      _error = '';
      print(
        "Tickets chargés par utilisateur $userId: ${_tickets.length} tickets",
      );
    } catch (e) {
      _error = 'Erreur chargement tickets par utilisateur: ${e.toString()}';
      print("Erreur loadTicketsByUserId: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //🔍 RECHERCHE DE TICKETS DANS LE CACHE LOCAL
  List<Ticket> searchTickets(String query) {
    return _service.searchTickets(query);
  }

  // FILTRAGE DES TICKETS PAR STATUT
  List<Ticket> filterTicketsByStatus(TicketStatus status) {
    return _service.filterTicketsByStatus(status);
  }

  // FILTRAGE DES TICKETS PAR TYPE
  List<Ticket> filterTicketsByType(TicketType type) {
    return _service.filterTicketsByType(type);
  }

  // Filtre les tickets réservés/non réservés
  List<Ticket> filterTicketsByBookedStatus(bool booked) {
    return _service.filterTicketsByBookedStatus(booked);
  }

  /*
   * 💰 TRI DES TICKETS PAR PRIX
   * @param ascending : true pour croissant, false pour décroissant
   */
  List<Ticket> sortTicketsByPrice(bool ascending) {
    return _service.sortTicketsByPrice(ascending);
  }

  /*
   * 📅 TRI DES TICKETS PAR DATE DE CREATION
   * @param ascending : true pour plus récents d'abord, false pour plus anciens
   */
  List<Ticket> sortTicketsByCreationDate(bool ascending) {
    return _service.sortTicketsByCreationDate(ascending);
  }

  /*
   * OBTENTION DE TOUS LES STATUTS de tickets UNIQUES
   * @return List<TicketStatus> : liste des statuts existants
   */
  List<TicketStatus> getUniqueTicketStatuses() {
    final statuses = _tickets
        .map((ticket) => ticket.ticketStatus)
        .toSet()
        .toList();
    statuses.sort();
    return statuses;
  }

  // "Obtient tous les types de tickets uniques"
  /* OBTENTION DE TOUS LES TYPES UNIQUES (POUR FILTRES UI)
   * @return List<String> : liste des types de tickets existants
   */
  List<TicketType> getUniqueTicketTypes() {
    final types = _tickets.map((ticket) => ticket.ticketType).toSet().toList();
    types.sort();
    return types;
  }

  /*
   * 💰 CALCUL DU REVENU TOTAL
   * @return double : somme des prix de tous les tickets
   */
  double getTotalRevenue() {
    return _tickets.fold(0.0, (sum, ticket) => sum + ticket.ticketPrice);
  }

  // VERIFICATION DE DISPONIBILITE D'UN TICKET POUR ACHAT
  bool isTicketAvailableForPurchase(Ticket ticket) {
    // CORRECTION : Utiliser l'enum directement au lieu de String
    return !ticket.booked && ticket.ticketStatus == TicketStatus.available;
    // return !ticket.booked && ticket.ticketStatus == 'AVAILABLE';
  }

  // 🛒 OBTENTION DES TICKETS DISPONIBLES POUR ACHAT
  List<Ticket> getAvailableTicketsForPurchase() {
    return _tickets.where(isTicketAvailableForPurchase).toList();
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

  // OBTENTION DU NOM D'AFFICHAGE D'UN TYPE
  String getTypeDisplayName(TicketType type) {
    return type.displayName; // "a", "b"
  }
  */

  /*  Future<bool> purchaseTickets(
    PurchaseTicketsRequestDTO purchaseTicketsRequestDTO,
  ) async {
    _isPurchasingTickets = true;
    _isLoading = true;
    notifyListeners();

    try {
      final purchasedTickets = await _service.purchaseTickets(
        purchaseTicketsRequestDTO,
      ); // "demande à l'API d'acheter les tickets"

      _tickets.addAll(
        purchasedTickets,
      ); // "Ajoute les tickets achetés à la liste locale"
      _error = '';
      print("Tickets achetés avec succès: ${purchasedTickets.length} tickets");
      return true;
    } catch (e) {
      _error = 'Erreur achat tickets: ${e.toString()}';
      print("Erreur purchaseTickets: $e");
      return false;
    } finally {
      _isPurchasingTickets = false;
      _isLoading = false;
      notifyListeners();
    }
  } */

  /*
   * 👤 CHARGEMENT DES TICKETS PAR COMPTE
   * @param accountId : l'identifiant du compte
   */
  /* Future<void> loadTicketsByAccountId(int accountId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _tickets = await _service.getTicketsByAccountId(accountId);
      _error = '';
      print(
          "Tickets chargés par compte $accountId: ${_tickets.length} tickets");
    } catch (e) {
      _error = 'Erreur chargement tickets par compte: ${e.toString()}';
      print("Erreur loadTicketsByAccountId: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  } */