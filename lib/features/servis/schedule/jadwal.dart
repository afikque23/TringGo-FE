import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../widget/bottom_navbar.dart';
import '../../widget/page_transition.dart';
import 'detail_jadwal.dart';
import '../history/riwayat_service.dart';
import 'tambah_jadwal.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
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
                        _buildTabButton(l10n.overview, false),
                        const SizedBox(width: 8),
                        _buildTabButton(l10n.schedule, true),
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
                    _buildInfoCard(),
                    const SizedBox(height: 12),
                    _buildAddScheduleButton(),
                    const SizedBox(height: 12),
                    _buildServiceItem(
                      icon: Icons.oil_barrel_outlined,
                      title: l10n.oilChange,
                      hasIntervalBadge: true,
                      status: l10n.soon,
                      statusColor: colorScheme.warning,
                      kmRemaining: '755',
                      nextKm: '9000',
                      currentKm: '8245',
                      percentage: 75,
                      progressColor: colorScheme.warning,
                    ),
                    const SizedBox(height: 12),
                    _buildServiceItem(
                      icon: Icons.cached,
                      title: l10n.brakePads,
                      hasIntervalBadge: false,
                      status: l10n.good,
                      statusColor: colorScheme.primary,
                      kmRemaining: '6755',
                      nextKm: '15000',
                      currentKm: '8245',
                      percentage: 55,
                      progressColor: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    _buildServiceItem(
                      icon: Icons.settings_outlined,
                      title: l10n.chainSprocket,
                      hasIntervalBadge: true,
                      status: l10n.good,
                      statusColor: colorScheme.primary,
                      kmRemaining: '3755',
                      nextKm: '12000',
                      currentKm: '8245',
                      percentage: 6,
                      progressColor: colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    _buildServiceItem(
                      icon: Icons.multiline_chart,
                      title: l10n.tireInspection,
                      hasIntervalBadge: false,
                      status: l10n.soon,
                      statusColor: colorScheme.warning,
                      kmRemaining: '255',
                      nextKm: '8500',
                      currentKm: '8245',
                      percentage: 65,
                      progressColor: colorScheme.warning,
                    ),
                    const SizedBox(height: 12),
                    _buildServiceItem(
                      icon: Icons.bolt_outlined,
                      title: l10n.sparkPlug,
                      hasIntervalBadge: false,
                      status: l10n.urgent,
                      statusColor: colorScheme.error,
                      kmRemaining: '0',
                      nextKm: '8000',
                      currentKm: '8245',
                      percentage: 3,
                      progressColor: colorScheme.error,
                    ),
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
          if (label == l10n.overview) {
            // Navigate back to Overview page
            Navigator.pop(context);
          } else if (label == l10n.history) {
            // Navigate to History page
            Navigator.push(
              context,
              SmoothPageRoute(page: const RiwayatServicePage()),
            );
          }
          // Schedule is already active
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
      child: Text(
        l10n.schedulePrediction,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Arial',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.secondary,
          height: 1.43,
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required bool hasIntervalBadge,
    required String status,
    required Color statusColor,
    required String kmRemaining,
    required String nextKm,
    required String currentKm,
    required int percentage,
    required Color progressColor,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SmoothPageRoute(
            page: DetailJadwalPage(
              title: title,
              status: status,
              statusColor: statusColor,
              kmRemaining: kmRemaining,
              currentKm: currentKm,
              targetKm: nextKm,
              percentage: percentage,
              interval: l10n.every3000km,
              lastService: '15 November 2025',
              reminder: l10n.activeReminder,
              notes: l10n.useFullySynthetic,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.65,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.5,
                              ),
                            ),
                          ),
                          if (hasIntervalBadge) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.4),
                                  width: 0.65,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                l10n.intervalAdjusted,
                                style: TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).colorScheme.primary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            status,
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: statusColor,
                              height: 1.33,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• $kmRemaining ${l10n.kmRemaining}',
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
                    ],
                  ),
                ),
                // Next KM
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.next,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.secondary,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$nextKm km',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 8,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.outlineVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.currently}: $currentKm km',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.secondary,
                        height: 1.33,
                      ),
                    ),
                    Text(
                      '$percentage%',
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddScheduleButton() {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SmoothPageRoute(page: const TambahJadwalPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.65,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Text(
              l10n.addMaintenanceSchedule,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
