import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../widget/bottom_navbar.dart';
import '../widget/page_transition.dart';
import 'schedule/jadwal.dart';
import 'history/riwayat_service.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  final int _selectedIndex = 1; // Service tab is active

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Header with tabs
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.service,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildTabButton(l10n.overview, true),
                        const SizedBox(width: 8),
                        _buildTabButton(l10n.schedule, false),
                        const SizedBox(width: 8),
                        _buildTabButton(l10n.history, false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 16),
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    _buildRecommendationsCard(),
                    const SizedBox(height: 16),
                    _buildUsagePatternCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex),
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    IconData icon;
    if (label == l10n.overview) {
      icon = Icons.info_outline;
    } else if (label == l10n.schedule) {
      icon = Icons.schedule_outlined;
    } else if (label == l10n.history) {
      icon = Icons.history;
    } else {
      icon = Icons.info_outline;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (label == l10n.schedule) {
            // Navigate to Schedule page
            Navigator.push(context, SmoothPageRoute(page: const JadwalPage()));
          } else if (label == l10n.history) {
            // Navigate to History page
            Navigator.push(
              context,
              SmoothPageRoute(page: const RiwayatServicePage()),
            );
          }
          // Tab switching logic for other tabs
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isActive ? Colors.white : colorScheme.secondary,
                  height: 1.43,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.overallStatus,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface,
                  height: 1.56,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.check_circle_outline,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.good,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: 0.75,
                  minHeight: 12,
                  backgroundColor: colorScheme.outlineVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.vehicleCondition,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.secondary,
                  height: 1.33,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatBox(
                l10n.urgent,
                '1',
                colorScheme.error,
                Icons.warning_amber_outlined,
              ),
              const SizedBox(width: 12),
              _buildStatBox(
                l10n.soon,
                '2',
                colorScheme.warning,
                Icons.access_time,
              ),
              const SizedBox(width: 12),
              _buildStatBox(
                l10n.good,
                '5',
                colorScheme.primary,
                Icons.check_circle_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 0.65),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color.withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.secondary,
                      height: 1.33,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: color,
                height: 1.33,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aboutService,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.aboutServiceDesc,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    height: 1.62,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 0.65,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.totalComponents,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.secondary,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '8',
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
                  l10n.monitored,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.secondary,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 0.65,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.needsAttention,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.secondary,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '3',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.warning,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.item,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.secondary,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recommendations,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 12),
          _buildRecommendationItem(
            icon: Icons.warning_amber_outlined,
            color: colorScheme.error,
            title: l10n.urgentMaintenance,
            description: l10n.urgentMaintenanceDesc,
          ),
          const SizedBox(height: 8),
          _buildRecommendationItem(
            icon: Icons.access_time,
            color: colorScheme.warning,
            title: l10n.planMaintenance,
            description: l10n.planMaintenanceDesc,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: color,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.secondary,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsagePatternCard() {
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.bar_chart,
                  size: 20,
                  color: colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.usagePatternSummary,
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
                      l10n.usagePatternDesc,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.secondary,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withValues(alpha: 0.1),
              border: Border.all(
                color: colorScheme.tertiary.withValues(alpha: 0.3),
                width: 0.65,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.route_outlined,
                  size: 20,
                  color: colorScheme.tertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.lightUsage,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.tertiary,
                          height: 1.43,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.lightUsageDesc,
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurface,
                          height: 1.62,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildUsageStatBox(l10n.average, '11.1', l10n.kmPerDay),
              const SizedBox(width: 12),
              _buildUsageStatBox(l10n.thisWeek, '78', l10n.kmTotal),
              const SizedBox(width: 12),
              _buildUsageStatBox(l10n.odometer, '8,450', l10n.km),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant, width: 0.65),
              ),
            ),
            child: Text(
              l10n.usagePatternFooter,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
                height: 1.62,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStatBox(String label, String value, String unit) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: colorScheme.secondary,
                height: 1.33,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
                height: 1.56,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              unit,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
