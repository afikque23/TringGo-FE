import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'detail_trip.dart';
import '../../../widget/page_transition.dart';

class RiwayatTripPage extends StatefulWidget {
  const RiwayatTripPage({super.key});

  @override
  State<RiwayatTripPage> createState() => _RiwayatTripPageState();
}

class _RiwayatTripPageState extends State<RiwayatTripPage> {
  int _selectedFilterIndex = 0;

  final List<Map<String, dynamic>> _trips = [
    {
      'vehicle': 'My Ninja',
      'date': 'today',
      'distance': '0.37 km',
      'duration': '33m',
      'avgSpeed': 'Avg: 41.9 km/h',
    },
    {
      'vehicle': 'My Ninja',
      'date': 'yesterday',
      'distance': '45.2 km',
      'duration': '1h 5m',
      'avgSpeed': 'Avg: 42 km/h',
    },
    {
      'vehicle': 'My Ninja',
      'date': 'Jan 23, 2026',
      'distance': '32.8 km',
      'duration': '48m',
      'avgSpeed': 'Avg: 41 km/h',
    },
    {
      'vehicle': 'Daily Commuter',
      'date': 'Jan 22, 2026',
      'distance': '18.5 km',
      'duration': '35m',
      'avgSpeed': 'Avg: 32 km/h',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
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

  Widget _buildStatsCards() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(child: _buildStatCard(l10n.trip, '4')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(l10n.distance, '97', unit: 'km')),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            l10n.duration,
            '3',
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
    return Column(
      children: _trips.map((trip) => _buildTripItem(trip)).toList(),
    );
  }

  Widget _buildTripItem(Map<String, dynamic> trip) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    // Translate date labels
    String dateLabel = trip['date'];
    if (dateLabel == 'today') {
      dateLabel = l10n.today;
    } else if (dateLabel == 'yesterday') {
      dateLabel = l10n.yesterday;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SmoothPageRoute(page: DetailTripPage(tripData: trip)),
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
                      trip['vehicle'],
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
                          dateLabel,
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
                      trip['distance'],
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
                      trip['duration'],
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
                  trip['avgSpeed'],
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
