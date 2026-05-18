// ENUM : STATUTS DE PAIEMENT
// Correspond à l'enum PaymentStatus.java du backend Spring Boot
// Valeurs retournées par l'API : "PENDING", "COMPLETED", "FAILED", etc.
enum PaymentStatus {
  pending, // Paiement initié, en attente de confirmation de l'utilisateur
  completed, // Paiement confirmé par PayDunya, tickets attribués avec succès
  failed, // Échec technique du paiement
  cancelled, // Annulé par l'utilisateur sur la page PayDunya
  unknown, // Statut non reconnu (erreur réseau ou URL incorrecte)
}

// Utilitaire : convertit un String (retourné par le backend) en enum PaymentStatus
// Le backend Spring Boot retourne "COMPLETED", "PENDING", etc. en majuscules
PaymentStatus paymentStatusFromString(String? status) {
  switch (status?.trim().toUpperCase()) {
    case 'COMPLETED':
      return PaymentStatus.completed;
    case 'FAILED':
      return PaymentStatus.failed;
    case 'CANCELLED':
      return PaymentStatus.cancelled;
    case 'PENDING':
      return PaymentStatus.pending;
    default:
      // Cas inconnu : erreur réseau, HTML retourné à la place de JSON, etc.
      return PaymentStatus.unknown;
  }
}

// Utilitaire inverse : convertit l'enum en String pour affichage ou debug
String paymentStatusToString(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.completed:
      return 'COMPLETED';
    case PaymentStatus.failed:
      return 'FAILED';
    case PaymentStatus.cancelled:
      return 'CANCELLED';
    case PaymentStatus.pending:
      return 'PENDING';
    case PaymentStatus.unknown:
      return 'UNKNOWN';
  }
}
