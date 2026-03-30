import 'package:senticket_front/enums/transaction_type.dart';

/// DTO pour une transaction individuelle
class TransactionHistoryDTO {
  final int id;
  final TransactionType transactionType;
  final DateTime date;
  final int ticketsCount;
  final List<int> ticketIds;
  final List<String> ticketTypes;

  // Champs spécifiques aux achats
  final UserDTO? purchaserDTO;

  // Champs spécifiques aux débits
  final UserDTO? porterDTO;
  final UserDTO? studentDTO;

  // Champs spécifiques aux transferts
  final UserDTO? senderDTO;
  final UserDTO? recipientDTO;
  final bool? transferCanceled;

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

  /// Convertit un JSON en objet TransactionHistoryDTO
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

  /// Retourne le libellé de la transaction selon son type
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
class TransactionHistoryResponseDTO {
  final List<TransactionHistoryDTO> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool first;
  final bool last;
  final bool hasNext;
  final bool hasPrevious;

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

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }

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
