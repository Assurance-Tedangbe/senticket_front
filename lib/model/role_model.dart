class Role {
  final int? roleId; // null si nouveau rôle)
  final String name;

  // Constructor with required named parameters
  Role({this.roleId, required this.name});

  // Factory constructor to create a Role from the API's JSON response
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: json['roleId'], // Extracts the role ID from the JSON
      name: json['name'], // Extracts the role name from the JSON
    );
  }

  // Role object → JSON Map conversion for sending to the Spring Boot API
  Map<String, dynamic> toJson() {
    return {'roleId': roleId, 'name': name};
  }

  // Creates a copy of the role with certain modified values
  // useful for modifying forms without affecting the original
  /* Role copyWith({
    int? roleId,
    String? roleName,
  }) {
    return Role(
      roleId: roleId ?? this.roleId, // Keep the old roleId if not provided
      roleName: roleName ?? this.roleName,
    );
  } */

  // Textual representation for debugging
  @override
  String toString() {
    return 'Role(roleId: $roleId, name: $name)';
  }

  /* // Compare two roles for equality (based on roleId and name)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Role &&
        other.roleId == roleId &&
        other.roleName == roleName;
  }

  // HashCode for using roles in Sets and Maps
  @override
  int get hashCode => roleId.hashCode ^ roleName.hashCode; */
}
