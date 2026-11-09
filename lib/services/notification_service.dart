import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:senticket_front/http/auth_http_client.dart';
import 'package:senticket_front/navigation/navigation_service.dart';
import 'package:senticket_front/config/network_config.dart';
import 'dart:convert';
import 'dart:async';


class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  // ✅ Client HTTP partagé pour les appels vers le backend
  static final _authClient = AuthHttpClient(
    onUnauthorized: () => NavigationService.goToLogin(),
  );

  static const _channel = AndroidNotificationChannel(
    'senticket_channel',
    'Senticket Notifications',
    description: "Notifications de l'application Senticket",
    importance: Importance.high,
  );

  static bool _localReady = false;
  static String? _userId;
  static StreamSubscription<RemoteMessage>? _onMessageSub;
  static StreamSubscription<String>? _onRefreshSub;

  /// À appeler après login / restauration de session. Peut l'être plusieurs fois.
  static Future<void> initialize(String userId) async {
    print('[Notif] ▶ initialize() — userId: $userId');

    if (userId.isEmpty) return;
      _userId = userId;

      await _setupLocalNotifications();

    // Demander la permission à l'utilisateur
    final settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true);
    print('[Notif] Permission: ${settings.authorizationStatus}');

    // Un seul écouteur, quel que soit le nombre d'appels
    _onMessageSub ??= FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    await _onRefreshSub?.cancel();
    _onRefreshSub = _messaging.onTokenRefresh.listen((t) {
      final id = _userId;
      if (id != null) _saveFcmToken(id, t);
    });

    // Récupérer le FCM token et l'envoyer au backend
    final token = await _messaging.getToken();
    print('[Notif] FCM Token: $token');
    if (token != null) await _saveFcmToken(userId, token); // ← userId passé directement

    // Rafraîchir si Firebase régénère le token
    _messaging.onTokenRefresh.listen((newToken) {
      _saveFcmToken(userId, newToken);
    });
  }

  /// À appeler au logout : détache cet appareil du compte
  static Future<void> onLogout() async {
    _userId = null;
    await _onRefreshSub?.cancel();
    _onRefreshSub = null;
    try {
      await _messaging.deleteToken(); // le prochain login obtiendra un nouveau token
    } catch (e) {
      print('[Notif] deleteToken: $e');
    }
  }

  // Initialiser les notifications locales (affichage en foreground)
  static Future<void> _setupLocalNotifications() async {
    if (_localReady) return;
    await _localNotifications.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ));
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
    _localReady = true;
  }

  /// Envoie le FCM token au backend — directement via HTTP,
  /// sans passer par UserApiService pour éviter les dépendances circulaires
  /// ✅ userId passé en paramètre — plus de lecture depuis stockage
  static Future<void> _saveFcmToken(String userId, String token) async {
    try {
      print('[Notif] _saveFcmToken — userId: $userId');
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
        print('[Notif] ✅ FCM token sauvegardé pour userId: $userId');
      } else {
        print('[Notif] Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      // Ne jamais faire échouer l'initialisation
      print('[Notif] _saveFcmToken error: $e');
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

    print('[Notif] Message foreground: '
        '${notification.title} — ${notification.body}');
  }
}