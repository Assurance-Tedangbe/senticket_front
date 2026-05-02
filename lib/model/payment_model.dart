// cette classe définit les structures de données pour l'intégration PayDunya.

/// DTO pour initier un paiement (envoyé au backend)
class PaymentInitiationDTO {
  /// ID de l'utilisateur connecté
  final int userId;

  /// IDs des tickets sélectionnés
  final List<int> selectedTicketIds;

  /// Montant total à payer
  final double totalAmount;

  /// Nombre de tickets Type A à régénérer
  final int countA;

  /// Nombre de tickets Type B à régénérer
  final int countB;

  PaymentInitiationDTO({
    required this.userId,
    required this.selectedTicketIds,
    required this.totalAmount,
    required this.countA,
    required this.countB,
  });

  /// Convertit l'objet en Map pour l'envoi JSON
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'selectedTicketIds': selectedTicketIds,
    'totalAmount': totalAmount,
    'countA': countA,
    'countB': countB,
  };
}

/// Réponse du backend après initiation du paiement
class PaymentResponseDTO {
  /// URL de la page de paiement PayDunya (à ouvrir dans le navigateur)
  final String paymentUrl;

  /// Identifiant unique de la transaction PayDunya
  final String transactionId;

  /// Statut du paiement: "PENDING", "SUCCESS", "FAILED"
  final String status;

  /// Message explicatif
  final String message;

  PaymentResponseDTO({
    required this.paymentUrl,
    required this.transactionId,
    required this.status,
    required this.message,
  });

  /// Crée un objet à partir d'une réponse JSON
  factory PaymentResponseDTO.fromJson(Map<String, dynamic> json) {
    return PaymentResponseDTO(
      paymentUrl: json['paymentUrl'],
      transactionId: json['transactionId'],
      status: json['status'],
      message: json['message'],
    );
  }
}
