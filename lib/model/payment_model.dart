// MODÈLES DE DONNÉES PAIEMENT PAYDUNYA
import 'package:senticket_front/enums/payment_status.dart';

// REQUÊTE D'INITIATION DE PAIEMENT
//
// Envoyée par Flutter → Backend : POST /api/payments/initiate
// Correspond exactement à PaymentInitiationDTO.java
//
// Champs :
//   userId           : ID de l'étudiant connecté
//   selectedTicketIds: IDs des tickets sélectionnés dans l'UI
//   totalAmount      : Montant à papyer calculé côté Flutter (countA×100 + countB×150)
//   countA           : Nombre de tickets Type A à régénérer
//   countB           : Nombre de tickets Type B à régénérer
class PaymentInitiationDTO {
  final int userId;
  final List<int> selectedTicketIds;
  final double totalAmount;
  final int countA;
  final int countB;

  PaymentInitiationDTO({
    required this.userId,
    required this.selectedTicketIds,
    required this.totalAmount,
    required this.countA,
    required this.countB,
  });

  // Sérialise(convertit) l'objet en Map JSON pour l'envoi HTTP POST
  // Les noms de clés correspondent exactement aux champs de PaymentInitiationDTO.java
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'selectedTicketIds': selectedTicketIds,
    'totalAmount': totalAmount,
    'countA': countA,
    'countB': countB,
  };

  @override
  String toString() =>
      'PaymentInitiationRequest('
      'userId: $userId, '
      'tickets: $selectedTicketIds, '
      'total: $totalAmount FCFA, '
      'countA: $countA, countB: $countB)';
}

/// RÉPONSE D'INITIATION DE PAIEMENT
//
// Reçue depuis le Backend : réponse de POST /api/payments/initiate
// Correspond exactement à PaymentResponseDTO.java
//
// Champs :
//   paymentUrl    : URL de la page de paiement PayDunya → à charger dans le WebView
//   transactionId : Token unique PayDunya (ex: "test_H5vmmOaMa1")
//                   → utilisé pour le polling de statut
//   status        : Toujours PENDING au moment de l'initiation
//   message       : Message informatif du backend (ex: "Redirection vers...")
class PaymentResponseDTO {
  final String paymentUrl;
  final String transactionId;
  final PaymentStatus status;
  final String message;

  PaymentResponseDTO({
    required this.paymentUrl,
    required this.transactionId,
    required this.status,
    required this.message,
  });

  // Désérialise la réponse JSON du backend en objet Dart
  // Utilisé dans PaymentApiService.initiatePayment()
  factory PaymentResponseDTO.fromJson(Map<String, dynamic> json) {
    return PaymentResponseDTO(
      paymentUrl: json['paymentUrl'] as String? ?? '',
      transactionId: json['transactionId'] as String? ?? '',
      status: paymentStatusFromString(json['status'] as String?),
      message: json['message'] as String? ?? '',
    );
  }

  @override
  String toString() =>
      'PaymentResponse('
      'transactionId: $transactionId, '
      'status: $status, '
      'url: $paymentUrl)';
}

///////////////////////////////////////////////////////////////////////

// RÉSULTAT DU POLLING DE STATUT
//
// Reçu depuis le Backend : GET /api/payments/status/{token}
// Le backend retourne une simple String (ex: "COMPLETED", "PENDING")
// Cette classe encapsule le parsing et fournit des propriétés utiles.
class PaymentStatusResult {
  final String transactionId; // Token PayDunya de la transaction
  final PaymentStatus status; // Statut parsé depuis la String du backend

  const PaymentStatusResult({
    required this.transactionId,
    required this.status,
  });

  // Crée un résultat depuis la String simple retournée par le backend
  // Le backend retourne juste "COMPLETED", pas un objet JSON complexe
  factory PaymentStatusResult.fromString(
    String transactionId,
    String statusStr,
  ) {
    return PaymentStatusResult(
      transactionId: transactionId,
      status: paymentStatusFromString(statusStr),
    );
  }

  // Indique si le paiement est dans un état terminal
  // (plus besoin de continuer le polling)
  bool get isTerminal =>
      status == PaymentStatus.completed ||
      status == PaymentStatus.failed ||
      status == PaymentStatus.cancelled;

  // Raccourci pour vérifier le succès
  bool get isCompleted => status == PaymentStatus.completed;

  // Raccourci pour vérifier l'annulation
  bool get isCancelled => status == PaymentStatus.cancelled;

  @override
  String toString() =>
      'PaymentStatusResult(transactionId: $transactionId, status: $status)';
}
