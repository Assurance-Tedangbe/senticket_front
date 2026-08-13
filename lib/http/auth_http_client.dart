// lib/core/http/auth_http_client.dart
import 'package:http/http.dart' as http;
import '../services/token_storage_service.dart';

/// Intercepteur HTTP JWT pour Flutter.
/// Équivalent du TokenInterceptor Angular ou du Dio interceptor.
/// Fonctionnement :
///   - Hérite de http.BaseClient (remplace http.Client)
///   - Surcharge send() qui est appelé pour TOUTE requête HTTP
///     → Lit le token depuis TokenStorageService
///     → Ajoute Authorization: Bearer <token> si token présent
///     → Gère les 401 automatiquement (token expiré → nettoyage)
///
/// Si pas de token (inscription, login) : aucun header ajouté.
/// Les endpoints publics fonctionnent normalement.
///
/// Utilisation dans les services :
///   final _client = AuthHttpClient(onUnauthorized: () { ... });
///   final response = await _client.get(Uri.parse(...));
class AuthHttpClient extends http.BaseClient {
  final http.Client _inner;
  final TokenStorageService _tokenStorage;

  // Callback appelé quand le serveur retourne 401 (token expiré/invalide)
  // Flutter ne peut pas naviguer depuis ici directement,
  // donc le caller décide quoi faire (rediriger vers login, etc.)
  final void Function()? onUnauthorized;

  AuthHttpClient({
    http.Client? inner,
    TokenStorageService? tokenStorage,
    this.onUnauthorized,
  })  : _inner = inner ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Lire le token depuis le stockage sécurisé
    final token = await _tokenStorage.getToken();

    // Ajouter le header Authorization si token présent
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Envoyer la requête
    final response = await _inner.send(request);

    // Gérer le 401 : token expiré ou invalide
    if (response.statusCode == 401) {
      print('[AuthHttpClient] 401 reçu — token invalide ou expiré');
      await _tokenStorage.clearAll();
      onUnauthorized?.call();
    }

    return response;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}