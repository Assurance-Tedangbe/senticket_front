import 'package:senticket_front/model/role_model.dart';

class User {
  final int? userId; // User ID (null if new user)
  final String username;
  final String password; // Password (can be empty for reading)
  final String email;
  final String firstName;
  final String lastName;
  final Role role;

  User({
    this.userId,
    required this.username,
    required this.password,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  // JSON -> User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        userId: json['userId'],
        username: json['username'],
        password: json['password'] ?? '', // Default value if null
        email: json['email'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        role: Role.fromJson(json['roleDTO']));
  }

  // User -> JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'password': password,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'roleDTO': role.toJson(),
    };
  }

  // Creates a copy of the user with some modified values: useful for edit forms
/*   User copyWith({
    int? userId,
    String? username,
    String? password,
    String? email,
    String? firstName,
    String? lastName,
    Role? role,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
    );
  } */
}
