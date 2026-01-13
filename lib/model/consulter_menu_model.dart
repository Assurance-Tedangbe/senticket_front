import 'package:senticket_front/model/menu_model.dart';

class ConsulterMenu {
  final int? consulterMenuId;
  final DateTime consultationDate;
  final Menu menu;
  final UserDTO userDTO;

  // Constructeur principal
  ConsulterMenu({
    this.consulterMenuId,
    required this.consultationDate,
    required this.menu,
    required this.userDTO,
  });

  // Factory constructor pour créer un ConsulterMenu à partir d'un JSON
  factory ConsulterMenu.fromJson(Map<String, dynamic> json) {
    return ConsulterMenu(
      consulterMenuId: json['consulterMenuId'],
      consultationDate: DateTime.parse(json['consultationDate']),
      menu: Menu.fromJson(json['menu']),
      userDTO: UserDTO.fromJson(json['userDTO']),
    );
  }

  /// Convertit l'objet ConsulterMenu en Map JSON
  Map<String, dynamic> toJson() {
    return {
      'consulterMenuId': consulterMenuId,
      'consultationDate': consultationDate.toIso8601String(),
      'menu': menu.toJson(),
      'userDTO': userDTO.toJson(),
    };
  }

  // Crée une copie de l'objet ConsulterMenu avec des valeurs optionnelles modifiées
  /*  ConsulterMenu copyWith({
    String? consulterMenuId,
    DateTime? consultationDate,
    Menu? menu,
    UserDTO? userDTO,
  }) {
    return ConsulterMenu(
      consulterMenuId: consulterMenuId ?? this.consulterMenuId,
      consultationDate: consultationDate ?? this.consultationDate,
      menu: menu ?? this.menu,
      userDTO: userDTO ?? this.userDTO,
    );
  } */

  @override
  String toString() {
    return 'ConsulterMenu(consulterMenuId: $consulterMenuId, consultationDate: $consultationDate, menu: ${menu.menuName}, user: ${userDTO.firstName} ${userDTO.lastName})';
  }

/*   @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConsulterMenu && other.consulterMenuId == consulterMenuId;
  }

  @override
  int get hashCode {
    return consulterMenuId.hashCode;
  } */
}

// Modèles DTO associés (simplifiés pour l'exemple)
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
