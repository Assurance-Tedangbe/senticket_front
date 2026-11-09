import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage sécurisé et chiffré du token JWT sur l'appareil.
/// Équivalent de localStorage Angular mais chiffré sur Android/iOS.
class TokenStorageService {
  // chiffrement Android explicite: Instance unique du stockage chiffré
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';
  static const _roleKey = 'user_role';
  static const _usernameKey = 'username';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

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

  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<String?> getUserId() => _storage.read(key: _userIdKey);
  Future<String?> getRole() => _storage.read(key: _roleKey);
  Future<String?> getUsername() => _storage.read(key: _usernameKey);

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  Future<bool> isLoggedIn() => hasToken();

  Future<void> clearAll() => _storage.deleteAll();
}