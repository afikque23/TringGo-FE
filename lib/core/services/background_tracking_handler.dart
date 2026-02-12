import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'location_service.dart';
import '../model/location_point.dart';

/// Handler untuk background tracking menggunakan foreground service
@pragma('vm:entry-point')
class BackgroundTrackingHandler extends TaskHandler {
  final LocationService _locationService = LocationService();
  StreamSubscription<LocationPoint>? _locationSubscription;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('Background tracking started at $timestamp');

    // Start location updates
    final started = await _locationService.startLocationUpdates();

    if (started) {
      // Listen to location updates
      _locationSubscription = _locationService.locationStream.listen((
        location,
      ) {
        // Send location data back to main isolate
        FlutterForegroundTask.sendDataToMain({
          'type': 'location',
          'latitude': location.latitude,
          'longitude': location.longitude,
          'speed': location.speed,
          'accuracy': location.accuracy,
          'timestamp': location.timestamp.toIso8601String(),
        });
      });
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This will be called every interval
    // Update notification with current stats
    FlutterForegroundTask.updateService(
      notificationTitle: 'GPS Tracking Aktif',
      notificationText: 'Perjalanan sedang direkam',
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('Background tracking stopped at $timestamp');
    _locationSubscription?.cancel();
    _locationService.stopLocationUpdates();
  }

  @override
  void onReceiveData(Object data) {
    // Receive data from main isolate
    if (data is Map<String, dynamic>) {
      if (data['action'] == 'updateStats') {
        // Update notification with stats
        final distance = data['distance'] as double?;
        final duration = data['duration'] as String?;

        if (distance != null && duration != null) {
          FlutterForegroundTask.updateService(
            notificationTitle: 'GPS Tracking Aktif',
            notificationText: '${distance.toStringAsFixed(2)} km • $duration',
          );
        }
      }
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Handle notification button press
    if (id == 'stop') {
      FlutterForegroundTask.sendDataToMain({'type': 'stopRequest'});
    }
  }

  @override
  void onNotificationPressed() {
    // Handle notification tap - bring app to foreground
    FlutterForegroundTask.launchApp('/tracking');
  }
}

/// Helper class untuk manage background tracking
class BackgroundTrackingManager {
  static final BackgroundTrackingManager _instance =
      BackgroundTrackingManager._internal();
  factory BackgroundTrackingManager() => _instance;
  BackgroundTrackingManager._internal();

  bool _isInitialized = false;

  /// Initialize foreground task
  Future<void> initialize() async {
    if (_isInitialized) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'motorcycle_gps_tracking',
        channelName: 'GPS Tracking',
        channelDescription: 'Notification untuk GPS tracking perjalanan motor',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          5000,
        ), // Update every 5 seconds
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );

    _isInitialized = true;
  }

  /// Start foreground service untuk background tracking
  Future<bool> startBackgroundTracking() async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check if already running
    if (await FlutterForegroundTask.isRunningService) {
      return true;
    }

    // Request notification permission for Android 13+
    if (await FlutterForegroundTask.isIgnoringBatteryOptimizations == false) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Start foreground service
    await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'GPS Tracking Aktif',
      notificationText: 'Memulai tracking...',
      callback: startCallback,
    );

    // Verify service started
    return await FlutterForegroundTask.isRunningService;
  }

  /// Stop foreground service
  Future<bool> stopBackgroundTracking() async {
    await FlutterForegroundTask.stopService();
    // Verify service stopped
    return !(await FlutterForegroundTask.isRunningService);
  }

  /// Update notification dengan stats terbaru
  Future<void> updateStats({
    required double distance,
    required String duration,
  }) async {
    if (await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.sendDataToTask({
        'action': 'updateStats',
        'distance': distance,
        'duration': duration,
      });
    }
  }

  /// Callback untuk data dari background task
  void Function(Object)? _taskDataCallback;

  /// Listen untuk data dari background task
  void listenToBackgroundData(Function(Map<String, dynamic>) onData) {
    // Setup receive port untuk menerima data dari background
    _taskDataCallback = (data) {
      if (data is Map<String, dynamic>) {
        onData(data);
      }
    };
    FlutterForegroundTask.addTaskDataCallback(_taskDataCallback!);
  }

  /// Stop listening
  void stopListening() {
    if (_taskDataCallback != null) {
      FlutterForegroundTask.removeTaskDataCallback(_taskDataCallback!);
      _taskDataCallback = null;
    }
  }

  /// Dispose resources
  void dispose() {
    stopListening();
  }
}

/// Callback untuk start foreground service
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(BackgroundTrackingHandler());
}
