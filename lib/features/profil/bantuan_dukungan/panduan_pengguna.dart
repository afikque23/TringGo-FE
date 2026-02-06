import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';

class PanduanPenggunaPage extends StatefulWidget {
  const PanduanPenggunaPage({super.key});

  @override
  State<PanduanPenggunaPage> createState() => _PanduanPenggunaPageState();
}

class _PanduanPenggunaPageState extends State<PanduanPenggunaPage> {
  int? _expandedSectionIndex;

  List<Map<String, dynamic>> _getGuideData(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'title': l10n.gettingStartedTitle,
        'icon': Icons.menu_book_outlined,
        'topicCount': 3,
        'topics': [
          {
            'title': l10n.creatingAccount,
            'description': l10n.creatingAccountDesc,
          },
          {
            'title': l10n.addingFirstMotorcycle,
            'description': l10n.addingFirstMotorcycleDesc,
          },
          {
            'title': l10n.dashboardNavigation,
            'description': l10n.dashboardNavigationDesc,
          },
        ],
      },
      {
        'title': l10n.managingVehicles,
        'icon': Icons.motorcycle_outlined,
        'topicCount': 3,
        'topics': [
          {'title': l10n.multiVehicle, 'description': l10n.multiVehicleDesc},
          {
            'title': l10n.editMotorcycleInfo,
            'description': l10n.editMotorcycleInfoDesc,
          },
          {'title': l10n.deleteVehicle, 'description': l10n.deleteVehicleDesc},
        ],
      },
      {
        'title': l10n.gpsTrackingTitle,
        'icon': Icons.route_outlined,
        'topicCount': 4,
        'topics': [
          {
            'title': l10n.startTripTracking,
            'description': l10n.startTripTrackingDesc,
          },
          {'title': l10n.duringTrip, 'description': l10n.duringTripDesc},
          {'title': l10n.endingTrip, 'description': l10n.endingTripDesc},
          {
            'title': l10n.viewTripHistory,
            'description': l10n.viewTripHistoryDesc,
          },
        ],
      },
      {
        'title': l10n.maintenanceServiceTitle,
        'icon': Icons.build_outlined,
        'topicCount': 4,
        'topics': [
          {
            'title': l10n.smartMaintenanceTracking,
            'description': l10n.smartMaintenanceTrackingDesc,
          },
          {
            'title': l10n.addServiceHistory,
            'description': l10n.addServiceHistoryDesc,
          },
          {
            'title': l10n.periodicServiceSchedule,
            'description': l10n.periodicServiceScheduleDesc,
          },
          {
            'title': l10n.workshopLocator,
            'description': l10n.workshopLocatorDesc,
          },
        ],
      },
      {
        'title': l10n.notificationsRemindersTitle,
        'icon': Icons.notifications_outlined,
        'topicCount': 2,
        'topics': [
          {
            'title': l10n.settingNotifications,
            'description': l10n.settingNotificationsDesc,
          },
          {
            'title': l10n.notificationTypes,
            'description': l10n.notificationTypesDesc,
          },
        ],
      },
      {
        'title': l10n.settingsPersonalizationTitle,
        'icon': Icons.settings_outlined,
        'topicCount': 3,
        'topics': [
          {
            'title': l10n.appPreferences,
            'description': l10n.appPreferencesDesc,
          },
          {
            'title': l10n.privacySecurityTopic,
            'description': l10n.privacySecurityTopicDesc,
          },
          {'title': l10n.backupData, 'description': l10n.backupDataDesc},
        ],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 16),
                    ..._buildGuideSections(context),
                    const SizedBox(height: 16),
                    _buildTipsSection(),
                    const SizedBox(height: 16),
                    _buildContactSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 15, 24, 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.userGuide,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface,
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.completeGuideSubtitle,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.secondary,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.2),
            colorScheme.primary.withOpacity(0.15),
          ],
        ),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.menu_book_outlined,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeGuideTitle,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.welcomeGuideDesc,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withOpacity(0.85),
                    height: 1.64,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGuideSections(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return _getGuideData(context).asMap().entries.map((entry) {
      final index = entry.key;
      final section = entry.value;
      final isExpanded = _expandedSectionIndex == index;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Section Header
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedSectionIndex = isExpanded ? null : index;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          section['icon'] as IconData,
                          size: 24,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section['title'] as String,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurface,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${section['topicCount']} ${l10n.topics}',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.33,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              // Expanded Content
              if (isExpanded) ...[
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 0.65,
                      ),
                    ),
                  ),
                  child: Column(
                    children: (section['topics'] as List<Map<String, String>>)
                        .asMap()
                        .entries
                        .map((topicEntry) {
                          final topicIndex = topicEntry.key;
                          final topic = topicEntry.value;
                          final isLastTopic =
                              topicIndex ==
                              (section['topics'] as List).length - 1;

                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: isLastTopic
                                    ? BorderSide.none
                                    : BorderSide(
                                        color: colorScheme.outlineVariant,
                                        width: 0.65,
                                      ),
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${topicIndex + 1}',
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onPrimary,
                                        height: 1.33,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        topic['title']!,
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: colorScheme.onSurface,
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        topic['description']!,
                                        style: TextStyle(
                                          fontFamily: 'Arial',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: colorScheme.onSurfaceVariant,
                                          height: 1.64,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildTipsSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tipsAndTricks,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildTipItem(l10n.tip1),
          _buildTipItem(l10n.tip2),
          _buildTipItem(l10n.tip3),
          _buildTipItem(l10n.tip4),
          _buildTipItem(l10n.tip5),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
          height: 1.43,
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(58, 16, 60, 16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            l10n.stillHaveQuestions,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface.withOpacity(0.85),
              height: 1.43,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.supportEmail,
            textAlign: TextAlign.center,
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
    );
  }
}
