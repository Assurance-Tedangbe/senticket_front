import 'dart:convert';

class QrCodeData {
  static const String userType   = 'SENTICKET_USER';
  static const String ticketType = 'SENTICKET_TICKET';

  final String type;
  final int userId;
  final String username;
  final String role;
  // Champs spécifiques au QR ticket (null si QR utilisateur)
  final int? ticketId;
  final String? ticketTypeLabel; // "A" ou "B"

  QrCodeData({
    required this.type,
    required this.userId,
    required this.username,
    required this.role,
    this.ticketId,
    this.ticketTypeLabel,
  });

  // QR utilisateur — identifie une personne
  factory QrCodeData.forUser({
    required int userId,
    required String username,
    required String role,
  }) => QrCodeData(
    type: userType,
    userId: userId,
    username: username,
    role: role,
  );

  // QR ticket — identifie un ticket précis pour débit direct
  factory QrCodeData.forTicket({
    required int ticketId,
    required String ticketTypeLabel,
    required int userId,
    required String username,
  }) => QrCodeData(
    type: ticketType,
    userId: userId,
    username: username,
    role: 'ETUDIANT',
    ticketId: ticketId,
    ticketTypeLabel: ticketTypeLabel,
  );

  String toQrString() => json.encode({
    'type': type,
    'userId': userId,
    'username': username,
    'role': role,
    if (ticketId != null) 'ticketId': ticketId,
    if (ticketTypeLabel != null) 'ticketTypeLabel': ticketTypeLabel,
  });

  static QrCodeData? fromQrString(String qrString) {
    try {
      final Map<String, dynamic> data = json.decode(qrString);
      if (data['type'] != userType && data['type'] != ticketType) return null;
      if (data['userId'] == null || data['username'] == null) return null;

      return QrCodeData(
        type: data['type'] as String,
        userId: data['userId'] as int,
        username: data['username'] as String,
        role: data['role'] as String? ?? 'ETUDIANT',
        ticketId: data['ticketId'] as int?,
        ticketTypeLabel: data['ticketTypeLabel'] as String?,
      );
    } catch (e) {
      print('[QrCodeData] Erreur parsing: $e');
      return null;
    }
  }

  bool get isUserQr   => type == userType;
  bool get isTicketQr => type == ticketType;
}
