import 'package:flutter/foundation.dart';
import 'package:senticket_front/model/role_model.dart';
import 'package:senticket_front/services/role_service.dart';

class RoleProvider with ChangeNotifier {
  final RoleApiService _roleservice;

  List<Role> _roles = [];
  Role? _currentRole;
  bool _isLoading = false;
  String _error = '';

  RoleProvider(this._roleservice);

  List<Role> get roles => _roles;
  Role? get currentRole => _currentRole;
  bool get isLoading => _isLoading;
  String get error => _error;

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


