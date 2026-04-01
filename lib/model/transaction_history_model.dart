import 'package:senticket_front/enums/transaction_type.dart';

/// MODÈLES DE DONNÉES POUR L'HISTORIQUE DES TRANSACTIONS
/// Ces classes représentent la structure des données reçues du backend
/// pour l'historique des transactions. Elles sont utilisées pour :
/// - Décoder les réponses JSON du backend
/// - Stocker les données dans le provider
/// - Afficher les informations dans l'UI

/// DTO représentant une transaction individuelle
/// Contient toutes les informations nécessaires pour afficher une transaction
/// dans la liste d'historique.
class TransactionHistoryDTO {
  final int id;

  /// Identifiant unique de la transaction
  final TransactionType transactionType;

  /// Type de transaction (ACHAT, DÉBIT, TRANSFERT)
  final DateTime date;

  /// Date et heure de la transaction
  final int ticketsCount;

  /// Liste des IDs des tickets impliqués dans la transaction
  final List<int> ticketIds;

  /// Liste des types des tickets impliqués (A, B, etc.)
  final List<String> ticketTypes;

  // Champs spécifiques aux achats:  l'Utilisateur qui a effectué l'achat
  final UserDTO? purchaserDTO;

  // Champs spécifiques aux débits
  /// Portier qui a effectué le débit
  final UserDTO? porterDTO;

  /// Étudiant dont le compte a été débité
  final UserDTO? studentDTO;

  // Champs spécifiques aux transferts
  /// Expéditeur du transfert
  final UserDTO? senderDTO;

  /// Destinataire du transfert
  final UserDTO? recipientDTO;

  /// Indique si le transfert a été annulé
  final bool? transferCanceled;

  /// Constructeur de la classe
  TransactionHistoryDTO({
    required this.id,
    required this.transactionType,
    required this.date,
    required this.ticketsCount,
    required this.ticketIds,
    required this.ticketTypes,
    this.purchaserDTO,
    this.porterDTO,
    this.studentDTO,
    this.senderDTO,
    this.recipientDTO,
    this.transferCanceled,
  });

  /// Convertit un JSON (reçu du backend) en objet TransactionHistoryDTO
  /// Utilise la méthode fromApi() de TransactionType pour convertir la chaîne
  /// en énumération.
  factory TransactionHistoryDTO.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryDTO(
      id: json['id'],
      transactionType: TransactionType.fromApi(json['transactionType']),
      date: DateTime.parse(json['date']),
      ticketsCount: json['ticketsCount'],
      ticketIds: (json['ticketIds'] as List<dynamic>?)?.cast<int>() ?? [],
      ticketTypes:
          (json['ticketTypes'] as List<dynamic>?)?.cast<String>() ?? [],
      purchaserDTO: json['purchaserDTO'] != null
          ? UserDTO.fromJson(json['purchaserDTO'])
          : null,
      porterDTO: json['porterDTO'] != null
          ? UserDTO.fromJson(json['porterDTO'])
          : null,
      studentDTO: json['studentDTO'] != null
          ? UserDTO.fromJson(json['studentDTO'])
          : null,
      senderDTO: json['senderDTO'] != null
          ? UserDTO.fromJson(json['senderDTO'])
          : null,
      recipientDTO: json['recipientDTO'] != null
          ? UserDTO.fromJson(json['recipientDTO'])
          : null,
      transferCanceled: json['transferCanceled'],
    );
  }

  /// Retourne le libellé affichable selon le type de transaction
  /// Utilisé pour afficher le type dans l'interface utilisateur
  String getTransactionLabel() {
    return transactionType.getDisplayName();
  }

  /// Retourne les détails de la transaction selon son type
  String getTransactionDetails() {
    switch (transactionType) {
      case TransactionType.purchase:
        return 'Par ${purchaserDTO?.username ?? 'Inconnu'}';
      case TransactionType.debit:
        return 'Par ${porterDTO?.username ?? 'Inconnu'} sur ${studentDTO?.username ?? 'Inconnu'}';
      case TransactionType.transfer:
        return 'De ${senderDTO?.username ?? 'Inconnu'} à ${recipientDTO?.username ?? 'Inconnu'}'
            '${transferCanceled == true ? ' (Annulé)' : ''}';
    }
  }
}

/// DTO de réponse paginée pour l'historique
/// Contient la liste des transactions ainsi que les métadonnées de pagination
/// pour permettre le chargement infini (scroll) dans l'interface.
class TransactionHistoryResponseDTO {
  /// Liste des transactions pour la page courante
  final List<TransactionHistoryDTO> content;

  /// Nombre total d'éléments disponibles (toutes pages confondues)
  final int totalElements;

  /// Nombre total de pages disponibles
  final int totalPages;

  /// Numéro de la page courante (0-indexé)
  final int currentPage;

  /// Taille de la page (nombre d'éléments par page)
  final int pageSize;

  /// Indique si c'est la première page
  final bool first;

  /// Indique si c'est la dernière page
  final bool last;

  /// Indique s'il y a une page suivante (utilisé pour le scroll infini)
  final bool hasNext;

  /// Indique s'il y a une page précédente
  final bool hasPrevious;

  /// Constructeur de la classe
  TransactionHistoryResponseDTO({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.first,
    required this.last,
    required this.hasNext,
    required this.hasPrevious,
  });

  /// Convertit un JSON en objet TransactionHistoryResponseDTO
  factory TransactionHistoryResponseDTO.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponseDTO(
      content:
          (json['content'] as List<dynamic>?)
              ?.map((e) => TransactionHistoryDTO.fromJson(e))
              .toList() ??
          [],
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      hasNext: json['hasNext'] ?? false,
      hasPrevious: json['hasPrevious'] ?? false,
    );
  }
}

/// DTO représentant un utilisateur
/// Utilisé dans les détails des transactions pour identifier les acteurs.
class UserDTO {
  final int id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;

  UserDTO({
    required this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
  });

  /// Convertit un JSON en objet UserDTO
  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

  /// Convertit l'objet en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
