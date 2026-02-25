import 'package:flutter/foundation.dart'; // Import les bases de Flutter, dont ChangeNotifier
import 'package:senticket_front/model/role_model.dart';
import 'package:senticket_front/model/user_model.dart';
import 'package:senticket_front/services/user_service.dart';

class UserProvider with ChangeNotifier {
  //Creates a class that can notify its listeners of changes
  // _ means these variables are private

  final UserApiService _service;

  // Main state
  List<User> _users = []; // Empty list to store all users
  User? _currentUser; // Currently selected user (can be null)
  bool _isLoading = false; // load indicator (initially false)
  String _error = ''; // Stores error messages (initially empty)

  // State for specific operations
  bool _isCreatingUser = false; // Creation in progress
  bool _isUpdatingUser = false;
  bool _isDeletingUser = false;
  bool _isLoggingIn = false;
  /*   bool _isUpdatingPassword = false;
  bool _isAddRoleToUser = false;
  bool _isRemoveRoleFromUser = false; */

  // State for signup form
  String _firstName = '';
  String _lastName = '';
  String _username = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isPasswordVisible = false;
  Role? _role;

  // Connexion state
  String _loginUsername = '';
  String _loginPassword = '';
  String? _authToken; // Pour stocker le token JWT si votre API l'utilise

  // Consult form state
  String _consultUsername = '';
  bool _isConsultingUser = false;

  // variables d'état pour edit form
  String _updateFirstName = '';
  String _updateLastName = '';
  String _updateUsername = '';
  String _updateEmail = '';
  String _updatePassword = '';
  Role? _updateRole;

  // DEBIT FORM STATE
  String _debitUsername = '';
  bool _isSearchingUser = false;
  User? _searchedUser; // Utilisateur recherché
  String? _debitUsernameError;

  // TRANSFER FORM STATE: pour la recherche du destinataire
  String _transferRecipientUsername = '';
  bool _isSearchingRecipient = false;
  User? _searchedRecipient;
  String? _transferRecipientError;

  String _senderPassword = '';
  String? _senderPasswordError;
  //String? _recipientError;

  UserProvider(this._service);

  // GETTERS - Accès contrôlé à l'état ===

  // Main Getters
  List<User> get users =>
      _users; // Allows other classes to read `_users` but not modify it.
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Getters for specific states
  bool get isCreatingUser => _isCreatingUser;
  bool get isUpdatingUser => _isUpdatingUser;
  bool get isDeletingUser => _isDeletingUser;
  bool get isLoggingIn => _isLoggingIn;
  /*   bool get isUpdatingPassword => _isUpdatingPassword;
  bool get isAddRoleToUser => _isAddRoleToUser;
  bool get isRemoveRoleFromUser => _isRemoveRoleFromUser; */

  // Signup Getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get username => _username;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  bool get isPasswordVisible => _isPasswordVisible;
  Role? get role => _role;

  // Connexion getters
  String get loginUsername => _loginUsername;
  String get loginPassword => _loginPassword;
  String? get authToken => _authToken;

  // Getters for consul form
  String get consultUsername => _consultUsername;
  bool get isConsultingUser => _isConsultingUser;
  bool get isConsultFormValid => _consultUsername.isNotEmpty;

  // Getters pour edit form
  String get updateFirstName => _updateFirstName;
  String get updateLastName => _updateLastName;
  String get updateUsername => _updateUsername;
  String get updateEmail => _updateEmail;
  String get updatePassword => _updatePassword;
  Role? get updateRole => _updateRole;

  // Getter pour l'utilisateur consulté
  User? get consultedUser => _currentUser;

  // Getters for debit form
  String get debitUsername => _debitUsername;
  bool get isSearchingUser => _isSearchingUser;
  User? get searchedUser => _searchedUser;
  String? get debitUsernameError => _debitUsernameError;
  bool get isDebitFormValid => _debitUsername.isNotEmpty;

  // Getters for transfer form
  String get transferRecipientUsername => _transferRecipientUsername;
  User? get searchedRecipient => _searchedRecipient;
  String? get transferRecipientError => _transferRecipientError;
  bool get isSearchingRecipient => _isSearchingRecipient;
  bool get isTransferFormValid =>
      _transferRecipientUsername.isNotEmpty; //&& _searchedRecipient != null;
  String get senderPassword => _senderPassword;
  String? get senderPasswordError => _senderPasswordError;

  // **************** setters for signup form ***************
  void setFirstname(String value) {
    _firstName = value;
    notifyListeners(); // ← Reconstruction automatique du widget
  }

  void setLastname(String value) {
    _lastName = value;
    notifyListeners();
  }

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setRole(Role value) {
    print('=== setRole appelé ===');
    print('Valeur reçue: ${value.name} (ID: ${value.roleId})');
    print('Ancien _role: ${_role?.name}');

    _role = value;

    print('Nouveau _role: ${_role?.name}');
    print('Rôle ID: ${_role?.roleId}');
    print('Rôle est null? ${_role == null}');

    notifyListeners();
  }

  // *************** Connexion setters ****************
  void setLoginUsername(String value) {
    _loginUsername = value;
    notifyListeners();
  }

  void setLoginPassword(String value) {
    _loginPassword = value;
    notifyListeners();
  }

  //  *************** Consult form setters ****************
  void setConsultUsername(String value) {
    _consultUsername = value;
    notifyListeners();
  }

  // ************* Setter pour currentUser (manquant)
  set currentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  // *************** Setters for edit form ****************
  void setUpdateFirstName(String value) {
    _updateFirstName = value;
    notifyListeners();
  }

  void setUpdateLastName(String value) {
    _updateLastName = value;
    notifyListeners();
  }

  void setUpdateUsername(String value) {
    _updateUsername = value;
    notifyListeners();
  }

  void setUpdateEmail(String value) {
    _updateEmail = value;
    notifyListeners();
  }

  void setUpdatePassword(String value) {
    _updatePassword = value;
    notifyListeners();
  }

  void setUpdateRole(Role value) {
    _updateRole = value;
    notifyListeners();
  }

  // ************** Setters pour debit form ***************
  void setDebitUsername(String value) {
    _debitUsername = value;
    _debitUsernameError =
        null; // Réinitialiser l'erreur quand l'utilisateur tape
    notifyListeners();
  }

  // Définir l'erreur de nom d'utilisateur pour débit
  void setDebitUsernameError(String error) {
    _debitUsernameError = error;
    notifyListeners();
  }

  // ************** Setters pour transfer form ***************
  void setTransferRecipientUsername(String value) {
    _transferRecipientUsername = value;
    _transferRecipientError = null;
    notifyListeners();
  }

  // Définir l'erreur de nom d'utilisateur pour transfert
  void setTransferRecipientError(String error) {
    _transferRecipientError = error;
    notifyListeners();
  }

  // Définir l'erreur de nom d'utilisateur pour transfert
  void setSenderPassword(String value) {
    _senderPassword = value;
    _senderPasswordError = null;
    notifyListeners();
  }

  // Définir l'erreur de nom d'utilisateur pour transfert
  void setSenderPasswordError(String error) {
    _senderPasswordError = error;
    notifyListeners();
  }

  // *************** Load all users from the service ****************
  Future<void> loadAllUsers({bool forceRefresh = false}) async {
    //load the users, this will take some time (async)

    _isLoading = true; // activate the loading
    _error = ''; // clear previous errors
    notifyListeners(); // notify the UI of the loading begin

    try {
      _users = await _service.getAllUsers(
        forceRefresh: forceRefresh,
      ); //Ask the service to give me all the users

      _error = ''; //Confirm that there are no errors
      print(" successfully laoding : ${_users.length} users");
    } catch (e) {
      _error = e.toString(); // Stocke l'erreur
      print(" Error loadAllUsers: $e");
    } finally {
      _isLoading = false; // stop the loading
      notifyListeners(); // notify the UI of the loading end"
    }
  }

  // ***************** FOR SIGN UP ****************

  Future<bool> createNewUser(User user) async {
    //I'm going to create a user and I'll tell you if it worked (bool)"
    _isCreatingUser = true;
    _isLoading = true;
    notifyListeners(); //start the job and notify the interface

    try {
      // Validate the data before creation
      _service.validateUserData(user);

      final newUser = await _service.createUser(
        user,
      ); // ask the service to create this user in the API

      _users.add(newUser); // If it works, add the new user to my local list

      _error = ''; // Clears errors
      print(" User created successfully: ${newUser.username}");
      return true; // Success
    } catch (e) {
      _error = 'Error creation: ${e.toString()}';
      print("Erreur createNewUser: $e");
      return false; // Failure
    } finally {
      _isCreatingUser = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Validation
  bool get isFormValid =>
      _firstName.isNotEmpty &&
      _lastName.isNotEmpty &&
      _username.isNotEmpty &&
      _email.isNotEmpty &&
      _password.isNotEmpty &&
      _password == _confirmPassword &&
      _password.length >= 6;

  String? get passwordError {
    if (_password.isNotEmpty && _password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    if (_confirmPassword.isNotEmpty && _password != _confirmPassword) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  String? get emailError {
    if (_email.isNotEmpty && !_email.contains('@')) {
      return 'Email invalide';
    }
    return null;
  }

  Future<bool> submitSignup() async {
    print('1. _firstName: $_firstName');
    print('2. _role: $_role');
    print('3. _role?.name: ${_role?.name}');

    if (!isFormValid) {
      _error = 'Veuillez remplir tous les champs correctement';
      notifyListeners();
      return false;
    }

    // Vérifiez que le rôle est sélectionné
    if (_role == null) {
      print(" ERREUR CRITIQUE: _role est null dans submitSignup!");
      _error = 'Veuillez sélectionner un rôle';
      notifyListeners();
      return false;
    }

    try {
      final user = User(
        firstName: _firstName,
        lastName: _lastName,
        username: _username,
        email: _email,
        password: _password,
        role: _role!,
      );

      print('🔄 Création de l\'utilisateur avec rôle: ${_role!.name}');

      return await createNewUser(user);
    } catch (e) {
      _error = 'Erreur lors de l\'inscription: $e';
      notifyListeners();
      return false;
    }
  }

  // Reset of signup form
  void resetForm() {
    _firstName = '';
    _lastName = '';
    _username = '';
    _email = '';
    _password = '';
    _confirmPassword = '';
    _role = null;
    _error = '';
    notifyListeners();
  }

  // ****************** FOR LOGIN FORM ************************

  // Validation pour la connexion
  bool get isLoginFormValid =>
      _loginUsername.isNotEmpty && _loginPassword.isNotEmpty; /* &&
      loginUsernameError == null &&
      loginPasswordError == null; */

  String? get loginUsernameError {
    if (_loginUsername.isEmpty) {
      return 'Le nom d\'utilisateur est requis';
    }
    return null;
  }

  String? get loginPasswordError {
    if (_loginPassword.isEmpty) {
      return 'Le mot de passe est requis';
    }
    return null;
  }

  void resetLoginForm() {
    _loginUsername = '';
    _loginPassword = '';
    _error = '';
    notifyListeners();
  }

  Future<bool> submitLogin() async {
    print('1. loginUsername: $_loginUsername');
    print('3. isLoginFormValid: $isLoginFormValid');

    if (!isLoginFormValid) {
      _error = 'Veuillez remplir tous les champs';
      notifyListeners();
      return false;
    }

    _isLoggingIn = true;
    _error = '';
    notifyListeners();

    try {
      print('🔄 Tentative de connexion avec: $_loginUsername');

      // Appel au service de connexion
      final user = await _service.login(_loginUsername, _loginPassword);

      _currentUser = user;
      _isLoggingIn = false;
      _error = '';
      notifyListeners();

      print('✅ Connexion réussie: ${user.username}');
      print('ID: ${user.userId}');
      print('Rôle name: ${user.role.name}');

      // Réinitialise le formulaire de connexion
      resetLoginForm();

      return true;
    } catch (e) {
      _isLoggingIn = false;
      _error = 'Erreur de connexion: ${e.toString()}';
      notifyListeners();

      print(' Erreur de connexion: $e');
      return false;
    }
  }

  // ****************** FOR CONSULT FORM **********************

  Future<bool> submitConsult() async {
    if (!isConsultFormValid) {
      _error = 'Veuillez saisir un nom d\'utilisateur';
      notifyListeners();
      return false;
    }

    _isConsultingUser = true;
    _error = '';
    notifyListeners();

    try {
      print('🔍 Consultation du compte pour: $_consultUsername');

      // Appel au service pour récupérer l'utilisateur
      final user = await _service.getUserByUsername(_consultUsername);

      _currentUser = user;
      _isConsultingUser = false;
      _error = '';
      notifyListeners();

      print('✅ Compte trouvé: ${user.username}');
      return true;
    } catch (e) {
      _isConsultingUser = false;
      _error = 'Utilisateur non trouvé ou erreur de connexion';
      notifyListeners();

      print(' Erreur lors de la consultation: $e');
      return false;
    }
  }

  String? get consultUsernameError {
    return _consultUsername.isEmpty ? 'Le nom d\'utilisateur est requis' : null;
  }

  // To filter by role
  List<User> getUsersByRole(String roleName) {
    return _users.where((user) {
      return user.role.name.toUpperCase() == roleName.toUpperCase();
    }).toList();
  }

  // for loading User For Consultation
  Future<void> loadUserForConsultation(int userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _service.getUserById(userId);
      _error = '';
    } catch (e) {
      _error = 'Erreur lors du chargement: ${e.toString()}';
      print("Error loadUserForConsultation: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // This method returns void because the result is stored in _currentUser
  Future<void> loadUserById(int userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _currentUser = await _service.getUserById(
        userId,
      ); //request a specific user by its id from the API and store it in _currentUser"
      _error = '';
      print(" User loaded by ID: $userId");
    } catch (e) {
      _error = 'Error loading user: ${e.toString()}';
      print("Error loadUserById: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear the current user and notify the UI
  void clearCurrentUser() {
    _currentUser = null;
    notifyListeners();
  }

  //  ****************** FOR EDIT USER FORM ******************

  // Validation pour edit form
  bool get isUpdateFormValid =>
      _updateFirstName.isNotEmpty &&
      _updateLastName.isNotEmpty &&
      _updateUsername.isNotEmpty &&
      _updateEmail.isNotEmpty &&
      _updatePassword.isNotEmpty &&
      _updatePassword.length >= 6;

  String? get updatePasswordError {
    if (_updatePassword.isNotEmpty && _updatePassword.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  String? get updateEmailError {
    if (_updateEmail.isNotEmpty && !_updateEmail.contains('@')) {
      return 'Email invalide';
    }
    return null;
  }

  // for prefilling fields with existing user data
  void prefillUpdateForm(User user) {
    _updateFirstName = user.firstName;
    _updateLastName = user.lastName;
    _updateUsername = user.username;
    _updateEmail = user.email;
    // _updatePassword = user.password;
    _updatePassword = ''; // Ne pas pré-remplir le mot de passe pour la sécurité
    _updateRole = user.role;

    // Si vous voulez conserver l'utilisateur courant pour la mise à jour
    _currentUser = user;

    notifyListeners();
  }

  // Méthode pour soumettre la mise à jour
  Future<bool> submitUpdate() async {
    if (!isUpdateFormValid) {
      _error = 'Veuillez remplir tous les champs correctement';
      notifyListeners();
      return false;
    }

    _isUpdatingUser = true;
    _error = '';
    notifyListeners();

    try {
      // Utilisez l'ID de l'utilisateur courant
      if (_currentUser == null) {
        throw Exception('Aucun utilisateur sélectionné pour la modification');
      }

      // Gestion spéciale du mot de passe
      String finalPassword;
      if (_updatePassword.isEmpty || _updatePassword == '********') {
        // Garder l'ancien mot de passe
        finalPassword = _currentUser!.password;
        print('🔄 Mot de passe inchangé');
      } else {
        // Utiliser le nouveau mot de passe
        finalPassword = _updatePassword;
        print('🔄 Mot de passe mis à jour');
      }

      // Créez l'objet User mis à jour
      final updatedUser = User(
        userId: _currentUser!.userId,
        firstName: _updateFirstName,
        lastName: _updateLastName,
        username: _updateUsername,
        email: _updateEmail,
        password: finalPassword,
        /*  _updatePassword.isNotEmpty
            ? _updatePassword
            : _currentUser!.password, */
        role: _updateRole ?? _currentUser!.role,
      );

      // Appelez le service de mise à jour
      final success = await updateExistingUser(updatedUser);

      if (success) {
        // Réinitialisez le formulaire
        resetUpdateForm();
      }

      return success;
    } catch (e) {
      _error = 'Erreur lors de la modification: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isUpdatingUser = false;
      notifyListeners();
    }
  }

  // Réinitialiser le formulaire de modification
  void resetUpdateForm() {
    _updateFirstName = '';
    _updateLastName = '';
    _updateUsername = '';
    _updateEmail = '';
    _updatePassword = '';
    _updateRole = null;
    _error = '';
    notifyListeners();
  }

  // Updates an existing user
  Future<bool> updateExistingUser(User user) async {
    _isUpdatingUser = true;
    _isLoading = true;
    notifyListeners();

    try {
      _service.validateUserData(user);

      final updatedUser = await _service.updateUser(
        user,
      ); //asking the API to update this user

      // Updates in the local list
      final index = _users.indexWhere(
        (u) => u.userId == user.userId,
      ); //looking for this user's position in my list
      if (index != -1) {
        _users[index] =
            updatedUser; //If I found the user (index != -1), I replace the old version with the new one"
      }

      _error = '';
      print(" User updated successfully: ${updatedUser.username}");
      return true;
    } catch (e) {
      _error = 'Error updating user: ${e.toString()}';
      print(" Error updateExistingUser: $e");
      return false;
    } finally {
      _isUpdatingUser = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ********************** FOR DEBIT FORM ************************

  // Search user by username (generic, can be used for both debit and transfer)
  Future<bool> searchUserByUsername(String username) async {
    if (username.isEmpty) {
      _debitUsernameError = 'Veuillez entrer un nom d\'utilisateur';
      notifyListeners();
      return false;
    }

    _isSearchingUser = true;
    _searchedUser = null;
    _debitUsernameError = null;
    // Réinitialiser l'erreur de transfert
    // _isSearchingRecipient = true;
    // _searchedRecipient = null;
    _transferRecipientError = null;
    notifyListeners();

    try {
      print(
        '🔍 Recherche de l\'utilisateur pour débiter son compte: $username',
      );

      final user = await _service.getUserByUsername(username);

      _searchedUser = user;
      _isSearchingUser = false;
      _debitUsernameError = null;
      //for transfer form
      _searchedRecipient = user;
      _isSearchingRecipient = false;
      // _transferRecipientError = null;
      notifyListeners();

      print('Utilisateur trouvé: ${user.username} (Rôle: ${user.role.name})');
      return true;
    } catch (e) {
      _isSearchingUser = false;
      _searchedUser = null;
      _debitUsernameError = 'Utilisateur non trouvé ';
      //for transfer form
      _transferRecipientError = 'Utilisateur non trouvé';
      _searchedRecipient = null;
      _isSearchingRecipient = false;
      notifyListeners();

      print('Erreur lors de la recherche: $e');
      return false;
    }
  }

  /*  // Search user by username (generic, can be used for both debit and transfer)
  Future<bool> searchUserByUsername(String username) async {
    _isSearchingUser = true;
    _transferRecipientError = null;
    notifyListeners();

    try {
      // Assuming you have a method in UserApiService to get user by username
      final user = await _service.getUserByUsername(username);
      _searchedRecipient = user;
      _isSearchingRecipient = false;
      notifyListeners();
      return true;
    } catch (e) {
      _transferRecipientError = 'Utilisateur non trouvé';
      _searchedRecipient = null;
      _isSearchingRecipient = false;
      notifyListeners();
      return false;
    }
  } */

  // Réinitialiser l'état de débit
  void resetDebitState() {
    _debitUsername = '';
    _isSearchingUser = false;
    _searchedUser = null;
    _debitUsernameError = null;
    notifyListeners();
  }

  // ********************** FOR TRANSFERT TICKET(S) FORM ************************

  // Réinitialiser l'état de transfert
  void resetTransferState() {
    _transferRecipientUsername = '';
    _senderPassword = '';
    _isSearchingRecipient = false;
    _searchedRecipient = null;
    _transferRecipientError = null;
    _senderPasswordError = null;
    notifyListeners();
  }

  // *********************** for deleting user ***********************
  Future<bool> deleteExistingUser(int userId) async {
    _isDeletingUser = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.deleteUser(
        userId,
      ); //asking the API to delete the user with this ID

      // remove the user from the local list
      _users.removeWhere((user) => user.userId == userId);

      _error = '';
      print(" User with this ID deleted: $userId");
      return true;
    } catch (e) {
      _error = 'Error deleting: ${e.toString()}';
      print("Error deleteExistingUser: $e");
      return false;
    } finally {
      _isDeletingUser = false;
      _isLoading = false;
      notifyListeners();
    }
  }
}
  /*   
  //********** Suppl methods not used ************
 
  // *********************** for loging out ***********************
  Future<void> logout() async {
    try {
      // Optionnel: Appeler l'API pour invalider le token
      // await _service.logout();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    } finally {
      _currentUser = null;
      _authToken = null;
      resetLoginForm();
      notifyListeners();

      print('Déconnexion réussie');
    }
  }

    // Load a specific user by its username
    Future<void> loadUserByUsername(String username) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _currentUser = await _service.getUserByUsername(
        username,
      ); //I request a specific user by its username from the API and store it in _currentUser"
      _error = '';
      print(" User loaded with username: $username");
    } catch (e) {
      _error = 'Error loading user with username: ${e.toString()}';
      print(" Error loadUserByUsername: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  } 

  // ******************* Update password *****************
  Future<bool> updateUserPassword(int userId, String newPassword) async {
    _isUpdatingPassword = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updatePassword(
        userId,
        newPassword,
      ); // asking the API to change the password for this user

      _error = '';
      print(" User password updated successfully: $newPassword");
      return true;
    } catch (e) {
      _error = 'Error updating user password: ${e.toString()}';
      print("Error updatePassword: $e");
      return false;
    } finally {
      _isUpdatingPassword = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Force data refresh
  Future<void> refreshData() async {
    await loadAllUsers(forceRefresh: true);
  }

  // Clear the error message and notify the UI
  void clearError() {
    _error = '';
    notifyListeners();
  }

   // Validation du formulaire de débit
  String? getDebitUsernameError() {
    if (_debitUsername.isEmpty) {
      return 'Le nom d\'utilisateur est requis';
    }
    return null;
  } */  


  // Add role to an existing user
  Future<bool> addRoleToExistingUser(int userId, int roleId) async {
    _isAddRoleToUser = true;
    _isLoading = true;
    notifyListeners();

    try {
      await _service.addRoleToUser(
        userId,
        roleId,
      ); //“adding a role to a user via the API”

      _error = '';
      print("Role $roleId added to user $userId");
      return true;
    } catch (e) {
      _error = 'Error adding role: ${e.toString()}';
      print(" Error addRoleToUser: $e");
      return false;
    } finally {
      _isAddRoleToUser = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Searching for users (uses the service's local cache)
  List<User> searchUsers(String query) {
    return _service.searchUsers(query);
  }
 */


