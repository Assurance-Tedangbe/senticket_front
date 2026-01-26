import 'package:senticket_front/enums/ticket_status.dart';
import 'package:senticket_front/enums/ticket_type.dart';

/*  ticket_model.dart: role(Conversion données), utilise forApi, fromApi, toBackend, fromBackend  */

class Ticket {
  final int? ticketId;
  final TicketType ticketType;
  final double ticketPrice;
  final String paymentCode;
  final bool booked;
  final TicketStatus ticketStatus;
  final DateTime ticketCreationDate;
  final DateTime? ticketPurchaseDate;
  final String ticketDescription;
  final PurchaseUserDTO purchaseUserDTO;
  final bool isSelected;

  // Constructeur principal
  Ticket({
    this.ticketId,
    required this.ticketType,
    required this.ticketPrice,
    required this.paymentCode,
    required this.booked,
    required this.ticketStatus,
    required this.ticketCreationDate,
    this.ticketPurchaseDate,
    required this.ticketDescription,
    required this.purchaseUserDTO,
    this.isSelected = false,
  });

  /// Factory constructor pour créer un Ticket à partir d'un JSON
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticketId'],
      ticketPrice: (json['ticketPrice'] as num?)?.toDouble() ?? 0.0,
      paymentCode: json['paymentCode'] ?? '',
      booked: json['booked'] ?? false,
      ticketType: TicketTypeExtension.fromBackend(json['ticketType']), // ← ICI
      ticketStatus: TicketStatusExtension.fromApi(
        json['ticketStatus'],
      ), // ← ICI
      ticketCreationDate: DateTime.parse(json['ticketCreationDate']),
      ticketPurchaseDate: json['ticketPurchaseDate'] != null
          ? DateTime.parse(json['ticketPurchaseDate'])
          : null,
      ticketDescription: json['ticketDescription'] ?? '',
      purchaseUserDTO: PurchaseUserDTO.fromJson(json['userDTO']),
      isSelected: false, // Par défaut non sélectionné
    );
  }

  /// Convertit l'objet Ticket en Map JSON
  Map<String, dynamic> toJson() {
    return {
      'ticketId': ticketId,
      'ticketType': ticketType.toBackend, // ← ICI: "A", "B"
      'ticketPrice': ticketPrice,
      'paymentCode': paymentCode,
      'booked': booked,
      'ticketStatus':
          ticketStatus.forApi, // ← ICI:  "AVAILABLE", "BOOKED", "USED"
      'ticketCreationDate': ticketCreationDate.toIso8601String().split('T')[0],
      'ticketPurchaseDate': ticketPurchaseDate?.toIso8601String().split('T')[0],
      'ticketDescription': ticketDescription,
      'purchaseUserDTO': purchaseUserDTO.toJson(),
      'isSelected': isSelected,
    };
  }

  // Crée une copie de l'objet Ticket avec des valeurs optionnelles modifiées:
  // utilisé ds TicketApiService
  Ticket copyWith({
    int? ticketId,
    TicketType? ticketType,
    double? ticketPrice,
    String? paymentCode,
    bool? booked,
    TicketStatus? ticketStatus,
    DateTime? ticketCreationDate,
    DateTime? ticketPurchaseDate,
    String? ticketDescription,
    PurchaseUserDTO? purchaseUserDTO,
    bool? isSelected,
  }) {
    return Ticket(
      ticketId: ticketId ?? this.ticketId,
      ticketType: ticketType ?? this.ticketType,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      paymentCode: paymentCode ?? this.paymentCode,
      booked: booked ?? this.booked,
      ticketStatus: ticketStatus ?? this.ticketStatus,
      ticketCreationDate: ticketCreationDate ?? this.ticketCreationDate,
      ticketPurchaseDate: ticketPurchaseDate ?? this.ticketPurchaseDate,
      ticketDescription: ticketDescription ?? this.ticketDescription,
      purchaseUserDTO: purchaseUserDTO ?? this.purchaseUserDTO,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class PurchaseUserDTO {
  final int userId; // Ne doit pas être nullable - le backend le requiert
  final String username; // Ne doit pas être nullable - le backend le requiert

  PurchaseUserDTO({required this.userId, required this.username});

  factory PurchaseUserDTO.fromJson(Map<String, dynamic> json) {
    return PurchaseUserDTO(
      userId: json['userId'] as int,
      username: json['username'] as String,
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

  /* String toJsonString() {
    return json.encode(toJson());
  } */
}

class TransferTicketsRequestDTO {
  final int fromStudentId;
  final int toStudentId;
  final List<int> selectedTicketIdsToTransfer;

  TransferTicketsRequestDTO({
    required this.fromStudentId,
    required this.toStudentId,
    required this.selectedTicketIdsToTransfer,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromStudentId': fromStudentId,
      'toStudentId': toStudentId,
      'selectedTicketIdsToTransfer': selectedTicketIdsToTransfer,
    };
  }
}

class CancelTransferTicketsRequestDTO {
  final int originalSenderUserId;
  final int currentOwnerUserId;
  final List<int> ticketIdsToCancel;

  CancelTransferTicketsRequestDTO({
    required this.originalSenderUserId,
    required this.currentOwnerUserId,
    required this.ticketIdsToCancel,
  });

  Map<String, dynamic> toJson() {
    return {
      'originalSenderUserId': originalSenderUserId,
      'currentOwnerUserId': currentOwnerUserId,
      'ticketIdsToCancel': ticketIdsToCancel,
    };
  }
}

class DebitAccountRequestDTO {
  final int portierId;
  final int studentId;
  final List<int> ticketIds;

  DebitAccountRequestDTO({
    required this.portierId,
    required this.studentId,
    required this.ticketIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'portierId': portierId,
      'studentId': studentId,
      'ticketIds': ticketIds,
    };
  }
}

/* class AccountDTO {
  final int? accountId;
  final String accountNumber;

  AccountDTO({this.accountId, required this.accountNumber});

  factory AccountDTO.fromJson(Map<String, dynamic> json) {
    return AccountDTO(
      accountId: json['accountId'],
      accountNumber: json['accountNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'accountId': accountId, 'accountNumber': accountNumber};
  }
} */
