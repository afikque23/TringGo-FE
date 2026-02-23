import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'device_token_service.dart';
import 'auth_storage.dart';

/// Background message handler (harus top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
  // Jangan lakukan heavy operation di sini
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  // Lazy initialization untuk Firebase Messaging
  FirebaseMessaging? _messagingInstance;
  FirebaseMessaging get _messaging {
    _messagingInstance ??= FirebaseMessaging.instance;
    return _messagingInstance!;
  }

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize semua notification service
  Future<void> initialize() async {
    try {
      // 1. Request permission
      await _requestPermission();

      // 2. Setup local notifications (untuk custom display)
      await _setupLocalNotifications();

      // 3. Setup FCM handlers
      _setupFCMHandlers();

      // 4. Enable foreground notification presentation (PENTING!)
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true, // Show notification pop-up
        badge: true, // Update badge count
        sound: true, // Play notification sound
      );
      print('✅ Foreground notification presentation enabled');

      // 5. Get FCM token (but don't register yet - wait for login)
      final token = await _messaging.getToken();
      if (token != null) {
        print('FCM Token obtained: ${token.substring(0, 20)}...');
        // Save locally for later registration after login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
      }

      // 6. Listen token refresh (only register if user is logged in)
      _messaging.onTokenRefresh.listen((newToken) async {
        print('🔄 FCM Token refreshed');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', newToken);

        // Only register if user is logged in
        final authStorage = AuthStorage();
        final isLoggedIn = await authStorage.isLoggedIn();
        if (isLoggedIn) {
          await _registerFCMToken(token: newToken);
        } else {
          print('⏸️ Token refresh skipped - user not logged in');
        }
      });

      print('✅ NotificationService initialized successfully');
    } catch (e) {
      print('❌ Error initializing NotificationService: $e');
      // Don't throw, let the app continue without notifications
    }
  }

  /// Request notification permission (iOS & Android 13+)
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );
      print('Permission status: ${settings.authorizationStatus}');
    } catch (e) {
      print('⚠️ Error requesting permission: $e');
    }
  }

  /// Setup local notification channels
  Future<void> _setupLocalNotifications() async {
    try {
      // Request Android 13+ notification permission for local notifications
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final permissionGranted = await androidPlugin
            .requestNotificationsPermission();
        print('📱 Local notification permission granted: $permissionGranted');

        // DELETE OLD CHANNELS (untuk fix cached importance level)
        try {
          await androidPlugin.deleteNotificationChannel('mototracker_default');
          await androidPlugin.deleteNotificationChannel('mototracker_service');
          await androidPlugin.deleteNotificationChannel('mototracker_trip');
          await androidPlugin.deleteNotificationChannel('mototracker_alert');
          await androidPlugin.deleteNotificationChannel('mototracker_insight');
          print('🗑️ Old notification channels deleted');
        } catch (e) {
          print('⚠️ Error deleting old channels (might not exist): $e');
        }
      }

      // Android channels dengan importance levels berbeda

      // DEFAULT: High importance - general notifications
      const AndroidNotificationChannel defaultChannel =
          AndroidNotificationChannel(
            'mototracker_default',
            'Default Notifications',
            description: 'General notifications',
            importance: Importance.high,
            playSound: true,
            showBadge: true,
            enableVibration: true,
          );

      // SERVICE: High importance - service reminders, pop-up + sound
      const AndroidNotificationChannel serviceChannel =
          AndroidNotificationChannel(
            'mototracker_service',
            'Service Reminders',
            description: 'Service and maintenance reminders',
            importance: Importance.high,
            playSound: true,
            showBadge: true,
            enableVibration: true,
          );

      // TRIP: High importance - trip completed, pop-up + sound
      const AndroidNotificationChannel tripChannel = AndroidNotificationChannel(
        'mototracker_trip',
        'Trip Notifications',
        description: 'Trip tracking and completion notifications',
        importance: Importance.high,
        playSound: true,
        showBadge: true,
        enableVibration: true,
      );

      // ALERT: Max importance - critical alerts, pop-up with loud sound
      const AndroidNotificationChannel alertChannel =
          AndroidNotificationChannel(
            'mototracker_alert',
            'Alert Notifications',
            description: 'Critical alerts and warnings',
            importance: Importance.max,
            playSound: true,
            showBadge: true,
            enableVibration: true,
          );

      // INSIGHT: Low importance - tips and insights, no pop-up, no sound
      const AndroidNotificationChannel insightChannel =
          AndroidNotificationChannel(
            'mototracker_insight',
            'Insights & Tips',
            description: 'Riding insights and tips',
            importance: Importance.low,
            playSound: false,
            showBadge: true,
            enableVibration: false,
          );

      // Create all channels
      await androidPlugin?.createNotificationChannel(defaultChannel);
      await androidPlugin?.createNotificationChannel(serviceChannel);
      await androidPlugin?.createNotificationChannel(tripChannel);
      await androidPlugin?.createNotificationChannel(alertChannel);
      await androidPlugin?.createNotificationChannel(insightChannel);

      print(
        '✅ Created 5 notification channels: default, service, trip, alert, insight',
      );

      // Initialize plugin
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          _handleNotificationTap(details.payload);
        },
      );
    } catch (e) {
      print('⚠️ Error setting up local notifications: $e');
    }
  }

  /// Setup FCM message handlers
  void _setupFCMHandlers() {
    try {
      // Foreground messages (app sedang terbuka)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('🔔 FOREGROUND NOTIFICATION RECEIVED!');
        print('Message ID: ${message.messageId}');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        _showLocalNotification(message);
      });

      // Notification opened from terminated state
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          print('📬 App opened from terminated state notification');
          _handleNotificationData(message.data);
        }
      });

      // Notification opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📬 Notification opened from background: ${message.messageId}');
        _handleNotificationData(message.data);
      });

      print('✅ FCM handlers setup successfully');
    } catch (e) {
      print('⚠️ Error setting up FCM handlers: $e');
    }
  }

  /// Tampilkan notifikasi lokal saat app di foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      print('🔔 Showing local notification...');

      final notification = message.notification;
      final android = message.notification?.android;
      final data = message.data;

      // Check if we have notification payload
      String? title = notification?.title;
      String? body = notification?.body;

      // Fallback: Ambil dari data jika notification null (untuk data-only messages)
      if (title == null || body == null) {
        title = data['title'] ?? 'MotoTracker';
        body = data['body'] ?? 'New notification';
        print('⚠️ Using title/body from data payload');
      }

      final categoryKey = data['category_key'] ?? 'default';

      // CRITICAL FIX: ALWAYS use default channel for heads-up notifications
      // Karena channel spesifik (trip, service, etc) sering di-suppress oleh Android
      final channelId = 'mototracker_default'; // FORCE use default channel

      // Log original category for debugging
      if (categoryKey != 'default') {
        print('⚠️ Using default channel instead of: mototracker_$categoryKey');
      }

      print('📢 Title: $title');
      print('📢 Body: $body');
      print('📢 Channel: $channelId (FORCED DEFAULT)');
      print('📢 Category: $categoryKey');

      // Get importance and priority based on category
      // ALWAYS use HIGH for heads-up notifications
      final importance = Importance.max; // FORCE MAX importance
      final priority = Priority.max; // FORCE MAX priority
      final playSound = true; // ALWAYS play sound
      final enableVibration = true; // ALWAYS vibrate

      print(
        '🎯 Importance: FORCED MAX (was: ${_getImportanceForCategory(categoryKey)})',
      );
      print(
        '🎯 Priority: FORCED MAX (was: ${_getPriorityForCategory(categoryKey)})',
      );

      // Generate unique notification ID
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
        100000,
      );

      await _localNotifications.show(
        notificationId,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Default Notifications', // FORCE use default channel name
            channelDescription: 'MotoTracker notifications',
            importance: importance,
            priority: priority,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            showWhen: true,
            enableVibration: enableVibration,
            playSound: playSound,
            // CRITICAL: Set visibility to PUBLIC for heads-up
            visibility: NotificationVisibility.public,
            // CRITICAL: Use CALL category for MAXIMUM priority (always heads-up)
            category: AndroidNotificationCategory.call,
            // FORCE heads-up notification
            ticker: title, // Show in status bar immediately
            autoCancel: true, // Dismiss when tapped
            ongoing: false, // Not persistent
            // CRITICAL: Full screen intent untuk FORCE heads-up notification
            fullScreenIntent: true,
            // Styling
            styleInformation: BigTextStyleInformation(
              body ?? '',
              contentTitle: title,
              summaryText: 'MotoTracker',
            ),
            // LED and vibration for extra attention
            ledColor: const Color.fromARGB(255, 255, 0, 0),
            ledOnMs: 1000,
            ledOffMs: 500,
            vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(data),
      );

      print(
        '✅ Local notification displayed successfully (ID: $notificationId)',
      );
    } catch (e, stackTrace) {
      print('❌ Error showing local notification: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Get channel ID berdasarkan category
  String _getChannelId(String categoryKey) {
    switch (categoryKey) {
      case 'service':
        return 'mototracker_service';
      case 'trip':
        return 'mototracker_trip';
      case 'alert':
        return 'mototracker_alert';
      case 'insight':
        return 'mototracker_insight';
      default:
        return 'mototracker_default';
    }
  }

  /// Get channel name berdasarkan category
  String _getChannelName(String categoryKey) {
    switch (categoryKey) {
      case 'service':
        return 'Service Reminders';
      case 'trip':
        return 'Trip Notifications';
      case 'alert':
        return 'Alert Notifications';
      case 'insight':
        return 'Insights & Tips';
      default:
        return 'Default Notifications';
    }
  }

  /// Get importance level berdasarkan category
  /// Mapping sesuai backend: service/trip = high, alert = max, insight = low
  Importance _getImportanceForCategory(String categoryKey) {
    switch (categoryKey) {
      case 'alert':
        return Importance.max; // Critical alerts - pop-up with loud sound
      case 'service':
      case 'trip':
        return Importance.high; // Important - pop-up with sound
      case 'insight':
        return Importance.low; // Low priority - no pop-up, no sound
      default:
        return Importance.high; // Default to high
    }
  }

  /// Get priority level berdasarkan category
  Priority _getPriorityForCategory(String categoryKey) {
    switch (categoryKey) {
      case 'alert':
        return Priority.max; // Critical alerts
      case 'service':
      case 'trip':
        return Priority.high; // Important notifications
      case 'insight':
        return Priority.low; // Low priority
      default:
        return Priority.high; // Default to high
    }
  }

  /// Handle tap notification
  void _handleNotificationTap(String? payload) {
    if (payload == null) return;
    final data = jsonDecode(payload) as Map<String, dynamic>;
    _handleNotificationData(data);
  }

  /// Navigate berdasarkan data notifikasi
  void _handleNotificationData(Map<String, dynamic> data) {
    final notificationId = data['notification_id'];
    final categoryKey = data['category_key'];
    final vehicleId = data['vehicle_id'];

    // TODO: Implement navigation logic
    // Contoh:
    // if (categoryKey == 'service' && vehicleId != null) {
    //   navigatorKey.currentState?.pushNamed('/vehicle-detail', arguments: vehicleId);
    // }

    print(
      'Navigate: category=$categoryKey, notification=$notificationId, vehicle=$vehicleId',
    );
  }

  /// Register FCM token ke backend
  Future<void> _registerFCMToken({String? token}) async {
    try {
      token ??= await _messaging.getToken();
      if (token == null) {
        print('FCM Token is null');
        return;
      }

      final success = await DeviceTokenService.register(token);
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
      }
      print('FCM Token registered: ${token.substring(0, 20)}...');
    } catch (e) {
      print('❌ Error registering FCM token: $e');
      // Continue without crashing
    }
  }

  /// Unregister FCM token (saat logout)
  Future<void> unregisterToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('fcm_token');
    if (token != null) {
      await DeviceTokenService.unregister(token);
      await prefs.remove('fcm_token');
    }
  }

  /// Register FCM token setelah login berhasil
  /// Method ini harus dipanggil setelah user berhasil login
  Future<void> registerTokenAfterLogin() async {
    try {
      print('📱 Registering FCM token after login...');

      // Check if user is logged in
      final authStorage = AuthStorage();
      final isLoggedIn = await authStorage.isLoggedIn();

      if (!isLoggedIn) {
        print('⚠️ Cannot register FCM token - user not logged in');
        return;
      }

      // Get token from SharedPreferences or Firebase
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('fcm_token');

      // If not cached, get fresh token from Firebase
      if (token == null) {
        token = await _messaging.getToken();
        if (token != null) {
          await prefs.setString('fcm_token', token);
        }
      }

      if (token == null) {
        print('❌ FCM token is null - cannot register');
        return;
      }

      // Register to backend with authentication
      final success = await DeviceTokenService.register(token);
      if (success) {
        print('✅ FCM token registered successfully after login');
      } else {
        print('⚠️ Failed to register FCM token to backend');
      }
    } catch (e) {
      print('❌ Error registering FCM token after login: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }
}
