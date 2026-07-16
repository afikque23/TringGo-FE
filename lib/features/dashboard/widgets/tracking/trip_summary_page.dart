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

  final _vehicleService = VehicleService();
  bool _isSaving = false;

  // Parameter default — pre-fill dari vehicle yang ada jika tersedia
  String? _defaultBeban;
  bool? _defaultPenumpang;
  String? _defaultGayaBerkendara;
  String? _defaultKondisiJalan;
  String? _defaultMedan;

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

  bool get _hasPreviousParams {
    final v = widget.currentVehicle;
    if (v == null) return false;
    return v.defaultBeban != null ||
        v.defaultPenumpang != null ||
        v.defaultGayaBerkendara != null ||
        v.defaultKondisiJalan != null ||
        v.defaultMedan != null;
  }

  void _usePreviousParams() {
    final v = widget.currentVehicle;
    if (v == null) return;
    setState(() {
      _defaultBeban = v.defaultBeban;
      _defaultPenumpang = v.defaultPenumpang;
      _defaultGayaBerkendara = v.defaultGayaBerkendara;
      _defaultKondisiJalan = v.defaultKondisiJalan;
      _defaultMedan = v.defaultMedan;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _saveAndReturn() async {
    setState(() => _isSaving = true);
    try {
      if (widget.currentVehicle != null) {
        final updatedJson = widget.currentVehicle!.toJson();
        updatedJson['default_beban'] = _defaultBeban;
        updatedJson['default_penumpang'] = _defaultPenumpang;
        updatedJson['default_gaya_berkendara'] = _defaultGayaBerkendara;
        updatedJson['default_kondisi_jalan'] = _defaultKondisiJalan;
        updatedJson['default_medan'] = _defaultMedan;
        
        final updatedVehicle = VehicleModel.fromJson(updatedJson);
        await _vehicleService.updateVehicle(widget.vehicleId, updatedVehicle);
      }

      if (mounted) {
        // Kembali ke tracking page lalu pop lagi ke dashboard
        // Pop TripSummaryPage dengan result true (berhasil disimpan)
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan parameter: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _skipAndReturn() async {
    final shouldSkip = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Tutup Tanpa Menyimpan?',
            style: TextStyle(color: Colors.white, fontFamily: 'Arial'),
          ),
          content: const Text(
            'Parameter motor tidak akan diperbarui. Apakah Anda yakin ingin menutup halaman ini?',
            style: TextStyle(color: Colors.white70, fontFamily: 'Arial'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey, fontFamily: 'Arial'),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _card,
                side: const BorderSide(color: _border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Tutup',
                style: TextStyle(color: Colors.white, fontFamily: 'Arial'),
              ),
            ),
          ],
        );
      },
    );

    if (shouldSkip == true) {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripData = widget.tripData;

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
                        onPressed: _isSaving ? null : _skipAndReturn,
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

                        // ── Divider Label Parameter ───────────────────────
                        Row(
                          children: [
                            Container(width: 3, height: 16, color: _greenLight),
                            const SizedBox(width: 10),
                            const Text(
                              'Parameter Motor Anda (Opsional)',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Arial',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Parameter ini digunakan untuk perhitungan jadwal servis yang lebih akurat.',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontFamily: 'Arial',
                            fontSize: 12,
                          ),
                        ),
                        if (_hasPreviousParams) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _usePreviousParams,
                            icon: const Icon(Icons.history, size: 16),
                            label: const Text(
                              'Gunakan Parameter Sebelumnya',
                              style: TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _greenLight,
                              side: const BorderSide(color: _greenLight),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // ── Form Parameter Default ─────────────────────────
                        _buildParamSection(
                          label: 'Beban Bawaan Biasa',
                          icon: Icons.shopping_bag_outlined,
                          child: _buildChipSelector(
                            options: const ['🎒 Ringan', '🛍️ Sedang', '📦 Berat'],
                            values: const ['ringan', 'sedang', 'berat'],
                            selected: _defaultBeban,
                            onSelected: (v) =>
                                setState(() => _defaultBeban = v),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildParamSection(
                          label: 'Gaya Berkendara',
                          icon: Icons.speed_outlined,
                          child: _buildChipSelector(
                            options: const [
                              '🐢 Pelan',
                              '🚗 Normal',
                              '🏎️ Agresif',
                            ],
                            values: const ['pelan', 'normal', 'agresif'],
                            selected: _defaultGayaBerkendara,
                            onSelected: (v) =>
                                setState(() => _defaultGayaBerkendara = v),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildParamSection(
                          label: 'Kondisi Jalan Dominan',
                          icon: Icons.traffic_outlined,
                          child: _buildChipSelector(
                            options: const [
                              '🔴 Macet',
                              '🟡 Sedang',
                              '🟢 Lancar',
                            ],
                            values: const ['macet', 'sedang', 'lancar'],
                            selected: _defaultKondisiJalan,
                            onSelected: (v) =>
                                setState(() => _defaultKondisiJalan = v),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildParamSection(
                          label: 'Medan Jalan',
                          icon: Icons.terrain_outlined,
                          child: _buildChipSelector(
                            options: const [
                              '🏙️ Datar',
                              '🌄 Campuran',
                              '🏔️ Berbukit',
                            ],
                            values: const ['datar', 'campuran', 'berbukit'],
                            selected: _defaultMedan,
                            onSelected: (v) =>
                                setState(() => _defaultMedan = v),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Toggle Penumpang
                        _buildToggleParam(),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // ── Tombol Simpan ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAndReturn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        disabledBackgroundColor: const Color(0xFF3A3A3A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Simpan & Kembali',
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
    final duration = tripData['durationMinutes']?.toString() ?? '0';
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
                  value: '${duration} mnt',
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

          // Elevasi (jika ada)
          if (elevGain != null) ...[
            const SizedBox(height: 12),
            Container(height: 1, color: _border),
            const SizedBox(height: 12),
            Center(
              child: _buildStatItem(
                icon: Icons.landscape_outlined,
                label: 'Elevasi Naik',
                value: '${elevGain} m',
                compact: false,
              ),
            ),
          ],
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

  // ── Widget: Section Parameter ──────────────────────────────────────────────

  Widget _buildParamSection({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF6B7280), size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontFamily: 'Arial',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildChipSelector({
    required List<String> options,
    required List<String> values,
    required String? selected,
    required void Function(String?) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(options.length, (i) {
        final isSelected = selected == values[i];
        return GestureDetector(
          onTap: () => onSelected(isSelected ? null : values[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? _green.withOpacity(0.25)
                  : const Color(0xFF111111),
              border: Border.all(
                color: isSelected ? _greenLight : _border,
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              options[i],
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? _greenLight : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildToggleParam() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_outline,
            color: Color(0xFF6B7280),
            size: 16,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sering Bawa Penumpang?',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontFamily: 'Arial',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Mempengaruhi kalkulasi beban motor',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontFamily: 'Arial',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _defaultPenumpang ?? false,
            onChanged: (v) => setState(() => _defaultPenumpang = v),
            activeColor: _greenLight,
            activeTrackColor: _green.withOpacity(0.4),
            inactiveThumbColor: const Color(0xFF6B7280),
            inactiveTrackColor: _border,
          ),
        ],
      ),
    );
  }
}
