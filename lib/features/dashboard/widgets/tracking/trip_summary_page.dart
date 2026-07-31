import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/model/vehicle_model.dart';
import '../../../../core/services/vehicle_service.dart';

/// Halaman ringkasan perjalanan setelah menghentikan GPS tracking.
/// Menampilkan statistik perjalanan dan form opsional untuk mengatur
/// parameter default motor yang digunakan dalam kalkulasi jadwal servis.
class TripSummaryPage extends StatefulWidget {
  const TripSummaryPage({
    super.key,
    required this.tripData,
    required this.vehicleId,
    required this.vehicleName,
    this.currentVehicle,
  });

  final Map<String, dynamic> tripData;
  final int vehicleId;
  final String vehicleName;

  /// Kendaraan saat ini (opsional) — dipakai untuk pre-fill form parameter default
  final VehicleModel? currentVehicle;

  @override
  State<TripSummaryPage> createState() => _TripSummaryPageState();
}

class _TripSummaryPageState extends State<TripSummaryPage>
    with TickerProviderStateMixin {
  static const _bg = Color(0xFF0A0A0A);
  static const _card = Color(0xFF1A1A1A);
  static const _border = Color(0xFF2A2A2A);
  static const _green = Color(0xFF6B7C4F);
  static const _greenLight = Color(0xFF8FA06A);

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  double _toDouble(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  bool _toBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
    return fallback;
  }

  String _formatDuration(dynamic rawValue) {
    final minutes = rawValue is num
        ? rawValue.toDouble()
        : double.tryParse(rawValue?.toString() ?? '');

    if (minutes == null || minutes.isNaN || minutes < 0) {
      return '0 mnt';
    }

    final totalSeconds = (minutes * 60).round();
    final hours = totalSeconds ~/ 3600;
    final remainingMinutes = (totalSeconds % 3600) ~/ 60;
    final remainingSeconds = totalSeconds % 60;

    if (hours > 0) {
      if (remainingSeconds > 0) {
        return '$hours jam ${remainingMinutes} mnt ${remainingSeconds} dtk';
      }
      return '$hours jam ${remainingMinutes} mnt';
    }

    if (remainingMinutes > 0) {
      if (remainingSeconds > 0) {
        return '${remainingMinutes} mnt ${remainingSeconds} dtk';
      }
      return '${remainingMinutes} mnt';
    }

    return '${remainingSeconds} dtk';
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _close() {
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripData = widget.tripData;
    final tripPointsCount = _toInt(tripData['tripPointsCount']);
    final usedClientDistance = _toBool(tripData['usedClientDistance']);
    final distanceValue = _toDouble(tripData['distanceValue']);
    final hasInsufficientTelemetry =
        usedClientDistance || (tripPointsCount > 0 && tripPointsCount < 2);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: _greenLight,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Perjalanan Selesai',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Arial',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Tombol Tutup
                      TextButton(
                        onPressed: _close,
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontFamily: 'Arial',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Content Scrollable ───────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Card Statistik Perjalanan ──────────────────────
                        _buildTripStatsCard(tripData),
                        const SizedBox(height: 24),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // ── Tombol Tutup ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _close,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widget: Card Statistik ─────────────────────────────────────────────────

  Widget _buildTripStatsCard(Map<String, dynamic> tripData) {
    final distance = tripData['distanceValue']?.toString() ?? '0.00';
    final duration = _formatDuration(tripData['durationMinutes']);
    final avgSpeed = tripData['averageSpeedKph']?.toString() ?? '0.0';
    final maxSpeed = tripData['maxSpeedKph']?.toString() ?? '0';
    final elevGain = tripData['elevationGainM'];
    final startTime = tripData['startTime']?.toString() ?? '--:--';
    final endTime = tripData['endTime']?.toString() ?? '--:--';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _greenLight.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle name + waktu
          Row(
            children: [
              const Icon(Icons.motorcycle, color: _greenLight, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.vehicleName,
                  style: const TextStyle(
                    color: _greenLight,
                    fontFamily: 'Arial',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$startTime  →  $endTime',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontFamily: 'Arial',
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Jarak Utama
          Center(
            child: Column(
              children: [
                Text(
                  '$distance km',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Arial',
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Jarak Perjalanan',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontFamily: 'Arial',
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          Container(height: 1, color: _border),
          const SizedBox(height: 16),

          // Grid Statistik
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.timer_outlined,
                  label: 'Durasi',
                  value: duration,
                ),
              ),
              Container(width: 1, height: 40, color: _border),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.speed_outlined,
                  label: 'Avg Speed',
                  value: '$avgSpeed km/h',
                ),
              ),
              Container(width: 1, height: 40, color: _border),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.arrow_upward,
                  label: 'Max Speed',
                  value: '$maxSpeed km/h',
                ),
              ),
            ],
          ),

          // Elevasi dihapus sesuai permintaan
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    bool compact = true,
  }) {
    return Column(
      children: [
        Icon(icon, color: _greenLight, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Arial',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontFamily: 'Arial',
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
