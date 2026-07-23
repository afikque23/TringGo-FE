import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'device_token_service.dart';
import 'auth_storage.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
  
  // Jika ini data-only message (tidak ada object notification dari FCM backend),
  // kita harus memunculkan notifikasinya secara manual agar bisa menggunakan fullScreenIntent
  if (message.notification == null) {
    print('Processing Data-Only message in background to wake screen...');
    final localNotifications = FlutterLocalNotificationsPlugin();
    
    final data = message.data;
    final title = data['title'] ?? 'TringGo';
    final body = data['body'] ?? 'Anda mendapat peringatan baru';
    final categoryKey = data['category_key'] ?? 'default';

    String channelId = 'tringgo_default_v5';
    String channelName = 'Default Notifications';
    Importance importance = Importance.high;
    Priority priority = Priority.high;
    bool playSound = true;
    bool enableVibration = true;

    if (categoryKey == 'alert') {
      channelId = 'tringgo_alert_v5';
      channelName = 'Alert Notifications';
      importance = Importance.max;
      priority = Priority.max;
    } else if (categoryKey == 'service' || categoryKey == 'trip') {
      channelId = 'tringgo_${categoryKey}_v5';
      channelName = categoryKey == 'service' ? 'Service Reminders' : 'Trip Notifications';
    } else if (categoryKey == 'insight') {
      channelId = 'tringgo_insight_v5';
      channelName = 'Insights & Tips';
      importance = Importance.low;
      priority = Priority.low;
      playSound = false;
      enableVibration = false;
    }

    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: importance,
          priority: priority,
          fullScreenIntent: true, // INI YANG MEMAKSA LAYAR MENYALA
          playSound: playSound,
          sound: playSound ? const RawResourceAndroidNotificationSound('sound_tringgo') : null,
          enableVibration: enableVibration,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(data),
    );
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _initialized = false;
  bool _fcmHandlersSetup = false;

  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;
  StreamSubscription<String>? _onTokenRefreshSubscription;

  // Lazy initialization untuk Firebase Messaging
  FirebaseMessaging? _messagingInstance;
  FirebaseMessaging get _messaging {
    _messagingInstance ??= FirebaseMessaging.instance;
    return _messagingInstance!;
  }

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize semua notification service
  Future<void> initialize({bool forceReinitialize = false}) async {
    try {
      if (_initialized && !forceReinitialize) {
        print('ℹ️ NotificationService already initialized (skipped)');
        return;
      }

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
      _onTokenRefreshSubscription ??= _messaging.onTokenRefresh.listen((
        newToken,
      ) async {
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
      _initialized = true;
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
        // NOTE: Android tidak bisa mengubah sound untuk channel yang sudah ada.
        // Solusi paling aman adalah pakai ID baru (v2) + delete channel lama.
        try {
          await androidPlugin.deleteNotificationChannel('tringgo_default');
          await androidPlugin.deleteNotificationChannel('tringgo_service');
          await androidPlugin.deleteNotificationChannel('tringgo_trip');
          await androidPlugin.deleteNotificationChannel('tringgo_alert');
          await androidPlugin.deleteNotificationChannel('tringgo_insight');
          await androidPlugin.deleteNotificationChannel('tringgo_default_v2');
          await androidPlugin.deleteNotificationChannel('tringgo_service_v2');
          await androidPlugin.deleteNotificationChannel('tringgo_trip_v2');
          await androidPlugin.deleteNotificationChannel('tringgo_alert_v2');
          await androidPlugin.deleteNotificationChannel('tringgo_insight_v2');
          print('🗑️ Old notification channels deleted');
        } catch (e) {
          print('⚠️ Error deleting old channels (might not exist): $e');
        }
      }

      // Android channels dengan importance levels berbeda
      const AndroidNotificationSound tringSound =
          RawResourceAndroidNotificationSound('sound_tringgo');

      // DEFAULT: High importance - general notifications
      final AndroidNotificationChannel defaultChannel =
          AndroidNotificationChannel(
            'tringgo_default_v5',
            'Default Notifications',
            description: 'General notifications',
            importance: Importance.high,
            playSound: true,
            sound: tringSound,
            showBadge: true,
            enableVibration: true,
          );

      // SERVICE: High importance - service reminders, pop-up + sound
      final AndroidNotificationChannel serviceChannel =
          AndroidNotificationChannel(
            'tringgo_service_v5',
            'Service Reminders',
            description: 'Service and maintenance reminders',
            importance: Importance.high,
            playSound: true,
            sound: tringSound,
            showBadge: true,
            enableVibration: true,
          );

      // TRIP: High importance - trip completed, pop-up + sound
      final AndroidNotificationChannel tripChannel = AndroidNotificationChannel(
        'tringgo_trip_v5',
        'Trip Notifications',
        description: 'Trip tracking and completion notifications',
        importance: Importance.high,
        playSound: true,
        sound: tringSound,
        showBadge: true,
        enableVibration: true,
      );

      // ALERT: Max importance - critical alerts, pop-up with loud sound
      final AndroidNotificationChannel alertChannel =
          AndroidNotificationChannel(
            'tringgo_alert_v5',
            'Alert Notifications',
            description: 'Critical alerts and warnings',
            importance: Importance.max,
            playSound: true,
            sound: tringSound,
            showBadge: true,
            enableVibration: true,
          );

      // INSIGHT: Low importance - tips and insights, no pop-up, no sound
      const AndroidNotificationChannel insightChannel =
          AndroidNotificationChannel(
            'tringgo_insight_v5',
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
      if (_fcmHandlersSetup) {
        return;
      }

      // Foreground messages (app sedang terbuka)
      _onMessageSubscription ??= FirebaseMessaging.onMessage.listen((
        RemoteMessage message,
      ) {
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
      _onMessageOpenedAppSubscription ??= FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) {
            print(
              '📬 Notification opened from background: ${message.messageId}',
            );
            _handleNotificationData(message.data);
          });

      print('✅ FCM handlers setup successfully');
      _fcmHandlersSetup = true;
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
        title = data['title'] ?? 'TringGo';
        body = data['body'] ?? 'New notification';
        print('⚠️ Using title/body from data payload');
      }

      final categoryKey = data['category_key'] ?? 'default';

      final channelId = _getChannelId(categoryKey);
      final channelName = _getChannelName(categoryKey);
      final importance = _getImportanceForCategory(categoryKey);
      final priority = _getPriorityForCategory(categoryKey);

      final playSound = categoryKey != 'insight';
      final enableVibration = categoryKey != 'insight';
      final AndroidNotificationSound? sound = playSound
          ? RawResourceAndroidNotificationSound('sound_tringgo')
          : null;

      print('📢 Title: $title');
      print('📢 Body: $body');
      print('📢 Channel: $channelId');
      print('📢 Category: $categoryKey');

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
            channelName,
            channelDescription: 'TringGo notifications',
            importance: importance,
            priority: priority,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            showWhen: true,
            fullScreenIntent: true, // INI YANG MEMAKSA LAYAR MENYALA
            enableVibration: enableVibration,
            vibrationPattern: enableVibration
                ? Int64List.fromList([0, 250, 250, 250])
                : null,
            playSound: playSound,
            sound: sound,
            autoCancel: true,
            styleInformation: BigTextStyleInformation(
              body ?? '',
              contentTitle: title,
              summaryText: 'TringGo',
            ),
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
  // ignore: unused_element
  String _getChannelId(String categoryKey) {
    switch (categoryKey) {
      case 'service':
        return 'tringgo_service_v5';
      case 'trip':
        return 'tringgo_trip_v5';
      case 'alert':
        return 'tringgo_alert_v5';
      case 'insight':
        return 'tringgo_insight_v5';
      default:
        return 'tringgo_default_v5';
    }
  }

  /// Get channel name berdasarkan category
  // ignore: unused_element
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

  /// Debug helper: show a local notification immediately.
  /// Useful to verify channel + permission setup (independent of FCM delivery).
  Future<void> showTestLocalNotification() async {
    try {
      // Ensure plugin + channels are ready
      if (!_initialized) {
        await initialize();
      }

      await _localNotifications.show(
        99999,
        '🧪 Test Local Notification',
        'Jika Anda melihat notifikasi ini, berarti local notification BERFUNGSI!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tringgo_default_v5',
            'Default Notifications',
            channelDescription: 'Test notification channel',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'Test',
          ),
        ),
      );
    } catch (e) {
      print('❌ Error showing test local notification: $e');
      rethrow;
    }
  }
}
