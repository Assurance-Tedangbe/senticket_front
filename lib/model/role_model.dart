class Role {
  final int? roleId;
  final String name;

  // Constructor
  Role({this.roleId, required this.name});

  // Factory constructor to create a Role from the API's JSON response
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: json['id'],
      name: json['name'],
    );
  }

  // Role object → JSON Map conversion for sending to the Spring Boot API
  Map<String, dynamic> toJson() {
    return {'id': roleId, 'name': name};
  }

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
