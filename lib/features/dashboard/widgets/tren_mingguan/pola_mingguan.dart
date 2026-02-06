import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../l10n/app_localizations.dart';
import 'statistik_mingguan.dart';
import '../../../widget/page_transition.dart';

class PolaMingguanPage extends StatefulWidget {
  const PolaMingguanPage({super.key});

  @override
  State<PolaMingguanPage> createState() => _PolaMingguanPageState();
}

class _PolaMingguanPageState extends State<PolaMingguanPage> {
  int _selectedTabIndex = 1; // Patterns tab is active

  // Sample data for hourly riding patterns (trips per hour)
  final List<double> hourlyData = [4, 7, 3, 5, 8, 4];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: colorScheme.surfaceContainerLow),
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button, title, and subtitle
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.ridingInsights,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'My Ninja',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tab buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to Weekly Stats page
                            Navigator.pushReplacement(
                              context,
                              SmoothPageRoute(
                                page: const StatistikMingguanPage(),
                              ),
                            );
                          },
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 0
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerLow,
                              border: Border.all(
                                color: _selectedTabIndex == 0
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.weeklyStats,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: _selectedTabIndex == 0
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 1),
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 1
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerLow,
                              border: Border.all(
                                color: _selectedTabIndex == 1
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              l10n.patterns,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: _selectedTabIndex == 1
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats Grid (2x2)
                  SizedBox(
                    height: 230,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.trending_up,
                                  label: l10n.totalDistanceWeek,
                                  value: '78',
                                  unit: l10n.kilometers,
                                  context: context,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.route,
                                  label: l10n.avgTrip,
                                  value: '39.0',
                                  unit: l10n.kmPerTrip,
                                  context: context,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.access_time,
                                  label: l10n.totalTime,
                                  value: '1',
                                  unit: l10n.hoursRiding,
                                  context: context,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.speed,
                                  label: l10n.avgSpeed,
                                  value: '41.5',
                                  unit: 'km/h',
                                  context: context,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Riding Time Patterns Chart
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 0.65,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.fromLTRB(21, 21, 21, 1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chart title
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.ridingTimePatterns,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Bar Chart
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 8,
                              minY: 0,
                              barTouchData: BarTouchData(
                                enabled: true,
                                handleBuiltInTouches: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (group) =>
                                      colorScheme.surface,
                                  tooltipPadding: const EdgeInsets.all(12),
                                  tooltipMargin: 8,
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                        final l10n = AppLocalizations.of(
                                          context,
                                        )!;
                                        const labels = [
                                          '6AM',
                                          '9AM',
                                          '12PM',
                                          '3PM',
                                          '6PM',
                                          '9PM',
                                        ];
                                        final timeLabel = labels[groupIndex];
                                        final trips = rod.toY.toInt();
                                        return BarTooltipItem(
                                          '$timeLabel\n',
                                          TextStyle(
                                            color: colorScheme.onSurface,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  '${l10n.tripsLabel} : $trips trips',
                                              style: const TextStyle(
                                                color: Color(0xFF6B7C4F),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const labels = [
                                        '6AM',
                                        '9AM',
                                        '12PM',
                                        '3PM',
                                        '6PM',
                                        '9PM',
                                      ];
                                      if (value.toInt() >= 0 &&
                                          value.toInt() < labels.length) {
                                        return Text(
                                          labels[value.toInt()],
                                          style: const TextStyle(
                                            color: Color(0xFF666666),
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 25,
                                    interval: 2,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          color: Color(0xFF666666),
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                        ),
                                        textAlign: TextAlign.right,
                                      );
                                    },
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                horizontalInterval: 2,
                                verticalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return const FlLine(
                                    color: Color(0xFF2A2A2A),
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return const FlLine(
                                    color: Color(0xFF2A2A2A),
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                  );
                                },
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: const Border(
                                  left: BorderSide(
                                    color: Color(0xFF666666),
                                    width: 1,
                                  ),
                                  bottom: BorderSide(
                                    color: Color(0xFF666666),
                                    width: 1,
                                  ),
                                ),
                              ),
                              barGroups: List.generate(
                                hourlyData.length,
                                (index) => BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: hourlyData[index],
                                      color: const Color(0xFF6B7C4F),
                                      width: 30,
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Insight Cards
                  _buildInsightCard(
                    title: l10n.eveningCommuter,
                    description: l10n.eveningCommuterDesc,
                    borderColor: colorScheme.primary,
                    context: context,
                  ),
                  const SizedBox(height: 12),
                  _buildInsightCard(
                    title: l10n.shortTripPattern,
                    description: l10n.shortTripPatternDesc,
                    borderColor: const Color(0xFFFE9A00),
                    context: context,
                  ),
                  const SizedBox(height: 12),
                  _buildInsightCard(
                    title: l10n.optimalServiceWindow,
                    description: l10n.optimalServiceWindowDesc,
                    borderColor: colorScheme.primary,
                    context: context,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildStatCard({
  required IconData icon,
  required String label,
  required String value,
  required String unit,
  required BuildContext context,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
    decoration: BoxDecoration(
      color: colorScheme.surface,
      border: Border.all(color: colorScheme.outlineVariant, width: 0.65),
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.fromLTRB(17, 17, 17, 1),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

Widget _buildInsightCard({
  required String title,
  required String description,
  required Color borderColor,
  required BuildContext context,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: colorScheme.surface,
      border: Border(left: BorderSide(color: borderColor, width: 4)),
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
            height: 1.43,
          ),
        ),
      ],
    ),
  );
}
