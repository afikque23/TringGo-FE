import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _selectedFilter = '';
  int? _openedIndex;

  List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get _filteredNotifications {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedFilter == l10n.notifFilterAll) {
      return _notifications;
    }
    return _notifications
        .where((notif) => notif['category'] == _selectedFilter)
        .toList();
  }

  int get _unreadCount {
    return _notifications.where((notif) => !notif['isRead']).length;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _selectedFilter = l10n.notifFilterAll;
      _notifications = [
        {
          'type': 'service',
          'icon': Icons.info_outline,
          'color': Color(0xFF51A2FF),
          'title': l10n.notifOilChangeTitle,
          'description': l10n.notifOilChangeDesc,
          'time': l10n.notifTimeHoursAgo,
          'category': l10n.notifCategoryService,
          'isRead': true,
        },
        {
          'type': 'trip',
          'icon': Icons.check_circle_outline,
          'color': Color(0xFF05DF72),
          'title': l10n.notifLongTripTitle,
          'description': l10n.notifLongTripDesc,
          'time': l10n.notifTimeFiveHoursAgo,
          'category': l10n.notifCategoryTrip,
          'isRead': true,
        },
        {
          'type': 'warning',
          'icon': Icons.warning_amber_outlined,
          'color': Color(0xFFFF8904),
          'title': l10n.notifTirePressureTitle,
          'description': l10n.notifTirePressureDesc,
          'time': l10n.notifTimeOneDayAgo,
          'category': l10n.notifCategoryWarning,
          'isRead': false,
        },
        {
          'type': 'recommendation',
          'icon': Icons.lightbulb_outline,
          'color': Color(0xFF6B7C4F),
          'title': l10n.notifEfficientDrivingTitle,
          'description': l10n.notifEfficientDrivingDesc,
          'time': l10n.notifTimeTwoDaysAgo,
          'category': l10n.notifCategoryRecommendation,
          'isRead': true,
        },
        {
          'type': 'service',
          'icon': Icons.info_outline,
          'color': Color(0xFF51A2FF),
          'title': l10n.notifServiceHistoryTitle,
          'description': l10n.notifServiceHistoryDesc,
          'time': l10n.notifTimeThreeDaysAgo,
          'category': l10n.notifCategoryService,
          'isRead': true,
        },
      ];
    });
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
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Filter Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterTab(l10n.notifFilterAll),
                            const SizedBox(width: 8),
                            _buildFilterTab(l10n.notifCategoryService),
                            const SizedBox(width: 8),
                            _buildFilterTab(l10n.notifCategoryTrip),
                            const SizedBox(width: 8),
                            _buildFilterTab(l10n.notifCategoryWarning),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            // Mark All Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        for (var notif in _notifications) {
                          notif['isRead'] = true;
                        }
                      });
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
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          l10n.cancel,
                                          style: TextStyle(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _notifications.remove(notif);
                                            _openedIndex = null;
                                          });
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${notif['title']} ${l10n.deleted}',
                                              ),
                                              backgroundColor:
                                                  colorScheme.error,
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          l10n.delete,
                                          style: TextStyle(
                                            color: colorScheme.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
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
                            onTap: () {
                              if (isOpen) {
                                setState(() {
                                  _openedIndex = null;
                                });
                              } else if (!notif['isRead']) {
                                setState(() {
                                  notif['isRead'] = true;
                                });
                              }
                            },
                            child: _buildNotificationCard(
                              icon: notif['icon'],
                              iconColor: notif['color'],
                              title: notif['title'],
                              description: notif['description'],
                              time: notif['time'],
                              category: notif['category'],
                              isRead: notif['isRead'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
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

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String time,
    required String category,
    required bool isRead,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    Color categoryColor;
    switch (category) {
      case String _ when category == l10n.notifCategoryService:
        categoryColor = colorScheme.tertiary;
        break;
      case String _ when category == l10n.notifCategoryTrip:
        categoryColor = const Color(0xFF05DF72);
        break;
      case String _ when category == l10n.notifCategoryWarning:
        categoryColor = const Color(0xFFFF8904);
        break;
      case String _ when category == l10n.notifCategoryRecommendation:
        categoryColor = colorScheme.primary;
        break;
      default:
        categoryColor = colorScheme.onSurfaceVariant;
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
                  description,
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
                      time,
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
                      category,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: categoryColor,
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
