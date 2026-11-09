// Définit ts ls statuts possibles qu'1 ticket peut avoir ds l'appli
enum TicketStatus {
  booked,  // TICKET ACHETÉ : a été acheté
  used;    // TICKET UTILISÉ : a été utilisé (débité) par un portier
}

/*
🎯 EXTENSION POUR L'ENUM TICKETSTATUS
Cette extension ajoute des fonctionnalités supplémentaires à l'enum TicketStatus
pour faciliter la conversion entre les conventions Flutter et Spring Boot
*/
extension TicketStatusExtension on TicketStatus {
  /* FORMAT POUR L'API SPRING BOOT : toBackend
   * Convertit l'enum au format attendu par l'API backend
   * @return String : Le statut en MAJUSCULES selon la convention Java
   * Exemple :
   * - TicketStatus.booked → "BOOKED"
   */
  String get forApi {
    switch (this) {
      case TicketStatus.booked:
        return 'BOOKED';
      case TicketStatus.used:
        return 'USED';
    }
  }

  /* CONVERSION DEPUIS L'API SPRING BOOT: fromBackend
   * Convertit une valeur String de l'API en enum Dart
   * @param apiValue : La valeur reçue de l'API Spring Boot
   * @return TicketStatus : L'enum Dart correspondant
   * @throws ArgumentError : Si la valeur de l'API n'est pas reconnue
   * Exemple :
   * - "BOOKED" → TicketStatus.booked
   * equivalent de getCampaignStatus dans SharedService.ts qu'on a appelé dans le front de Angular
   */
  static TicketStatus fromApi(String backendStatus) {
    switch (backendStatus.toUpperCase()) {
      case 'BOOKED':
        return TicketStatus.booked;
      case 'USED':
        return TicketStatus.used;
      default:
        throw ArgumentError('TicketStatus inconnu: $backendStatus');
    }
  }
}
