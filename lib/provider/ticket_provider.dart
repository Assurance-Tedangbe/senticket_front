import 'package:flutter/material.dart';
import 'package:senticket_front/enums/ticket_status.dart';
import 'package:senticket_front/enums/ticket_type.dart';
import 'package:senticket_front/model/ticket_model.dart';
import 'package:senticket_front/provider/user_provider.dart';
import 'package:senticket_front/services/ticket_service.dart';
import 'package:provider/provider.dart';

/*
  Rôle Principal: Gestionnaire d'état centralisé pour les tickets
  Votre TicketProvider sert de cerveau central qui :
   - Stocke l'état de tous les tickets / gère l'état de l'interface utilisateur 
   - Coordonne les opérations CRUD / actions sur les tickets 
   - Gère le loading et les erreurs
   - Notifie l'UI des changements / notifie les changements aux écouteurs

  Gère l'état de toutes les opérations du TicketApiService.
  Il sert d'intermédiaire entre l'interface utilisateur et les services backend

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

  // === INTERNAL STATE FOR ALL OPERATIONS = ETAT PRINCIPAL DE L'APPLICATION ===

  List<Ticket> _tickets = []; // "Liste vide pour stocker tous les tickets"
  // Liste principale qui stocke tous les tickets chargés depuis l'API

  Ticket?
  _currentTicket; // "Ticket actuellement sélectionné (peut être null si aucun ticket n'est sélectionné)"

  bool _isLoading = false; // "Indicateur de chargement (initialement false)"
  // Indicateur global de chargement - true quand une opération asynchrone est en cours

  String _error = ''; // "Stocke les messages d'erreur (initialement vide)"
  // Stocke le dernier message d'erreur rencontré, vide string signifie aucune erreur

  // === ETATS SPECIFIQUES PAR OPERATION ===
  // Ces booléens permettent de savoir précisément quelle opération est en cours

  bool _isCreatingTickets = false; // Création de nouveaux tickets en cours
  // True uniquement pendant la création de nouveaux tickets

  bool _isUpdatingTicket = false; // "Mise à jour en cours"
  bool _isDeletingTicket = false;
  bool _isUpdatingTicketStatus = false;
  bool _isBookingTicket = false;
  bool _isUnbookingTicket = false;
  bool _isPurchasingTickets = false;
  bool _isTransferringTickets = false;
  bool _isCancelingTransfer = false;
  bool _isDebitingAccount = false;

  // CONSTRUCTEUR
  TicketProvider(this._service);
  // Le constructeur reçoit une instance de TicketApiService en paramètre (dependency injection)

  // Les getters permettent un accès en lecture seule aux variables privées

  // GETTERS PRINCIPAUX
  List<Ticket> get tickets =>
      _tickets; // Retourne la liste complète des tickets (en lecture seule)
  // Permet à d'autres classes de lire `_tickets` mais pas de le modifier
  Ticket? get currentTicket =>
      _currentTicket; // Retourne le ticket actuellement sélectionné (peut être null)
  bool get isLoading =>
      _isLoading; // Indique si une opération globale est en cours de chargement
  String get error => _error; // Retourne le dernier message d'erreur rencontré

  // GETTERS POUR LES ETATS SPECIFIQUES
  bool get isCreatingTickets =>
      _isCreatingTickets; // Indique si une création de tickets est en cours
  bool get isUpdatingTicket => _isUpdatingTicket;
  bool get isDeletingTicket => _isDeletingTicket;
  bool get isUpdatingTicketStatus => _isUpdatingTicketStatus;
  bool get isBookingTicket => _isBookingTicket;
  bool get isUnbookingTicket => _isUnbookingTicket;
  bool get isPurchasingTickets => _isPurchasingTickets;
  bool get isTransferringTickets => _isTransferringTickets;
  bool get isCancelingTransfer => _isCancelingTransfer;
  bool get isDebitingAccount => _isDebitingAccount;

  // GETTERS POUR LES TICKETS FILTRÉS
  List<Ticket> get availableTickets => _tickets
      .where((ticket) => ticket.ticketStatus == TicketStatus.available)
      .toList();

  List<Ticket> get ticketsA => availableTickets
      .where((ticket) => ticket.ticketType == TicketType.a)
      .toList();

  List<Ticket> get ticketsB => availableTickets
      .where((ticket) => ticket.ticketType == TicketType.b)
      .toList();

  List<Ticket> get selectedTickets =>
      _tickets.where((ticket) => ticket.isSelected).toList();

  /* CHARGE TOUS LES TICKETS DEPUIS L'API
   * @param forceRefresh : si true, ignore le cache et force le rechargement */
  Future<void> loadAllTickets({bool forceRefresh = false}) async {
    // "charge les tickets, cela va prendre du temps (async)"

    _isLoading = true; // active le chargement
    _error = ''; // efface les erreurs précédentes
    notifyListeners(); // notifie tous les écouteurs (UI) que l'état a changé/du début du chargement
    // Notifie tous les widgets écoutant ce provider

    try {
      // Appel asynchrone au service pour récupérer les tickets
      _tickets = await _service.getAllTickets(
        forceRefresh: forceRefresh,
      ); // "Demande au service de me donner tous les tickets"

      // Si succès : mise à jour de la liste et effacement des erreurs
      _error = ''; // "Confirme qu'il n'y a pas d'erreurs"
      print("Chargement réussi : ${_tickets.length} tickets");
    } catch (e) {
      // En cas d'erreur : stockage du message d'erreur
      _error = e.toString(); // "Stocke l'erreur"
      print("Erreur loadAllTickets: $e");
    } finally {
      // Dans tous les cas : fin du chargement et notification
      _isLoading = false; // "arrête le chargement"
      notifyListeners(); // "notifie l'UI de la fin du chargement"
    }
  }

  // Pour gérer la sélection/désélection
  void toggleTicketSelection(int ticketId) {
    final index = _tickets.indexWhere((t) => t.ticketId == ticketId);
    if (index != -1) {
      _tickets[index] = _tickets[index].copyWith(
        isSelected: !(_tickets[index].isSelected),
      );
      notifyListeners();
    }
  }

  void selectAllTicketsA() {
    for (var ticket in _tickets) {
      if (ticket.ticketType == TicketType.a &&
          ticket.ticketStatus == TicketStatus.available) {
        final index = _tickets.indexWhere((t) => t.ticketId == ticket.ticketId);
        if (index != -1) {
          _tickets[index] = _tickets[index].copyWith(isSelected: true);
        }
      }
    }
    notifyListeners();
  }

  void selectAllTicketsB() {
    for (var ticket in _tickets) {
      if (ticket.ticketType == TicketType.b &&
          ticket.ticketStatus == TicketStatus.available) {
        final index = _tickets.indexWhere((t) => t.ticketId == ticket.ticketId);
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

  Future<bool> purchaseTickets() async {
    // Récupérer UserProvider via BuildContext (on le fera passer depuis le widget)
    // Cette méthode sera modifiée dans le widget pour passer le context

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
      final ticketIds = selected.map((t) => t.ticketId!).toList();

      // Cette méthode sera appelée avec le context pour récupérer l'utilisateur
      throw Exception(
        "Cette méthode doit être appelée depuis le widget avec le context",
      );

      /* final purchaseRequest = PurchaseTicketsRequestDTO(
        purchaseUserDTO: PurchaseUserDTO(username: ''),
        selectedTicketIds: ticketIds,
      );
      final success = await _service.purchaseTickets(purchaseRequest);
      if (success == true) {
        await loadAllTickets(forceRefresh: true);
        _error = '';
        return true;
      } else {
        _error = 'Échec de l\'achat des tickets';
        return false;
      } */
    } catch (e) {
      _error = 'Erreur lors de l\'achat: $e';
      return false;
    } finally {
      _isPurchasingTickets = false;
      notifyListeners();
    }
  }

  // Nouvelle méthode qui accepte le context pour récupérer l'utilisateur
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
    final isStudent = user.role?.name?.toUpperCase() == 'ETUDIANT';

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
      final ticketIds = selected.map((t) => t.ticketId!).toList();

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

  /*
   * 🗑️ SUPPRESSION D'UN TICKET */
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

  /* Cette méthode retourne void car le résultat est stocké dans _currentTicket
   *  🔍 CHARGEMENT D'UN TICKET SPECIFIQUE PAR SON ID
   * @param ticketId : l'identifiant du ticket à charger */
  Future<void> loadTicketById(int ticketId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Chargement du ticket depuis l'API et le stocke comme ticket courant
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

  /* 🛒 ACHAT DE TICKETS
   * @param request : DTO contenant les infos d'achat */
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

  /* 🔄 TRANSFERT DE TICKETS ENTRE UTILISATEURS
   * @param request : DTO contenant les infos de transfert */
  Future<bool> transferTickets(
    TransferTicketsRequestDTO transferTicketsRequestDTO,
  ) async {
    _isTransferringTickets = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.transferTickets(
        transferTicketsRequestDTO,
      ); // "demande à l'API de transférer les tickets"

      _error = '';
      print(
        "Tickets transférés de ${transferTicketsRequestDTO.fromStudentId} vers ${transferTicketsRequestDTO.toStudentId}",
      );
      return true;
    } catch (e) {
      _error = 'Erreur transfert tickets: ${e.toString()}';
      print("Erreur transferTickets: $e");
      return false;
    } finally {
      _isTransferringTickets = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /* ↩️ ANNULATION D'UN TRANSFERT DE TICKETS
   *  @param request : DTO contenant les infos d'annulation */
  Future<bool> cancelTransferTickets(
    CancelTransferTicketsRequestDTO cancelTransferTicketsRequestDTO,
  ) async {
    _isCancelingTransfer = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.cancelTransferTickets(
        cancelTransferTicketsRequestDTO,
      ); // demande à l'API d'annuler le transfert de tickets

      _error = '';
      print(
        "Transfert de tickets annulé entre ${cancelTransferTicketsRequestDTO.currentOwnerUserId} et ${cancelTransferTicketsRequestDTO.originalSenderUserId}",
      );
      return true;
    } catch (e) {
      _error = 'Erreur annulation transfert tickets: ${e.toString()}';
      print("Erreur cancelTransferTickets: $e");
      return false;
    } finally {
      _isCancelingTransfer = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /* 💳 DEBIT D'UN COMPTE UTILISATEUR
   * @param request : DTO contenant les infos de débit */
  Future<bool> debitAccount(
    DebitAccountRequestDTO debitAccountRequestDTO,
  ) async {
    _isDebitingAccount = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.debitAccount(
        debitAccountRequestDTO,
      ); // "demande à l'API de débiter le compte"

      _error = '';
      print("Compte ${debitAccountRequestDTO.studentId} débité");
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

  /*🧹 EFFACEMENT DU MESSAGE D'ERREUR
   * Nettoie l'erreur courante et notifie l'UI
   * - Utile pour permettre à l'utilisateur de réessayer après une erreur */
  void clearError() {
    _error = '';
    notifyListeners();
  }

  /*🧹 EFFACEMENT DU TICKET COURANT
   * Réinitialise la sélection courante et notifie l'UI */
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
}
