import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';

class NotifikasiSettingPage extends StatefulWidget {
  const NotifikasiSettingPage({super.key});

  @override
  State<NotifikasiSettingPage> createState() => _NotifikasiSettingPageState();
}

class _NotifikasiSettingPageState extends State<NotifikasiSettingPage> {
  // Master toggle
  bool _allNotificationsEnabled = true;

  // Maintenance notifications
  bool _scheduleReminders = true;
  bool _urgentMaintenance = true;
  bool _periodicService = true;

  // Trip notifications
  bool _dailySummary = true;
  bool _weeklySummary = true;
  bool _longTrips = true;

  // Vehicle notifications
  bool _vehicleSwitch = false;
  bool _vehicleStatus = true;

  // System notifications
  bool _appUpdates = true;
  bool _syncErrors = true;

  void _toggleAllNotifications(bool value) {
    setState(() {
      _allNotificationsEnabled = value;
      if (!value) {
        // Turn off all notifications
        _scheduleReminders = false;
        _urgentMaintenance = false;
        _periodicService = false;
        _dailySummary = false;
        _weeklySummary = false;
        _longTrips = false;
        _vehicleSwitch = false;
        _vehicleStatus = false;
        _appUpdates = false;
        _syncErrors = false;
      }
    });
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
            // Header
            _buildHeader(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  children: [
                    // Master Toggle
                    _buildMasterToggle(),
                    const SizedBox(height: 16),
                    // Maintenance Section
                    _buildMaintenanceSection(),
                    const SizedBox(height: 16),
                    // Trip Section
                    _buildTripSection(),
                    const SizedBox(height: 16),
                    // Vehicle Section
                    _buildVehicleSection(),
                    const SizedBox(height: 16),
                    // System Section
                    _buildSystemSection(),
                    const SizedBox(height: 16),
                    // Recommendation Card
                    _buildRecommendationCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 15, 24, 12),
        child: Row(
          children: [
            // Back Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
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
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.notificationSettings,
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
                    'Kelola preferensi notifikasi Anda',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterToggle() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20.65, 20.65, 20.65, 0.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.allNotifications,
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
                      l10n.enableDisableAll,
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
              // Toggle
              Switch(
                value: _allNotificationsEnabled,
                onChanged: _toggleAllNotifications,
                activeColor: colorScheme.onPrimary,
                activeTrackColor: colorScheme.primary,
                inactiveThumbColor: colorScheme.onSurface,
                inactiveTrackColor: colorScheme.outlineVariant,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.build_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.maintenanceNotifications,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Items
          _buildToggleItem(
            icon: Icons.event_outlined,
            title: l10n.scheduleReminders,
            subtitle: l10n.scheduleRemindersDesc,
            value: _scheduleReminders,
            onChanged: (value) => setState(() => _scheduleReminders = value),
            showDivider: true,
          ),
          _buildToggleItem(
            icon: Icons.priority_high_outlined,
            title: l10n.urgentMaintenanceNotif,
            subtitle: l10n.urgentMaintenanceNotifDesc,
            value: _urgentMaintenance,
            onChanged: (value) => setState(() => _urgentMaintenance = value),
            showDivider: true,
          ),
          _buildToggleItem(
            icon: Icons.calendar_today_outlined,
            title: l10n.periodicServiceNotif,
            subtitle: l10n.periodicServiceNotifDesc,
            value: _periodicService,
            onChanged: (value) => setState(() => _periodicService = value),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTripSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.route_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.tripNotifications,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Items
          _buildToggleItem(
            icon: Icons.today_outlined,
            title: l10n.dailySummary,
            subtitle: l10n.dailySummaryDesc,
            value: _dailySummary,
            onChanged: (value) => setState(() => _dailySummary = value),
            showDivider: true,
          ),
          _buildToggleItem(
            icon: Icons.calendar_view_week_outlined,
            title: l10n.weeklySummary,
            subtitle: l10n.weeklySummaryDesc,
            value: _weeklySummary,
            onChanged: (value) => setState(() => _weeklySummary = value),
            showDivider: true,
          ),
          _buildToggleItem(
            icon: Icons.location_on_outlined,
            title: l10n.longTripAlert,
            subtitle: l10n.longTripAlertDesc,
            value: _longTrips,
            onChanged: (value) => setState(() => _longTrips = value),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.motorcycle_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.vehicleNotifications,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Items
          _buildToggleItem(
            icon: Icons.calendar_today_outlined,
            title: l10n.vehicleSwitching,
            subtitle: l10n.vehicleSwitchingDesc,
            value: _vehicleSwitch,
            onChanged: (value) => setState(() => _vehicleSwitch = value),
            showDivider: true,
          ),
          _buildToggleItem(
            icon: Icons.info_outline,
            title: l10n.vehicleStatus,
            subtitle: l10n.vehicleStatusDesc,
            value: _vehicleStatus,
            onChanged: (value) => setState(() => _vehicleStatus = value),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0.65),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.systemNotifications,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Items
          _buildToggleItem(
            icon: Icons.system_update_outlined,
            title: l10n.appUpdates,
            subtitle: l10n.appUpdatesDesc,
            value: _appUpdates,
            onChanged: (value) => setState(() => _appUpdates = value),
            showDivider: true,
          ),
          _buildToggleItem(
            icon: Icons.sync_problem_outlined,
            title: l10n.syncErrors,
            subtitle: l10n.syncErrorsDesc,
            value: _syncErrors,
            onChanged: (value) => setState(() => _syncErrors = value),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool showDivider,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.65,
                ),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 20, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                    subtitle,
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
            // Toggle Switch
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: colorScheme.onPrimary,
              activeTrackColor: colorScheme.primary,
              inactiveThumbColor: colorScheme.onSurface,
              inactiveTrackColor: colorScheme.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16.65, 16.65, 16.65, 0.65),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.recommendedSettings,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.43,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.recommendedSettingsDesc,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.67,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
