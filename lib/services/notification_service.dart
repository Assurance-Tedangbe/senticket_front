import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:senticket_front/services/token_storage_service.dart';
import 'package:senticket_front/http/auth_http_client.dart';
import 'package:senticket_front/navigation/navigation_service.dart';
import 'package:senticket_front/config/network_config.dart';
import 'dart:convert';

class NotificationService {

  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  // ✅ Client HTTP partagé pour les appels vers le backend
  static final _authClient = AuthHttpClient(
    onUnauthorized: () => NavigationService.goToLogin(),
  );
  static final _tokenStorage = TokenStorageService();

  static Future<void> initialize() async {
    // Demander la permission à l'utilisateur
    final settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );
    print('[NotificationService] Permission: ${settings.authorizationStatus}');

    // Initialiser les notifications locales (affichage en foreground)
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);

    // Créer le canal Android (obligatoire depuis Android 8)
    const channel = AndroidNotificationChannel(
      'senticket_channel',
      'Senticket Notifications',
      description: 'Notifications de l\'application Senticket',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Écouter les messages reçus quand l'app est au premier plan
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Récupérer le FCM token et l'envoyer au backend
    final token = await _messaging.getToken();
    print('[NotificationService] FCM Token: $token');
    if (token != null) await _saveFcmToken(token);

    // Rafraîchir le token si Firebase le régénère
    _messaging.onTokenRefresh.listen(_saveFcmToken);
  }

  /// Envoie le FCM token au backend — directement via HTTP,
  /// sans passer par UserApiService pour éviter les dépendances circulaires
  static Future<void> _saveFcmToken(String token) async {
    try {
      // Récupérer l'userId depuis le stockage local
      final userId = await _tokenStorage.getUserId();
      if (userId == null || userId.isEmpty) {
        print('[NotificationService] userId absent — token non envoyé');
        return;
      }

      final url = Uri.parse(
          '${NetworkConfig.baseUrl}/api/users/$userId/fcm-token');

      final response = await _authClient.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        print('[NotificationService] ✅ FCM token sauvegardé pour userId: $userId');
      } else {
        print('[NotificationService] Erreur sauvegarde token: ${response.statusCode}');
      }
    } catch (e) {
      // Ne jamais faire échouer l'initialisation
      print('[NotificationService] Erreur _saveFcmToken: $e');
    }
  }

  /// Affiche une notification locale quand l'app est au premier plan
  static void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'senticket_channel',
          'Senticket Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    print('[NotificationService] Message foreground: '
        '${notification.title} — ${notification.body}');
  }
}