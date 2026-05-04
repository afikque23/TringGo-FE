import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class DetailTripPage extends StatelessWidget {
  final Map<String, dynamic> tripData;

  const DetailTripPage({super.key, required this.tripData});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMapContainer(context),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Column(
                      children: [
                        _buildDateSection(context),
                        const SizedBox(height: 16),
                        _buildStatsRow(context),
                        const SizedBox(height: 16),
                        _buildSpeedStats(context),
                        const SizedBox(height: 16),
                        _buildRouteInfo(context),
                        const SizedBox(height: 16),
                        _buildSummaryCard(context),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerLow),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tripDetail,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  tripData['vehicle'] ?? 'My Ninja',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapContainer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final rawPoints = tripData['routePoints'];
    final routePoints = <RoutePoint>[];
    if (rawPoints is List) {
      for (final item in rawPoints) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final latRaw = map['lat'];
        final lngRaw = map['lng'];
        final lat = latRaw is num
            ? latRaw.toDouble()
            : double.tryParse('$latRaw');
        final lng = lngRaw is num
            ? lngRaw.toDouble()
            : double.tryParse('$lngRaw');
        if (lat == null || lng == null) continue;
        routePoints.add(RoutePoint(lat, lng));
      }
    }

    return Container(
      width: double.infinity,
      height: 256,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surface,
                  colorScheme.surfaceContainerHighest,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // Grid overlay
          Positioned.fill(child: CustomPaint(painter: GridPainter())),
          // Route polyline
          if (routePoints.length >= 2)
            Positioned.fill(
              child: CustomPaint(
                painter: RoutePolylinePainter(
                  points: routePoints,
                  color: colorScheme.primary,
                  startColor: colorScheme.primary,
                  endColor: colorScheme.tertiary,
                ),
              ),
            )
          else
            Center(
              child: Icon(
                Icons.route,
                size: 80,
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20.65, 20.65, 20.65, 0.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.date,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              tripData['fullDate'] ?? tripData['shortDate'] ?? '-',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 18,
                fontWeight: FontWeight.w400,
                height: 1.56,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final distanceValue = (tripData['distanceValue'] ?? '0').toString();
    final durationMinutes = (tripData['durationMinutes'] ?? '0').toString();
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.map_outlined,
            label: l10n.totalDistance,
            value: distanceValue,
            unit: 'kilometer',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.access_time,
            label: l10n.duration,
            value: durationMinutes,
            unit: 'min',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20.65, 20.65, 20.65, 0.65),
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
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 30,
              fontWeight: FontWeight.w400,
              height: 1.2,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 0),
          Text(
            unit,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.43,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSpeedStats(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20.65, 20.65, 20.65, 0.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.speed, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.speedStatistics,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            context,
            l10n.averageSpeed,
            '${(tripData["averageSpeedKph"] ?? "0").toString()} km/h',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            context,
            l10n.maxSpeedEstimate,
            '${(tripData["maxSpeedKph"] ?? "0").toString()} km/h',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Arial',
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.56,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    String formatLatLng(dynamic lat, dynamic lng) {
      if (lat == null || lng == null) return l10n.locationRecorded;
      final latNum = lat is num
          ? lat.toDouble()
          : double.tryParse(lat.toString());
      final lngNum = lng is num
          ? lng.toDouble()
          : double.tryParse(lng.toString());
      if (latNum == null || lngNum == null) return l10n.locationRecorded;
      return '${latNum.toStringAsFixed(5)}, ${lngNum.toStringAsFixed(5)}';
    }

    final startText = formatLatLng(tripData['startLat'], tripData['startLng']);
    final endText = formatLatLng(tripData['endLat'], tripData['endLng']);
    final startTime = (tripData['startTime'] ?? '').toString();
    final endTime = (tripData['endTime'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.fromLTRB(20.65, 20.65, 20.65, 0.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.routeInformation,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.start,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                startTime.isNotEmpty ? '$startText • $startTime' : startText,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 12),
              Text(
                l10n.finish,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                endTime.isNotEmpty ? '$endText • $endTime' : endText,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final distanceValue = (tripData['distanceValue'] ?? '0').toString();
    final durationMinutes = (tripData['durationMinutes'] ?? '0').toString();
    final avgSpeedKph = (tripData['averageSpeedKph'] ?? '0').toString();

    final hours = int.tryParse(durationMinutes) != null
        ? (int.parse(durationMinutes) ~/ 60)
        : 0;
    final minutes = int.tryParse(durationMinutes) != null
        ? (int.parse(durationMinutes) % 60)
        : 0;
    final durationText = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Container(
      padding: const EdgeInsets.fromLTRB(16.65, 16.65, 16.65, 0.65),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(color: colorScheme.primary, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
                color: colorScheme.primary,
              ),
              children: [
                TextSpan(text: l10n.tripSummary),
                TextSpan(
                  text: '$distanceValue km ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                TextSpan(text: l10n.tripSummary2),
                TextSpan(
                  text: '$durationText ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                TextSpan(text: l10n.tripSummary3),
                TextSpan(
                  text: '$avgSpeedKph km/h',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Custom painter for grid overlay on map
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Draw horizontal lines
    for (int i = 0; i <= 8; i++) {
      double y = (size.height / 8) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (int i = 0; i <= 8; i++) {
      double x = (size.width / 8) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoutePoint {
  final double lat;
  final double lng;
  const RoutePoint(this.lat, this.lng);
}

class RoutePolylinePainter extends CustomPainter {
  final List<RoutePoint> points;
  final Color color;
  final Color startColor;
  final Color endColor;

  const RoutePolylinePainter({
    required this.points,
    required this.color,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    const padding = 18.0;
    final rect = Rect.fromLTWH(
      padding,
      padding,
      size.width - (padding * 2),
      size.height - (padding * 2),
    );
    if (rect.width <= 0 || rect.height <= 0) return;

    double minLat = points.first.lat;
    double maxLat = points.first.lat;
    double minLng = points.first.lng;
    double maxLng = points.first.lng;

    for (final p in points) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }

    final latRange = (maxLat - minLat).abs();
    final lngRange = (maxLng - minLng).abs();

    // Expand a tiny bit so start/end aren't stuck to edges
    final safeLatRange = latRange < 1e-9 ? 1.0 : latRange;
    final safeLngRange = lngRange < 1e-9 ? 1.0 : lngRange;

    final scaleX = rect.width / safeLngRange;
    final scaleY = rect.height / safeLatRange;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final contentW = safeLngRange * scale;
    final contentH = safeLatRange * scale;

    final dx = rect.left + (rect.width - contentW) / 2;
    final dy = rect.top + (rect.height - contentH) / 2;

    Offset project(RoutePoint p) {
      // x: west->east increasing
      final x = dx + ((p.lng - minLng) * scale);
      // y: north->south; invert lat so larger lat is higher on screen
      final y = dy + ((maxLat - p.lat) * scale);
      return Offset(x, y);
    }

    final startOffset = project(points.first);
    final endOffset = project(points.last);

    final path = Path()..moveTo(startOffset.dx, startOffset.dy);
    for (int i = 1; i < points.length; i++) {
      final o = project(points[i]);
      path.lineTo(o.dx, o.dy);
    }

    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: 0.18);
    canvas.drawPath(path, shadowPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: 0.95);
    canvas.drawPath(path, linePaint);

    // Start/End markers
    final markerBg = Paint()..color = color.withValues(alpha: 0.22);
    canvas.drawCircle(startOffset, 7.0, markerBg);
    canvas.drawCircle(endOffset, 7.0, markerBg);

    final startPaint = Paint()..color = startColor.withValues(alpha: 0.95);
    final endPaint = Paint()..color = endColor.withValues(alpha: 0.95);
    canvas.drawCircle(startOffset, 5.0, startPaint);
    canvas.drawCircle(endOffset, 5.0, endPaint);
  }

  @override
  bool shouldRepaint(covariant RoutePolylinePainter oldDelegate) {
    return oldDelegate.points.length != points.length ||
        oldDelegate.color != color ||
        oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor;
  }
}
