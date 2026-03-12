import 'package:senticket_front/enums/ticket_status.dart';
import 'package:senticket_front/enums/ticket_type.dart';

/* role(Conversion données), utilise forApi, fromApi, toBackend, fromBackend  */
class Ticket {
  final int? id;
  final TicketType type;
  final double price;
  final bool booked;
  final TicketStatus status;
  final DateTime creationDate;
  final PurchaseUserDTO purchaseUserDTO;
  final bool isSelected;

  Ticket({
    this.id,
    required this.type,
    required this.price,
    required this.booked,
    required this.status,
    required this.creationDate,
    required this.purchaseUserDTO,
    this.isSelected = false,
  });

  /// Factory constructor pour créer un Ticket à partir d'un JSON
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      booked: json['booked'] ?? false,
      type: TicketTypeExtension.fromBackend(json['type']),
      status: TicketStatusExtension.fromApi(json['status']),
      creationDate: DateTime.parse(json['creationDate']),
      purchaseUserDTO: PurchaseUserDTO.fromJson(json['userDTO']),
      isSelected: false,
    );
  }

  /// Convertit l'objet Ticket en Map JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toBackend, // "A", "B"
      'price': price,
      'booked': booked,
      'status': status.forApi, // "AVAILABLE", "BOOKED", "USED"
      'creationDate': creationDate.toIso8601String().split('T')[0],
      'purchaseUserDTO': purchaseUserDTO.toJson(),
      'isSelected': isSelected,
    };
  }

  // Crée une copie de l'objet Ticket avec des valeurs optionnelles modifiées:
  // utilisé ds TicketApiService
  Ticket copyWith({
    int? id,
    TicketType? type,
    double? price,
    bool? booked,
    TicketStatus? status,
    DateTime? creationDate,
    PurchaseUserDTO? purchaseUserDTO,
    bool? isSelected,
  }) {
    return Ticket(
      id: id ?? this.id,
      type: type ?? this.type,
      price: price ?? this.price,
      booked: booked ?? this.booked,
      status: status ?? this.status,
      creationDate: creationDate ?? this.creationDate,
      purchaseUserDTO: purchaseUserDTO ?? this.purchaseUserDTO,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class PurchaseUserDTO {
  final int? userId;
  final String username;

  PurchaseUserDTO({required this.userId, required this.username});

  factory PurchaseUserDTO.fromJson(Map<String, dynamic> json) {
    return PurchaseUserDTO(
      userId: json['userId'],
      username: json['username']
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'username': username};
  }
}

// Modèles pour les requêtes complexes
class CreationTicketsRequestDTO {
  final List<Ticket> tickets;
  //the total number of A tickets to create
  final int countA;
  final int countB;

  CreationTicketsRequestDTO(
    this.tickets, {
    required this.countA,
    required this.countB,
  });

  Map<String, dynamic> toJson() {
    return {
      'tickets': tickets.map((ticket) => ticket.toJson()).toList(),
      'countA': countA,
      'countB': countB,
    };
  }
}

class PurchaseTicketsRequestDTO {
  final PurchaseUserDTO purchaseUserDTO;
  final List<int> selectedTicketIds;

  PurchaseTicketsRequestDTO({
    required this.purchaseUserDTO,
    required this.selectedTicketIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'purchaseUserDTO': purchaseUserDTO.toJson(),
      'selectedTicketIds': selectedTicketIds,
    };
  }
}

class DebitAccountRequestDTO {
  final DebitPorterDTO debitPorterDTO;
  final DebitStudentDTO debitStudentDTO;
  final List<int> ticketIds;

  DebitAccountRequestDTO({
    required this.debitPorterDTO,
    required this.debitStudentDTO,
    required this.ticketIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'debitPorterDTO': debitPorterDTO.toJson(),
      'debitStudentDTO': debitStudentDTO.toJson(),
      'ticketIds': ticketIds,
    };
  }
}

class DebitPorterDTO {
  final int porterId;
  final String porterUsername;

  DebitPorterDTO({required this.porterId, required this.porterUsername});

  factory DebitPorterDTO.fromJson(Map<String, dynamic> json) {
    return DebitPorterDTO(
      porterId: json['porterId'],
      porterUsername: json['porterUsername']
    );
  }

  Map<String, dynamic> toJson() {
    return {'porterId': porterId, 'porterUsername': porterUsername};
  }
}

class DebitStudentDTO {
  final int debitStudentId;
  final String username;

  DebitStudentDTO({required this.debitStudentId, required this.username});

  factory DebitStudentDTO.fromJson(Map<String, dynamic> json) {
    return DebitStudentDTO(
      debitStudentId: json['debitStudentId'],
      username: json['username']
    );
  }

  Map<String, dynamic> toJson() {
    return {'debitStudentId': debitStudentId, 'username': username};
  }
}

class TransfertTicketRequestDTO {
  final SenderDTO senderDTO;
  final RecipientDTO recipentDTO;
  final TicketType ticketType;
  final int numberOfTicketsToTransfer;

  TransfertTicketRequestDTO({
    required this.senderDTO,
    required this.recipentDTO,
    required this.ticketType,
    required this.numberOfTicketsToTransfer,
  });

  Map<String, dynamic> toJson() {
    return {
      'senderDTO': senderDTO.toJson(),
      'recipientDTO': recipentDTO.toJson(),
      'ticketType': ticketType.toBackend, // "A" ou "B"
      'numberOfTicketsToTransfer': numberOfTicketsToTransfer,
    };
  }
}

class SenderDTO {
  final int senderId;
  final String senderUsername;
  final String senderPassword;

  SenderDTO({
    required this.senderId,
    required this.senderUsername,
    required this.senderPassword,
  });
  factory SenderDTO.fromJson(Map<String, dynamic> json) {
    return SenderDTO(
      senderId: json['senderId'],
      senderUsername: json['senderUsername'],
      senderPassword: json['senderPassword']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderUsername': senderUsername,
      'senderPassword': senderPassword,
    };
  }
}

class RecipientDTO {
  final int recipientId;
  final String recipientUsername;

  RecipientDTO({required this.recipientId, required this.recipientUsername});

  factory RecipientDTO.fromJson(Map<String, dynamic> json) {
    return RecipientDTO(
      recipientId: json['recipientId'],
      recipientUsername: json['recipientUsername']
    );
  }

  Map<String, dynamic> toJson() {
    return {'recipientId': recipientId, 'recipientUsername': recipientUsername};
  }
}

class CancelTransferTicketsRequestDTO {
  final CancelTransferDTO cancelTransferDTO;
  final List<int> ticketIdsToCancel;

  CancelTransferTicketsRequestDTO({
    required this.cancelTransferDTO,
    required this.ticketIdsToCancel,
  });

  Map<String, dynamic> toJson() {
    return {
      'cancelTransferDTO': cancelTransferDTO.toJson(),
      'ticketIdsToCancel': ticketIdsToCancel,
    };
  }
}

class CancelTransferDTO {
  final int transactionId;
  final OriginalSenderDTO originalSenderDTO;
  final RecipientDTO currentOwnerDTO;

  CancelTransferDTO({
    required this.transactionId,
    required this.originalSenderDTO,
    required this.currentOwnerDTO,
  });

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'originalSenderDTO': originalSenderDTO.toJson(),
      'currentOwnerDTO': currentOwnerDTO.toJson(),
    };
  }
}

class OriginalSenderDTO {
  final int senderId;
  final String senderUsername;

  OriginalSenderDTO({required this.senderId, required this.senderUsername});

  factory OriginalSenderDTO.fromJson(Map<String, dynamic> json) {
    return OriginalSenderDTO(
      senderId: json['senderId'],
      senderUsername: json['senderUsername']
    );
  }

  Map<String, dynamic> toJson() {
    return {'senderId': senderId, 'senderUsername': senderUsername};
  }
}

class TransfertHistoryDTO {
  final int id;
  final String ticketIdsTransfered;
  final UserDTO senderDTO;
  final UserDTO recipientDTO;
  final DateTime transferDate;
  final bool canceled;

  TransfertHistoryDTO({
    required this.id,
    required this.ticketIdsTransfered,
    required this.senderDTO,
    required this.recipientDTO,
    required this.transferDate,
    required this.canceled,
  });

  factory TransfertHistoryDTO.fromJson(Map<String, dynamic> json) {
    return TransfertHistoryDTO(
      id: json['id'],
      ticketIdsTransfered: json['ticketIdsTransfered'],
      senderDTO: UserDTO.fromJson(json['senderDTO']),
      recipientDTO: UserDTO.fromJson(json['recipientDTO']),
      transferDate: DateTime.parse(json['transferDate']),
      canceled: json['canceled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketIdsTransfered': ticketIdsTransfered,
      'senderDTO': senderDTO.toJson(),
      'recipientDTO': recipientDTO.toJson(),
      'transferDate': transferDate.toIso8601String(),
      'canceled': canceled,
    };
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
      lastName: json['lastName']
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
