import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/notification_api_service.dart';
import '../../core/services/notification_service.dart';
import 'notification_debug_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _selectedFilter = 'all';
  int? _openedIndex;
  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _notifications = [];
  List<dynamic> _categories = [];
  int _unreadCount = 0;

  List<dynamic> get _filteredNotifications {
    if (_selectedFilter == 'all') {
      return _notifications;
    }
    return _notifications
        .where((notif) => notif['category_key'] == _selectedFilter)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    // Load data setelah frame pertama selesai di-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _setupFCMListener();
      _printDebugInfo();
    });
  }

  /// Load notifications dan categories dari backend
  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load categories
      final categories = await NotificationApiService.getCategories();

      // Load notifications
      final response = await NotificationApiService.getNotifications(
        category: _selectedFilter,
        perPage: 50,
      );

      setState(() {
        _categories = categories;
        _notifications = response['data']?['data'] ?? [];
        _unreadCount = response['data']?['unread_count'] ?? 0;
        _isLoading = false;
      });

      print('✅ Loaded ${_notifications.length} notifications');
      print('📊 Unread count: $_unreadCount');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
      print('❌ Error loading notifications: $e');
    }
  }

  /// Setup listener untuk FCM push notifications
  void _setupFCMListener() {
    try {
      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('🔔 New notification received: ${message.notification?.title}');
        // Reload notifications
        if (mounted) {
          _loadData();
        }
      });

      // Listen for notification opened from terminated state
      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          print(
            '📬 App opened from notification: ${message.notification?.title}',
          );
        }
      });

      // Listen for notification opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📬 Notification opened: ${message.notification?.title}');
        if (mounted) {
          _loadData();
        }
      });
    } catch (e) {
      print('⚠️ Error setting up FCM listener: $e');
      // Firebase belum initialized atau ada error lain
      // App tetap bisa digunakan tanpa push notification listener
    }
  }

  /// Print debug info ke console
  Future<void> _printDebugInfo() async {
    try {
      final token = await NotificationService.instance.getToken();
      print('\n═══════════════════════════════════════');
      print('🔥 FIREBASE NOTIFICATION DEBUG INFO');
      print('═══════════════════════════════════════');
      if (token != null && token.length > 40) {
        print('📱 FCM Token: ${token.substring(0, 40)}...');
      } else {
        print('📱 FCM Token: $token');
      }
      print('📍 Page: Notification Page');
      print('═══════════════════════════════════════\n');
    } catch (e) {
      print('⚠️ Error getting debug info: $e');
      // Error mendapatkan FCM token, bisa diabaikan
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant,
                    width: 0.65,
                  ),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  size: 24,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.notification,
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                      height: 1.33,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_unreadCount ${l10n.unreadNotificationsCount}',
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.43,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Debug & Refresh buttons
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.bug_report,
                                  color: colorScheme.secondary,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationDebugPage(),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.refresh,
                                  color: colorScheme.primary,
                                ),
                                onPressed: _isLoading ? null : _loadData,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Filter Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterTab('all', l10n.notifFilterAll),
                            const SizedBox(width: 8),
                            ..._categories.map((cat) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildFilterTab(
                                  cat['key'],
                                  cat['name'] ?? cat['key'],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            // Mark All Button & Error Message
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            if (!_isLoading && _errorMessage == null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await NotificationApiService.markAllAsRead();
                        _loadData();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.markAllAsRead,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: colorScheme.primary,
                              height: 1.43,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // Notification List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: colorScheme.primary),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat notifikasi...',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada notifikasi',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: _filteredNotifications.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final notif = _filteredNotifications[index];
                          final isOpen = _openedIndex == index;

                          return GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              if (details.delta.dx < -5) {
                                setState(() {
                                  _openedIndex = index;
                                });
                              } else if (details.delta.dx > 5 && isOpen) {
                                setState(() {
                                  _openedIndex = null;
                                });
                              }
                            },
                            child: Stack(
                              children: [
                                // Background dengan tombol hapus
                                Positioned.fill(
                                  child: GestureDetector(
                                    onTap: () {
                                      _showDeleteDialog(notif);
                                    },
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      decoration: BoxDecoration(
                                        color: colorScheme.error,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Container(
                                        width: 80,
                                        height: double.infinity,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Card notifikasi
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                  transform: Matrix4.translationValues(
                                    isOpen ? -80 : 0,
                                    0,
                                    0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (isOpen) {
                                        setState(() {
                                          _openedIndex = null;
                                        });
                                      } else if (!notif['is_read']) {
                                        await NotificationApiService.markAsRead(
                                          notif['id'],
                                        );
                                        _loadData();
                                      }
                                    },
                                    child: _buildNotificationCard(notif),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> notif) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.deleteNotificationTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            '${l10n.deleteNotificationMessage} "${notif['title']}"?',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () async {
                await NotificationApiService.deleteNotification(notif['id']);
                setState(() {
                  _openedIndex = null;
                });
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${notif['title']} ${l10n.deleted}'),
                    backgroundColor: colorScheme.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                l10n.delete,
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterTab(String key, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = key;
        });
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
            height: 1.43,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    final colorScheme = Theme.of(context).colorScheme;

    // Get data dari notifikasi
    final categoryKey = notif['category_key'] ?? '';
    final title = notif['title'] ?? '';
    final message = notif['message'] ?? '';
    final isRead = notif['is_read'] ?? false;
    final createdAt = notif['created_at'];

    // Parse time
    String timeAgo = '';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        final diff = DateTime.now().difference(date);
        if (diff.inMinutes < 1) {
          timeAgo = 'Baru saja';
        } else if (diff.inMinutes < 60) {
          timeAgo = '${diff.inMinutes} menit lalu';
        } else if (diff.inHours < 24) {
          timeAgo = '${diff.inHours} jam yang lalu';
        } else if (diff.inDays < 7) {
          timeAgo = '${diff.inDays} hari yang lalu';
        } else {
          timeAgo = '${date.day}/${date.month}/${date.year}';
        }
      } catch (e) {
        timeAgo = createdAt.toString();
      }
    }

    // Icon dan color berdasarkan category
    IconData icon;
    Color iconColor;
    String categoryName;

    switch (categoryKey) {
      case 'service':
        icon = Icons.info_outline;
        iconColor = const Color(0xFF51A2FF);
        categoryName = 'Servis';
        break;
      case 'trip':
        icon = Icons.check_circle_outline;
        iconColor = const Color(0xFF05DF72);
        categoryName = 'Perjalanan';
        break;
      case 'warning':
        icon = Icons.warning_amber_outlined;
        iconColor = const Color(0xFFFF8904);
        categoryName = 'Peringatan';
        break;
      case 'system':
        icon = Icons.notifications_outlined;
        iconColor = colorScheme.onSurfaceVariant;
        categoryName = 'Sistem';
        break;
      default:
        icon = Icons.notifications_outlined;
        iconColor = colorScheme.primary;
        categoryName = categoryKey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(
          color: isRead
              ? colorScheme.outlineVariant
              : colorScheme.primary.withOpacity(0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: iconColor,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
