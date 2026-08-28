import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/geocoding_service.dart';

class DetailTripPage extends StatelessWidget {
  final Map<String, dynamic> tripData;

  const DetailTripPage({super.key, required this.tripData});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<dynamic>? routePoints = tripData['routePoints'];
    final bool isManualTrip = routePoints == null || routePoints.length <= 1;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMapContainer(context, isManualTrip),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Column(
                      children: [
                        _buildDateSection(context),
                        const SizedBox(height: 16),
                        _buildStatsRow(context),
                        const SizedBox(height: 16),
                        _buildSpeedStats(context, isManualTrip),
                        // Suhu mesin DS18B20 — tampil jika ada data suhu di tripData
                        if (tripData['engineTempC'] != null ||
                            tripData.containsKey('engineTempC') ||
                            tripData['engine_temp_c'] != null ||
                            tripData.containsKey('engine_temp_c')) ...[
                          const SizedBox(height: 16),
                          _buildEngineTempCard(context),
                        ],
                        if (!isManualTrip) ...[
                          const SizedBox(height: 16),
                          _buildRouteInfo(context, isManualTrip),
                        ],
                        const SizedBox(height: 16),
                        _buildSummaryCard(context, isManualTrip),
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

  Widget _buildMapContainer(BuildContext context, bool isManualTrip) {
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

    if (isManualTrip) return const SizedBox.shrink();

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

          if (routePoints.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                    routePoints.first.lat,
                    routePoints.first.lng,
                  ),
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints
                            .map((p) => LatLng(p.lat, p.lng))
                            .toList(),
                        strokeWidth: 4.0,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          routePoints.first.lat,
                          routePoints.first.lng,
                        ),
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      if (routePoints.length > 1)
                        Marker(
                          point: LatLng(
                            routePoints.last.lat,
                            routePoints.last.lng,
                          ),
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.stop,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Peta Tidak Tersedia',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildSpeedStats(BuildContext context, bool isManualTrip) {
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
          if (!isManualTrip) ...[
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              l10n.maxSpeedEstimate,
              '${(tripData["maxSpeedKph"] ?? "0").toString()} km/h',
            ),
          ],
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

  Widget _buildEngineTempCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rawTemp = tripData['engine_temp_c'] ?? tripData['engineTempC'] ?? tripData['avg_temperature_c'];
    final rawMax = tripData['max_engine_temp_c'] ?? tripData['maxEngineTempC'] ?? tripData['max_temperature_c'];
    final rawMin = tripData['min_engine_temp_c'] ?? tripData['minEngineTempC'] ?? tripData['min_temperature_c'];

    final temp = rawTemp is num ? rawTemp.toDouble() : double.tryParse(rawTemp?.toString() ?? '');
    final maxTemp = rawMax is num ? rawMax.toDouble() : double.tryParse(rawMax?.toString() ?? '');
    final minTemp = rawMin is num ? rawMin.toDouble() : double.tryParse(rawMin?.toString() ?? '');

    final overheat = tripData['engine_overheat'] == true || tripData['engineOverheat'] == true;

    if (temp == null) {
      return Container(
        padding: const EdgeInsets.all(20.65),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.thermostat, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Suhu Mesin',
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.thermostat_outlined, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Data tidak tersedia',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20.65, 20.65, 20.65, 20.65),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.thermostat, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Suhu Mesin',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (overheat || temp >= 110.0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'OVERHEAT',
                    style: TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTempBox(
                  context, 
                  label: 'Terendah', 
                  value: minTemp ?? temp, 
                  icon: Icons.ac_unit, 
                  color: Colors.lightBlue
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTempBox(
                  context, 
                  label: 'Rata-rata', 
                  value: temp, 
                  icon: Icons.thermostat, 
                  color: (temp >= 110.0 || overheat) ? Colors.redAccent : (temp >= 90.0 ? Colors.orange : colorScheme.primary)
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTempBox(
                  context, 
                  label: 'Tertinggi', 
                  value: maxTemp ?? temp, 
                  icon: Icons.local_fire_department, 
                  color: ((maxTemp ?? temp) >= 110.0 || overheat) ? Colors.redAccent : Colors.orange
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTempBox(BuildContext context, {required String label, required double value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            '${value.toStringAsFixed(1)}°',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(BuildContext context, bool isManualTrip) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final startLatRaw = tripData['startLat'];
    final startLngRaw = tripData['startLng'];
    final endLatRaw = tripData['endLat'];
    final endLngRaw = tripData['endLng'];

    final startLat = startLatRaw is num ? startLatRaw.toDouble() : double.tryParse(startLatRaw?.toString() ?? '');
    final startLng = startLngRaw is num ? startLngRaw.toDouble() : double.tryParse(startLngRaw?.toString() ?? '');
    final endLat = endLatRaw is num ? endLatRaw.toDouble() : double.tryParse(endLatRaw?.toString() ?? '');
    final endLng = endLngRaw is num ? endLngRaw.toDouble() : double.tryParse(endLngRaw?.toString() ?? '');

    final startTime = (tripData['startTime'] ?? '').toString();
    final endTime = (tripData['endTime'] ?? '').toString();

    Widget buildAddressRow(String label, double? lat, double? lng, String time) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 4),
          if (lat != null && lng != null)
            FutureBuilder<String>(
              future: GeocodingService.getAddressFromLatLng(lat, lng),
              builder: (context, snapshot) {
                final address = snapshot.data ?? '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
                final text = time.isNotEmpty ? '$address • $time' : address;
                
                return Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: colorScheme.onSurface,
                  ),
                );
              },
            )
          else
            Text(
              time.isNotEmpty ? '${l10n.locationRecorded} • $time' : l10n.locationRecorded,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: colorScheme.onSurface,
              ),
            ),
        ],
      );
    }

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
          buildAddressRow(l10n.start, startLat, startLng, startTime),
          const SizedBox(height: 12),
          Container(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          buildAddressRow(l10n.finish, endLat, endLng, endTime),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, bool isManualTrip) {
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

class RoutePoint {
  final double lat;
  final double lng;
  const RoutePoint(this.lat, this.lng);
}
