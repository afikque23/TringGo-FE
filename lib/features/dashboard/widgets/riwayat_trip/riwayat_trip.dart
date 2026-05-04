import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/tracking_service.dart';
import '../../../../core/model/trip_model.dart';
import 'detail_trip.dart';
import '../../../widget/page_transition.dart';

class RiwayatTripPage extends StatefulWidget {
  const RiwayatTripPage({super.key});

  @override
  State<RiwayatTripPage> createState() => _RiwayatTripPageState();
}

class _RiwayatTripPageState extends State<RiwayatTripPage> {
  final TrackingService _trackingService = TrackingService();
  int _selectedFilterIndex = 0;
  List<TripModel> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTripHistory();
  }

  Future<void> _loadTripHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trips = await _trackingService.getTripHistory();
      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading trips: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTripHistory,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Column(
                    children: [
                      _buildStatsCards(),
                      const SizedBox(height: 16),
                      _buildTripsList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerLow),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Back button and title
            Row(
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
                Text(
                  l10n.tripHistory,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            // Filter buttons
            Row(
              children: [
                Expanded(child: _buildFilterButton(l10n.allTime, 0)),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterButton(l10n.thisWeekFilter, 1)),
                const SizedBox(width: 8),
                Expanded(child: _buildFilterButton(l10n.thisMonthFilter, 2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerLow,
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.43,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  List<TripModel> _getFilteredTrips() {
    final now = DateTime.now();
    switch (_selectedFilterIndex) {
      case 1: // This Week
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return _trips
            .where((trip) => trip.startTime.isAfter(weekStart))
            .toList();
      case 2: // This Month
        final monthStart = DateTime(now.year, now.month, 1);
        return _trips
            .where((trip) => trip.startTime.isAfter(monthStart))
            .toList();
      default: // All Time
        return _trips;
    }
  }

  Widget _buildStatsCards() {
    final l10n = AppLocalizations.of(context)!;
    final filteredTrips = _getFilteredTrips();

    final totalTrips = filteredTrips.length;
    final totalDistance = filteredTrips.fold<double>(
      0,
      (sum, trip) => sum + trip.totalDistance,
    );
    final totalDuration = filteredTrips.fold<Duration>(
      Duration.zero,
      (sum, trip) => sum + Duration(seconds: trip.duration),
    );

    return Row(
      children: [
        Expanded(child: _buildStatCard(l10n.trip, totalTrips.toString())),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            l10n.distance,
            totalDistance.toStringAsFixed(1),
            unit: 'km',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            l10n.duration,
            (totalDuration.inMinutes / 60).toStringAsFixed(1),
            unit: l10n.hoursRiding.split(' ')[0],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, {String? unit}) {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                  color: colorScheme.onSurface,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
                    color: colorScheme.onSurfaceVariant,
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

  Widget _buildTripsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final filteredTrips = _getFilteredTrips();

    if (filteredTrips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Belum ada riwayat perjalanan',
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: filteredTrips.map((trip) => _buildTripItem(trip)).toList(),
    );
  }

  String _formatTripDate(DateTime date) {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context)!;

    // Check if today
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return l10n.today;
    }

    // Check if yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return l10n.yesterday;
    }

    // Format as date
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildTripItem(TripModel trip) {
    final colorScheme = Theme.of(context).colorScheme;
    final endTime = trip.endTimeForDisplay;
    final vehicleName = trip.motorcycleName.isNotEmpty
        ? trip.motorcycleName
        : 'My Motorcycle';

    final startPoint = trip.points.isNotEmpty ? trip.points.first : null;
    final endPoint = trip.points.isNotEmpty ? trip.points.last : null;

    return GestureDetector(
      onTap: () {
        // Convert TripModel to Map for DetailTripPage
        final tripData = {
          'vehicle': vehicleName,
          'fullDate': DateFormat('EEEE, MMMM d, yyyy').format(trip.startTime),
          'shortDate': _formatTripDate(trip.startTime),
          'distanceValue': trip.totalDistance.toStringAsFixed(1),
          'durationMinutes': (trip.duration / 60).round().toString(),
          'averageSpeedKph': trip.averageSpeed.toStringAsFixed(0),
          'maxSpeedKph': trip.maxSpeed.toStringAsFixed(0),
          'startTime': DateFormat('HH:mm').format(trip.startTime),
          'endTime': DateFormat('HH:mm').format(endTime),
          'routePoints': trip.points
              .map((p) => {'lat': p.latitude, 'lng': p.longitude})
              .toList(),
          if (startPoint != null) ...{
            'startLat': startPoint.latitude,
            'startLng': startPoint.longitude,
          },
          if (endPoint != null) ...{
            'endLat': endPoint.latitude,
            'endLng': endPoint.longitude,
          },
        };

        Navigator.push(
          context,
          SmoothPageRoute(page: DetailTripPage(tripData: tripData)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16.65),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            // Header with vehicle name and menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicleName,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTripDate(trip.startTime),
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${DateFormat('HH:mm').format(trip.startTime)} - ${DateFormat('HH:mm').format(endTime)}',
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
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Trip details
            Row(
              children: [
                // Distance
                Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${trip.totalDistance.toStringAsFixed(2)} km',
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Duration
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trip.formattedDuration,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Average speed
                Text(
                  'Avg: ${trip.averageSpeed.toStringAsFixed(1)} km/h',
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
}
