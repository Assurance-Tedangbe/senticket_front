import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage sécurisé et chiffré du token JWT sur l'appareil.
/// Équivalent de localStorage Angular mais chiffré sur Android/iOS.
class TokenStorageService {

  // ✅ Version 2 : chiffrement Android explicite
  // Instance unique du stockage chiffré
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';
  static const _roleKey = 'user_role';
  static const _usernameKey = 'username';

  // ============ ÉCRITURE ============
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // ✅ Nom saveUserSession (plus clair que saveUserInfo)
  Future<void> saveUserSession({
    required String userId,
    required String username,
    required String role,
  }) async {
    print('[TokenStorage] Sauvegarde — userId: $userId, username: $username');
    await _storage.write(key: _userIdKey, value: userId); // ← clé exacte
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _roleKey, value: role);
  }

  // ============ LECTURE ============
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
  // ✅ Version 2 : try/catch évite les crashes sur certains appareils Android
  /*Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (_) {
      return null;
    }
  }*/

 // Future<String?> getUserId() async => _storage.read(key: _userIdKey);
  Future<String?> getUserId() async {
    final id = await _storage.read(key: _userIdKey);  // ← même clé
    print('[TokenStorage] getUserId: $id');
    return id;
   // return await _storage.read(key: 'userId');
  }
  Future<String?> getRole() async => _storage.read(key: _roleKey);
  Future<String?> getUsername() async => _storage.read(key: _usernameKey);

  // ✅ Garde les deux noms pour compatibilité avec le reste du code
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Alias pour compatibilité avec UserProvider qui appelle isLoggedIn()
  Future<bool> isLoggedIn() => hasToken();

  // ============ SUPPRESSION ============
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}