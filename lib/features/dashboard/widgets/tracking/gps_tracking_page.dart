import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../l10n/app_localizations.dart';
import 'gps_tracking_active_page.dart';
import '../riwayat_trip/riwayat_trip.dart';

class GpsTrackingPage extends StatefulWidget {
  const GpsTrackingPage({super.key});

  @override
  State<GpsTrackingPage> createState() => _GpsTrackingPageState();
}

class _GpsTrackingPageState extends State<GpsTrackingPage> {
  // Tracking state
  final bool _isTracking = false;
  final double _distance = 0.0;
  final String _duration = "0:00";
  final int _currentSpeed = 0;
  final double _averageSpeed = 0.0;

  void _toggleTracking() {
    if (!_isTracking) {
      // Navigate to active tracking page
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const GpsTrackingActivePage()),
      );
    }
    // TODO: Implement actual GPS tracking logic
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildMapContainer(),
              const SizedBox(height: 16),
              Expanded(child: _buildStatsSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 48, 24, 5),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerLow),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.liveTracking,
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
              Text(
                'My Ninja',
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapContainer() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 320,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 50,
            offset: const Offset(0, 25),
            spreadRadius: -12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Grid overlay
            Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: _GridPainter(), child: Container()),
            ),
            // Center icon with text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.map_outlined,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.pressStartToTrack,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.ensureGPSActive,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.access_time,
                    iconColor: const Color(0xFF6B7C4F),
                    label: l10n.duration,
                    value: _duration,
                    unit: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.speed,
                    iconColor: const Color(0xFF51A2FF),
                    label: l10n.avgSpeed,
                    value: _averageSpeed.toStringAsFixed(0),
                    unit: 'km/h',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.bolt,
                    iconColor: const Color(0xFFFFB900),
                    label: l10n.maxSpeed,
                    value: _currentSpeed.toString(),
                    unit: 'km/h',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // View Trip History Link
            // Start/Stop Tracking Button
            _buildTrackingButton(),
            const SizedBox(height: 16),

            // View Trip History Link (DI BAWAH TOMBOL)
            _buildViewHistoryButton(),
            const SizedBox(height: 16),
            // Tracking Status Info
            if (_isTracking) _buildTrackingInfo(),
            if (_isTracking) const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.65, 16.65, 16.65, 0.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontFamily: 'Arial',
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildViewHistoryButton() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const RiwayatTripPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.viewTripHistory,
              style: TextStyle(
                fontFamily: 'Arial',
                color: colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingButton() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: _toggleTracking,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 10),
              spreadRadius: -3,
            ),
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 24, color: colorScheme.onPrimary),
            const SizedBox(width: 12),
            Text(
              l10n.startTracking,
              style: TextStyle(
                fontFamily: 'Arial',
                color: colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w400,
                height: 1.56,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingInfo() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(53, 16.65, 53, 16.65),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        border: Border.all(color: colorScheme.primary, width: 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        l10n.trackingActive,
        style: TextStyle(
          fontFamily: 'Arial',
          color: colorScheme.primary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.43,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Custom painter for grid overlay
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += 31.86) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += 35.95) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
