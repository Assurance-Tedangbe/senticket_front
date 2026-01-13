import 'package:flutter/material.dart';

// 🎫 ENUMERATION DES TYPES DE TICKETS
// Définit tous les types possibles qu'un ticket peut avoir dans l'application
enum TicketType { a, b }

extension TicketTypeExtension on TicketType {
  String get displayName => toString().split('.').last;

  // Conversion from the backend
  static TicketType fromBackend(String backendType) {
    switch (backendType.toUpperCase()) {
      case 'A':
        return TicketType.a;
      case 'B':
        return TicketType.b;
      default:
        throw ArgumentError('Ticket type inconnu: $backendType');
    }
  }

  // Conversion to the backend
  String get toBackend {
    switch (this) {
      case TicketType.a:
        return 'A';
      case TicketType.b:
        return 'B';
    }
  }

  Color get displayColor {
    switch (this) {
      case TicketType.a:
        return Colors.blue;
      case TicketType.b:
        return Colors.cyan;
    }
  }
}
