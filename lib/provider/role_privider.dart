import 'package:flutter/foundation.dart';
import 'package:senticket_front/model/role_model.dart';
import 'package:senticket_front/services/role_service.dart';

class RoleProvider with ChangeNotifier {
  final RoleApiService _roleservice;

  List<Role> _roles = [];
  Role? _currentRole;
  bool _isLoading = false;
  String _error = '';

  bool _isCreatingRole = false;
  bool _isFetchingRole =
      false;

  String _createRoleError = '';

  RoleProvider(this._roleservice);

  List<Role> get roles => _roles;
  Role? get currentRole => _currentRole;
  bool get isLoading => _isLoading;
  String get error => _error;

  bool get isCreatingRole => _isCreatingRole;
  bool get isFetchingRole => _isFetchingRole;

  String get createRoleError => _createRoleError;

  // ************************ READ ALL ROLES **************************

  Future<void> loadAllRoles({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _roles = await _roleservice.getAllRoles(forceRefresh: forceRefresh);
      _error = '';
      print("✅ - ${_roles.length} rôles chargés");
    } catch (e) {
      _error = 'Erreur lors du chargement des rôles: ${e.toString()}';
      print(" Erreur dans loadAllRoles: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
  /*
 // ************************** CREATE ROLE ***************************
  Future<bool> createNewRole(Role role) async {
    _isCreatingRole = true;
    _createRoleError = '';
    _isLoading = true;
    notifyListeners();

    try {
      final newRole = await _roleservice.createRole(role);
      _roles.add(newRole);

      _createRoleError = '';
      _error = '';
      print("✅ Rôle créé avec succès: ${newRole.name}");
      return true;
    } catch (e) {
      _createRoleError = 'Erreur lors de la création: ${e.toString()}';
      _error = 'Erreur lors de la création: ${e.toString()}';
      print(" Erreur dans createNewRole: $e");
      return false;
    } finally {
      _isCreatingRole = false;
      _isLoading = false;
      notifyListeners();
    }
  }
  */


