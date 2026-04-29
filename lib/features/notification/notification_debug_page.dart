import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/device_token_service.dart';
import '../../core/services/notification_api_service.dart';

/// Debug page untuk check FCM status dan test notifications
class NotificationDebugPage extends StatefulWidget {
  const NotificationDebugPage({super.key});

  @override
  State<NotificationDebugPage> createState() => _NotificationDebugPageState();
}

class _NotificationDebugPageState extends State<NotificationDebugPage> {
  String? _fcmToken;
  Map<String, dynamic>? _deviceStatus;
  bool _isLoading = false;
  String _statusMessage = 'Tap untuk check status';

  @override
  void initState() {
    super.initState();
    // Load FCM token setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFCMToken();
    });
  }

  Future<void> _loadFCMToken() async {
    try {
      final token = await NotificationService.instance.getToken();
      if (mounted) {
        setState(() {
          _fcmToken = token;
        });
      }
    } catch (e) {
      print('⚠️ Error loading FCM token: $e');
      if (mounted) {
        setState(() {
          _fcmToken = 'Error: $e';
        });
      }
    }
  }

  Future<void> _checkDeviceStatus() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Mengecek status...';
    });

    try {
      final status = await DeviceTokenService.getStatus();
      setState(() {
        _deviceStatus = status;
        _isLoading = false;
        _statusMessage = 'Status berhasil diambil';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _testNotificationAPI() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing API...';
    });

    try {
      final result = await NotificationApiService.getNotifications(perPage: 5);
      final notifications = result['data']?['data'] ?? [];
      final unreadCount = result['data']?['unread_count'] ?? 0;

      setState(() {
        _isLoading = false;
        _statusMessage =
            '✅ API OK: ${notifications.length} notifications, $unreadCount unread';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ API Error: $e';
      });
    }
  }

  Future<void> _refreshFCMToken() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '🔄 Refreshing FCM token...';
    });

    try {
      // Import firebase_messaging di atas
      final FirebaseMessaging messaging = FirebaseMessaging.instance;

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔄 REFRESHING FCM TOKEN');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // 1. Delete old token from Firebase
      print('1️⃣ Deleting old FCM token...');
      await messaging.deleteToken();
      print('✅ Old token deleted');

      // 2. Get new token
      print('2️⃣ Getting new FCM token...');
      final newToken = await messaging.getToken();
      print('✅ New token: ${newToken?.substring(0, 30)}...');

      if (newToken != null) {
        // 3. Register to backend
        print('3️⃣ Registering to backend...');
        final success = await DeviceTokenService.register(newToken);

        if (success) {
          print('✅ Token registered to backend successfully');
          setState(() {
            _fcmToken = newToken;
            _isLoading = false;
            _statusMessage =
                '✅ Token refreshed successfully! New token: ${newToken.substring(0, 30)}...';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ FCM Token refreshed and registered!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('❌ Failed to register to backend');
          setState(() {
            _fcmToken = newToken;
            _isLoading = false;
            _statusMessage =
                '⚠️ Token refreshed but backend registration failed';
          });
        }
      } else {
        print('❌ Failed to get new token');
        setState(() {
          _isLoading = false;
          _statusMessage = '❌ Failed to get new FCM token';
        });
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e) {
      print('❌ Error refreshing token: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  Future<void> _recreateNotificationChannels() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '🔧 Recreating notification channels...';
    });

    try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔧 RECREATING NOTIFICATION CHANNELS');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Reinitialize notification service to recreate channels
      await NotificationService.instance.initialize(forceReinitialize: true);

      setState(() {
        _isLoading = false;
        _statusMessage =
            '✅ Notification channels recreated! Restart app untuk apply changes.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Channels recreated! Restart app sekarang.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );

      print('✅ Notification channels recreated successfully');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e) {
      print('❌ Error recreating channels: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  Future<void> _openNotificationSettings() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '📱 Opening notification settings...';
    });

    try {
      print('📱 Opening app notification settings...');
      // Open app settings where user can check notification settings
      final opened = await Geolocator.openAppSettings();

      setState(() {
        _isLoading = false;
        _statusMessage = opened
            ? '✅ Settings opened! Check "Notifications" section'
            : '❌ Failed to open settings';
      });

      if (opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '📱 Check notification settings:\n1. Enable all notifications\n2. Enable "Pop on screen"\n3. Enable sound',
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('❌ Error opening settings: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error: $e';
      });
    }
  }

  Future<void> _testLocalNotification() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Sending test local notification...';
    });

    try {
      await NotificationService.instance.showTestLocalNotification();

      setState(() {
        _isLoading = false;
        _statusMessage =
            '✅ Test sent! Check notification tray. Jika muncul, FCM handler yang bermasalah.';
      });

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🧪 TEST LOCAL NOTIFICATION SENT');
      print('Jika pop-up muncul: Local notification OK ✅');
      print('Jika tidak muncul: Permission/channel issue ❌');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Local notification error: $e';
      });
      print('❌ Error sending test notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Debug'),
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FCM Token Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🔥 FCM Token',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (_fcmToken != null)
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: _fcmToken!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Token copied to clipboard'),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_fcmToken == null)
                      const Text('Loading...')
                    else
                      SelectableText(
                        _fcmToken!,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Message
            Card(
              color: _statusMessage.contains('❌')
                  ? colorScheme.errorContainer
                  : _statusMessage.contains('✅')
                  ? Colors.green.shade100
                  : colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        _statusMessage.contains('❌')
                            ? Icons.error_outline
                            : _statusMessage.contains('✅')
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        color: _statusMessage.contains('❌')
                            ? colorScheme.error
                            : _statusMessage.contains('✅')
                            ? Colors.green
                            : colorScheme.primary,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Device Status
            if (_deviceStatus != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📱 Device Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'Registered Devices',
                        _deviceStatus!['registered_devices'].toString(),
                      ),
                      const Divider(),
                      if (_deviceStatus!['devices'] != null)
                        ...(_deviceStatus!['devices'] as List).map((device) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(
                                  'Type',
                                  device['device_type'] ?? 'N/A',
                                ),
                                _buildInfoRow(
                                  'Active',
                                  device['is_active'] ? '✅ Yes' : '❌ No',
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testLocalNotification,
                icon: const Icon(Icons.notification_add),
                label: const Text('🧪 Test Local Notification'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _checkDeviceStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Check Device Status'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testNotificationAPI,
                icon: const Icon(Icons.api),
                label: const Text('Test Notification API'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _refreshFCMToken,
                icon: const Icon(Icons.refresh),
                label: const Text('🔄 Refresh FCM Token'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _recreateNotificationChannels,
                icon: const Icon(Icons.settings_backup_restore),
                label: const Text('🔧 Recreate Notification Channels'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _openNotificationSettings,
                icon: const Icon(Icons.settings),
                label: const Text('📱 Open Notification Settings'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.blue.shade700, width: 2),
                  foregroundColor: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '⚠️ Pop-up Tidak Muncul? WAJIB Coba!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep(
                      '1',
                      'Tap "📱 Open Notification Settings" (button biru)',
                      color: Colors.red.shade700,
                    ),
                    _buildInstructionStep(
                      '2',
                      'Di HP settings, cari "Notifications" atau "Default Notifications"',
                      color: Colors.red.shade700,
                    ),
                    _buildInstructionStep(
                      '3',
                      'Enable: "Pop on screen" / "Heads-up" / "Banner style"',
                      color: Colors.red.shade700,
                    ),
                    _buildInstructionStep(
                      '4',
                      'Enable: Sound dan Vibration',
                      color: Colors.red.shade700,
                    ),
                    _buildInstructionStep(
                      '5',
                      'Back ke app, test update odometer lagi!',
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '💡 PENTING: Android sering otomatis suppress notification dari app yang jarang dipakai. Pastikan "Pop on screen" atau "Banner" ENABLED di notification settings!',
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Alternative fix
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Alternative: Recreate Channels',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep(
                      '1',
                      'Tap "🔧 Recreate Notification Channels" (button merah)',
                      color: Colors.orange.shade700,
                    ),
                    _buildInstructionStep(
                      '2',
                      'Tunggu "✅ Channels recreated"',
                      color: Colors.orange.shade700,
                    ),
                    _buildInstructionStep(
                      '3',
                      'RESTART app (swipe close & buka lagi)',
                      color: Colors.orange.shade700,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Instructions
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.science_outlined,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Test Notifikasi Manual',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap "🧪 Test Local Notification" untuk test apakah notification system berfungsi.',
                      style: TextStyle(color: Colors.green.shade900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Jika pop-up muncul: ✅ Local notification OK',
                      style: TextStyle(color: Colors.green.shade900),
                    ),
                    Text(
                      '• Jika tidak muncul: ❌ Check permission di settings',
                      style: TextStyle(color: Colors.green.shade900),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, {Color? color}) {
    final circleColor = color ?? Colors.blue.shade700;
    final textColor = color ?? Colors.blue.shade900;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }
}
