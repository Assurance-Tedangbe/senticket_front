/*
import 'package:senticket_front/model/user_model.dart';

class TransfertHistory {
  final int id;
  final String ticketIdsTransfered;
  final User senderDTO;
  final User recipientDTO;
  final DateTime transferDate;
  final bool canceled;

  TransfertHistory({
    required this.id,
    required this.ticketIdsTransfered,
    required this.senderDTO,
    required this.recipientDTO,
    required this.transferDate,
    required this.canceled,
  });

  factory TransfertHistory.fromJson(Map<String, dynamic> json) {
    return TransfertHistory(
      id: json['id'],
      ticketIdsTransfered: json['ticketIdsTransfered'],
      senderDTO: User.fromJson(json['senderDTO']),
      recipientDTO: User.fromJson(json['recipientDTO']),
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

  // Helper pour extraire la liste des IDs
  List<int> get ticketIds {
    String cleaned = ticketIdsTransfered
        .replaceAll('[', '')
        .replaceAll(']', '');
    if (cleaned.isEmpty) return [];
    return cleaned.split(',').map((s) => int.parse(s.trim())).toList();
  }
}
*/
