/// Énumération des types de transactions
// Définit tous les types possibles qu'une transaction peut avoir dans l'application
enum TransactionType {
  purchase, // Achat de tickets
  debit, // Débit de compte
  transfer; // Transfert de tickets

  /// Convertit l'énumération en chaîne pour l'API "toBackend"
  String toApi() {
    switch (this) {
      case TransactionType.purchase:
        return 'PURCHASE';
      case TransactionType.debit:
        return 'DEBIT';
      case TransactionType.transfer:
        return 'TRANSFER';
    }
  }

  /// Crée une énumération à partir d'une chaîne API "fromBackend"
  static TransactionType fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'PURCHASE':
        return TransactionType.purchase;
      case 'DEBIT':
        return TransactionType.debit;
      case 'TRANSFER':
        return TransactionType.transfer;
      default:
        return TransactionType.purchase;
    }
  }

  /// Retourne le libellé affichable
  String getDisplayName() {
    switch (this) {
      case TransactionType.purchase:
        return 'Achat de tickets';
      case TransactionType.debit:
        return 'Débit de compte';
      case TransactionType.transfer:
        return 'Transfert de tickets';
    }
  }
}
