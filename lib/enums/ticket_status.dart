import 'package:flutter/material.dart';

// 🎫 ENUMERATION DES STATUTS DE TICKETS
// Définit tous les statuts possibles qu'un ticket peut avoir dans l'application
enum TicketStatus {
  // TICKET DISPONIBLE : Peut être acheté ou réservé
  available,
  // TICKET RÉSERVÉ : A été réservé mais pas encore payé/utilisé
  booked,
  // TICKET UTILISÉ : A été utilisé (débité) par un portier
  used,
}

/*
🎯 EXTENSION POUR L'ENUM TICKETSTATUS
Cette extension ajoute des fonctionnalités supplémentaires à l'enum TicketStatus
pour faciliter la conversion entre les conventions Flutter et Spring Boot
*/
extension TicketStatusExtension on TicketStatus {
  /* Convertit l'enum en String pour l'affichage dans l'UI
   * @return String : Le nom de l'enum sans le préfixe "TicketStatus."
   * Exemple :
   * - TicketStatus.available → "available"
   */
  String get displayName =>
      // Convertit l'enum en String et extrait la partie après le "."
      // TicketStatus.available.toString() → "TicketStatus.available"
      // .split('.') → ["TicketStatus", "available"]
      // .last → "available"
      toString().split('.').last;

  /* FORMAT POUR L'API SPRING BOOT : toBackend
   * Convertit l'enum au format attendu par l'API backend
   * @return String : Le statut en MAJUSCULES selon la convention Java
   * Exemple :
   * - TicketStatus.booked → "BOOKED"
   */
  String get forApi {
    switch (this) {
      case TicketStatus.available:
        return 'AVAILABLE';
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
      case 'AVAILABLE':
        return TicketStatus.available;
      case 'BOOKED':
        return TicketStatus.booked;
      case 'USED':
        return TicketStatus.used;
      default:
        throw ArgumentError('TicketStatus inconnu: $backendStatus');
    }
  }

  // For UI translation if necessary / displayLabel
  /* Retourne un libellé formaté pour l'affichage à l'utilisateur
   * @return String : Version lisible et formatée du statut
   * Exemple :
   * - TicketStatus.booked → "Réservé"
   */
  String get frenchLabel {
    switch (this) {
      case TicketStatus.available:
        return 'Disponible';
      case TicketStatus.booked:
        return 'Réservé';
      case TicketStatus.used:
        return 'Utilisé';
    }
  }

  /* Retourne une couleur qui représente visuellement le statut
   * @return Color : La couleur associée au statut pour l'UI
   * equivalent de getCampaignStatucColor dans SharedService.ts qu'on a appelé dans le front de Angular
   */
  Color get displayColor {
    switch (this) {
      case TicketStatus.available:
        return Colors.orange;
      case TicketStatus.booked:
        return Colors.green;
      case TicketStatus.used:
        return const Color.fromARGB(255, 142, 24, 16);
    }
  }
}
