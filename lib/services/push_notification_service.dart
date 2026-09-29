import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase_options.dart';
import '../helper_class/api_service_class.dart';
import '../models/user_model.dart';

typedef NotificationTapHandler = void Function(Map<String, dynamic> data);

const String _notificationChannelId = 'yunusco_notifications';
const String _notificationChannelName = 'Yunusco notifications';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationService.showBackgroundNotification(message);
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _api = ApiService();

  NotificationTapHandler? _onNotificationTap;
  UserModel? _signedInUser;
  bool _initialized = false;

  Future<void> initialize({
    required NotificationTapHandler onNotificationTap,
  }) async {
    if (_initialized) return;
    _onNotificationTap = onNotificationTap;

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        _handleLocalNotificationTap(response.payload);
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _notificationChannelId,
            _notificationChannelName,
            description: 'Updates and important activity from Yunusco.',
            importance: Importance.high,
          ),
        );

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteNotificationTap);
    _messaging.onTokenRefresh.listen(
      (token) => unawaited(_handleTokenRefresh(token)),
      onError: (Object error) {
        debugPrint('FCM token refresh listener failed: $error');
      },
    );

    final initialRemoteMessage = await _messaging.getInitialMessage();
    if (initialRemoteMessage != null) {
      _handleRemoteNotificationTap(initialRemoteMessage);
    }

    final localLaunchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    final localPayload = localLaunchDetails?.notificationResponse?.payload;
    if (localLaunchDetails?.didNotificationLaunchApp == true) {
      _handleLocalNotificationTap(localPayload);
    }

    _initialized = true;
  }

  Future<void> requestPermissionAndRegister(UserModel user) async {
    _signedInUser = null;
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    final isAllowed =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!isAllowed) {
      debugPrint('Push notifications are not authorized for this device.');
      return;
    }

    _signedInUser = user;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _waitForApnsToken();
    }
    final token = await _messaging.getToken();
    debugPrint('FCM token: $token');
    if (token == null || token.isEmpty) {
      debugPrint('FCM did not provide a device token.');
      return;
    }
    await _registerToken(user, token);
  }

  Future<void> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      if (await _messaging.getAPNSToken() != null) return;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    throw StateError('APNs did not provide a device token.');
  }

  Future<void> _handleTokenRefresh(String token) async {
    final user = _signedInUser;
    if (user == null) return;
    try {
      await _registerToken(user, token);
    } catch (error) {
      debugPrint('Could not register the refreshed FCM token: $error');
    }
  }

  Future<void> _registerToken(UserModel user, String token) async {
    final userId = user.userId;
    final roleId = user.roleId;
    if (userId == null || roleId == null) {
      throw StateError(
        'Cannot register an FCM token without user and role IDs.',
      );
    }

    final response = await _api.post('api/user/CheckDeviceToken', {
      'roleId': roleId,
      'FirebaseDeviceToken': token,
      'Userid': userId,
    });
    final statusCode = response?.statusCode;
    if (statusCode == null || statusCode < 200 || statusCode >= 300) {
      throw StateError(
        'FCM token registration failed (HTTP ${statusCode ?? 'no response'}).',
      );
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      unawaited(_showLocalNotification(message));
    }
  }

  void _handleRemoteNotificationTap(RemoteMessage message) {
    _onNotificationTap?.call(message.data);
  }

  void _handleLocalNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) {
      _onNotificationTap?.call(const {});
      return;
    }
    final decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) {
      _onNotificationTap?.call(decoded);
    } else {
      debugPrint('Ignoring a notification payload that is not a data map.');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      debugPrint('Ignoring an FCM message without a title or body.');
      return;
    }

    await _localNotifications.show(
      id: _notificationId(message),
      title: title ?? 'Accessories',
      body: body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,
          channelDescription: 'Updates and important activity from Yunusco.',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_notification',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> showBackgroundNotification(RemoteMessage message) async {
    if (message.notification != null) return;

    final title = message.data['title']?.toString();
    final body = message.data['body']?.toString();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      debugPrint('Ignoring a background FCM message without display text.');
      return;
    }

    final notifications = FlutterLocalNotificationsPlugin();
    await notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    await notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _notificationChannelId,
            _notificationChannelName,
            description: 'Updates and important activity from Yunusco.',
            importance: Importance.high,
          ),
        );
    await notifications.show(
      id: _notificationId(message),
      title: title ?? 'Accessories',
      body: body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannelId,
          _notificationChannelName,
          channelDescription: 'Updates and important activity from Yunusco.',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_notification',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }
}

int _notificationId(RemoteMessage message) {
  final id =
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch;
  return id & 0x7fffffff;
}

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService.instance,
);
