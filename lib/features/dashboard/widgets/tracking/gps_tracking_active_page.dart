import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/model/trip_model.dart';

class GpsTrackingActivePage extends StatefulWidget {
  const GpsTrackingActivePage({super.key});

  @override
  State<GpsTrackingActivePage> createState() => _GpsTrackingActivePageState();
}

class _GpsTrackingActivePageState extends State<GpsTrackingActivePage>
    with WidgetsBindingObserver {
  final TrackingService _trackingService = TrackingService();
  StreamSubscription<TripModel>? _tripSubscription;

  // Tracking state
  double _distance = 0.0;
  int _duration = 0; // in seconds
  double _averageSpeed = 0.0;
  double _maxSpeed = 0.0;
  double _currentSpeed = 0.0;
  bool _isStarting = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tripSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle lifecycle changes
    if (state == AppLifecycleState.resumed) {
      // App kembali ke foreground, check dan resume jika tracking masih aktif
      print('App resumed, checking tracking status...');
      if (_trackingService.isTracking) {
        // Re-subscribe to stream jika belum
        if (_tripSubscription == null || _tripSubscription!.isPaused) {
          _subscribeToTracking();
        }
      }
    } else if (state == AppLifecycleState.paused) {
      // App ke background, tracking tetap jalan via foreground service
      print('App paused, tracking continues in background...');
    }
  }

  void _startTracking() async {
    // Start tracking dengan nama motor (bisa diganti dengan data dari form)
    final started = await _trackingService.startTracking(
      motorcycleName: 'My Ninja',
    );

    if (!mounted) return;

    if (!started) {
      setState(() {
        _isStarting = false;
      });
      _showErrorDialog();
      return;
    }

    setState(() {
      _isStarting = false;
    });

    _subscribeToTracking();
  }

  void _subscribeToTracking() {
    // Listen untuk updates
    _tripSubscription?.cancel();
    _tripSubscription = _trackingService.tripStream.listen((trip) {
      if (!mounted) return;

      // Get current speed from last point (convert m/s to km/h)
      double currentSpeed = 0.0;
      if (trip.points.isNotEmpty) {
        final lastPoint = trip.points.last;
        currentSpeed = lastPoint.speed * 3.6; // m/s to km/h
      }

      print(
        '📊 UI Update - Distance: ${trip.totalDistance.toStringAsFixed(3)} km, '
        'Current: ${currentSpeed.toStringAsFixed(1)} km/h, '
        'Avg: ${trip.averageSpeed.toStringAsFixed(1)} km/h, '
        'Max: ${trip.maxSpeed.toStringAsFixed(1)} km/h',
      );

      setState(() {
        _distance = trip.totalDistance;
        _duration = trip.duration;
        _averageSpeed = trip.averageSpeed;
        _maxSpeed = trip.maxSpeed;
        _currentSpeed = currentSpeed;
      });
    });
  }

  void _showErrorDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Tracking Gagal',
          style: TextStyle(
            fontFamily: 'Arial',
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        content: Text(
          'Tidak dapat memulai tracking. Pastikan GPS aktif dan izin lokasi diberikan.',
          style: TextStyle(
            fontFamily: 'Arial',
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Back to previous page
            },
            child: Text(
              'Tutup',
              style: TextStyle(
                fontFamily: 'Arial',
                color: colorScheme.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _stopTracking() async {
    final trip = await _trackingService.stopTracking();

    if (!mounted) return;

    if (trip == null) {
      Navigator.of(context).pop();
      return;
    }

    final colorScheme = Theme.of(context).colorScheme;
    // Show summary dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Tracking Selesai',
          style: TextStyle(
            fontFamily: 'Arial',
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jarak: ${trip.totalDistance.toStringAsFixed(2)} km',
              style: TextStyle(
                fontFamily: 'Arial',
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waktu: ${trip.formattedDuration}',
              style: TextStyle(
                fontFamily: 'Arial',
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kecepatan Rata-rata: ${trip.averageSpeed.toStringAsFixed(1)} km/h',
              style: TextStyle(
                fontFamily: 'Arial',
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kecepatan Maksimal: ${trip.maxSpeed.toStringAsFixed(1)} km/h',
              style: TextStyle(
                fontFamily: 'Arial',
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Tutup',
              style: TextStyle(
                fontFamily: 'Arial',
                color: colorScheme.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colorScheme.surfaceContainerLow,
        statusBarIconBrightness: colorScheme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: colorScheme.brightness,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLow,
        body: _isStarting
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Memulai tracking...',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : SafeArea(
                top: false,
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildMapContainer(),
                              const SizedBox(height: 16),
                              _buildStatsSection(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 44, 14, 0),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerLow),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: SizedBox(
                  width: 40,
                  height: 40,
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
                      'Live Tracking',
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
              ),
              // REC Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFB2C36).withOpacity(0.2),
                  border: Border.all(
                    color: const Color(0xFFFB2C36).withOpacity(0.5),
                    width: 0.65,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFB2C36).withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'REC',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: Color(0xFFFF6467),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Speed Display Card
          _buildSpeedCard(),
        ],
      ),
    );
  }

  Widget _buildSpeedCard() {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine speed status
    String speedStatus = 'Lambat';
    Color speedColor = const Color(0xFF6B7C4F);
    double progressFactor = 0.0;

    if (_currentSpeed > 0) {
      if (_currentSpeed < 20) {
        speedStatus = 'Lambat';
        speedColor = const Color(0xFF6B7C4F);
        progressFactor = _currentSpeed / 80;
      } else if (_currentSpeed < 50) {
        speedStatus = 'Sedang';
        speedColor = const Color(0xFFFACC15);
        progressFactor = _currentSpeed / 80;
      } else {
        speedStatus = 'Cepat';
        speedColor = const Color(0xFFFB2C36);
        progressFactor = _currentSpeed / 80;
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24.65, 24.65, 24.65, 0.65),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Speed value and unit
          SizedBox(
            height: 102.68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentSpeed.toStringAsFixed(0),
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: speedColor,
                    fontSize: 60,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: Text(
                    'km/h',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Speed Status Badge
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
              decoration: BoxDecoration(
                color: speedColor.withOpacity(0.125),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                speedStatus,
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: speedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(100),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressFactor.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: speedColor,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Speed Labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: Color(0xFF6A7282),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
              Text(
                '40',
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: Color(0xFF6A7282),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
              Text(
                '80 km/h',
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: Color(0xFF6A7282),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMapContainer() {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(
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
                  child: CustomPaint(
                    painter: _GridPainter(),
                    child: Container(),
                  ),
                ),
                // Map Icon Placeholder
                Center(
                  child: Icon(
                    Icons.map_outlined,
                    size: 200,
                    color: colorScheme.outlineVariant.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
        // GPS Active Badge (top right)
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12.65, 8.65, 12.65, 8.65),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 0.65,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.map_outlined, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'GPS Active',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                  ),
                ),
                const SizedBox(width: 8),
                // Signal Bars
                Row(
                  children: List.generate(4, (index) {
                    final heights = [3.0, 6.0, 9.0, 12.0];
                    final opacities = [0.96, 0.91, 0.84, 0.76];
                    return Container(
                      width: 4,
                      height: heights[index],
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(
                          opacities[index],
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        // Total Distance Card (bottom left)
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16.65, 12.65, 16.65, 12.65),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 0.65,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Jarak',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                    Text(
                      '${_distance.toStringAsFixed(2)} km',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.56,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      children: [
        // Stats Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.access_time,
                iconColor: const Color(0xFF6B7C4F),
                label: 'Waktu',
                value: _formatDuration(_duration),
                unit: '',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.speed,
                iconColor: const Color(0xFF51A2FF),
                label: 'Rata-rata',
                value: _averageSpeed.toStringAsFixed(0),
                unit: 'km/h',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.bolt,
                iconColor: const Color(0xFFFFB900),
                label: 'Maksimal',
                value: _maxSpeed.toStringAsFixed(0),
                unit: 'km/h',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Live Performance Card
        _buildPerformanceCard(),
        const SizedBox(height: 12),
        // Stop Tracking Button
        _buildStopButton(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPerformanceCard() {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine performance text
    String performanceText = 'Kecepatan saat ini ';
    String comparisonText = 'sama dengan ';
    String contextText = 'rata-rata';

    if (_averageSpeed > 0) {
      if (_currentSpeed > _averageSpeed + 5) {
        comparisonText = 'lebih cepat ';
      } else if (_currentSpeed < _averageSpeed - 5) {
        comparisonText = 'lebih lambat ';
      } else {
        comparisonText = 'sama dengan ';
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16.65, 16.65, 16.65, 16.65),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.trending_up,
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
                  'Live Performance',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.62,
                    ),
                    children: [
                      TextSpan(
                        text: performanceText,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      TextSpan(
                        text: comparisonText,
                        style: TextStyle(color: colorScheme.primary),
                      ),
                      TextSpan(
                        text: contextText,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: Color(0xFF6A7282),
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

  Widget _buildStopButton() {
    return InkWell(
      onTap: _stopTracking,
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFE7000B), Color(0xFFC10007)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFB2C36).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 10),
              spreadRadius: -3,
            ),
            BoxShadow(
              color: const Color(0xFFFB2C36).withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
              spreadRadius: -4,
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stop, size: 24, color: Color(0xFFFFFFFF)),
            SizedBox(width: 12),
            Text(
              'Selesai & Simpan',
              style: TextStyle(
                fontFamily: 'Arial',
                color: Color(0xFFFFFFFF),
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
}

// Custom painter for grid overlay
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    // Draw horizontal lines with varying opacity
    for (int i = 0; i <= 10; i++) {
      final y = (size.height / 10) * i;
      final opacity = 0.58 - (i * 0.02);
      paint.color = Colors.white.withOpacity(opacity.clamp(0.5, 0.72));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines with varying opacity
    for (int i = 0; i <= 12; i++) {
      final x = (size.width / 12) * i;
      final opacity = 0.58 - (i * 0.02);
      paint.color = Colors.white.withOpacity(opacity.clamp(0.5, 0.72));
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
