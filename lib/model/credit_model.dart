class Credit {
  final int? creditId;
  final DateTime creditDate;
  final double creditAmount;
  final AccountDTO accountDTO;
  final UserDTO userDTO;

  // Constructeur principal
  Credit({
    this.creditId,
    required this.creditDate,
    required this.creditAmount,
    required this.accountDTO,
    required this.userDTO,
  });

  // Factory constructor pour créer un Credit à partir d'un JSON
  factory Credit.fromJson(Map<String, dynamic> json) {
    return Credit(
      creditId: json['creditId'],
      creditDate: DateTime.parse(json['creditDate']),
      creditAmount: (json['creditAmount'] as num?)?.toDouble() ?? 0.0,
      accountDTO: AccountDTO.fromJson(json['accountDTO']),
      userDTO: UserDTO.fromJson(json['userDTO']),
    );
  }

  /// Convertit l'objet Credit en Map JSON
  Map<String, dynamic> toJson() {
    return {
      'creditId': creditId,
      'creditDate':
          creditDate.toIso8601String().split('T')[0], // Format YYYY-MM-DD
      'creditAmount': creditAmount,
      'accountDTO': accountDTO.toJson(),
      'userDTO': userDTO.toJson(),
    };
  }

  // Crée une copie de l'objet Credit avec des valeurs optionnelles modifiées
  /* Credit copyWith({
    String? creditId,
    DateTime? creditDate,
    double? creditAmount,
    AccountDTO? accountDTO,
    UserDTO? userDTO,
  }) {
    return Credit(
      creditId: creditId ?? this.creditId,
      creditDate: creditDate ?? this.creditDate,
      creditAmount: creditAmount ?? this.creditAmount,
      accountDTO: accountDTO ?? this.accountDTO,
      userDTO: userDTO ?? this.userDTO,
    );
  } */

  @override
  String toString() {
    return 'Credit(creditId: $creditId, creditDate: $creditDate, creditAmount: $creditAmount, account: ${accountDTO.accountNumber}, user: ${userDTO.firstName} ${userDTO.lastName})';
  }

  /* @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Credit && other.creditId == creditId;
  }

  @override
  int get hashCode {
    return creditId.hashCode;
  } */
}

/// Modèles DTO associés (simplifiés pour l'exemple)
class AccountDTO {
  final int? accountId;
  final String accountNumber;
  final double balance;

  AccountDTO({
    this.accountId,
    required this.accountNumber,
    required this.balance,
  });

  factory AccountDTO.fromJson(Map<String, dynamic> json) {
    return AccountDTO(
      accountId: json['accountId'],
      accountNumber: json['accountNumber'] ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'accountNumber': accountNumber,
      'balance': balance,
    };
  }
}

class UserDTO {
  final int? userId;
  final String firstName;
  final String lastName;
  final String username;

  UserDTO({
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
        userId: json['userId'],
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        username: json['username'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
    };
  }
}
