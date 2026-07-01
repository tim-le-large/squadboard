import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/firebase_config.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(
    FirebaseMessaging.instance,
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

/// Foreground push banner stream (SnackBar in [HomeScreen]).
final pushBannerProvider = StateProvider<PushBanner?>((ref) => null);

class PushBanner {
  const PushBanner({required this.title, required this.body});

  final String title;
  final String body;
}

class PushNotificationService {
  PushNotificationService(
    this._messaging,
    this._firestore,
    this._auth,
  );

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  final _localNotifications = FlutterLocalNotificationsPlugin();
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  bool _initialized = false;

  static bool get isAvailable =>
      FirebaseConfig.isConfigured &&
      (!kIsWeb || FirebaseConfig.vapidKey.isNotEmpty);

  Future<void> initialize(WidgetRef ref) async {
    if (!isAvailable || _initialized) return;
    _initialized = true;

    if (!kIsWeb) {
      await _setupLocalNotifications();
    }

    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      _showForegroundNotification(message, ref);
    });

    _tokenRefreshSub = _messaging.onTokenRefresh.listen(_saveToken);

    final user = _auth.currentUser;
    if (user != null && await areNotificationsEnabled()) {
      await _syncTokenForCurrentUser();
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
  }

  Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<bool> requestPermissionAndSync() async {
    if (!isAvailable) return false;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    if (granted) {
      await _syncTokenForCurrentUser();
    }
    return granted;
  }

  Future<void> _syncTokenForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken(
      vapidKey: kIsWeb && FirebaseConfig.vapidKey.isNotEmpty
          ? FirebaseConfig.vapidKey
          : null,
    );
    if (token != null) {
      await _saveToken(token);
    }
  }

  Future<void> _saveToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set(
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> removeTokenForCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken(
      vapidKey: kIsWeb && FirebaseConfig.vapidKey.isNotEmpty
          ? FirebaseConfig.vapidKey
          : null,
    );
    if (token == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }

  Future<void> _setupLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );

    const channel = AndroidNotificationChannel(
      'squadboard',
      'SquadBoard',
      description: 'Team chat and ticket updates',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _showForegroundNotification(RemoteMessage message, WidgetRef ref) {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] as String? ?? 'SquadBoard';
    final body = notification?.body ?? message.data['body'] as String? ?? '';

    if (!kIsWeb) {
      _localNotifications.show(
        notification.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'squadboard',
            'SquadBoard',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }

    ref.read(pushBannerProvider.notifier).state = PushBanner(
      title: title,
      body: body,
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background data handled by firebase-messaging-sw.js on web.
}
