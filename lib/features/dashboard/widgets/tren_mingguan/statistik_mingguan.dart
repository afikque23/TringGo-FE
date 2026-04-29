import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../l10n/app_localizations.dart';
import 'pola_mingguan.dart';
import '../../../widget/page_transition.dart';

class StatistikMingguanPage extends StatefulWidget {
  const StatistikMingguanPage({super.key});

  @override
  State<StatistikMingguanPage> createState() => _StatistikMingguanPageState();
}

class _StatistikMingguanPageState extends State<StatistikMingguanPage> {
  int _selectedTabIndex = 0;

  final List<FlSpot> weeklyData = [
    const FlSpot(0, 15),
    const FlSpot(1, 12),
    const FlSpot(2, 28),
    const FlSpot(3, 8),
    const FlSpot(4, 22),
    const FlSpot(5, 35),
    const FlSpot(6, 10),
  ];

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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    _buildStatsGrid(),
                    const SizedBox(height: 16),
                    _buildWeeklyChart(),
                    const SizedBox(height: 16),
                    _buildPeakActivityCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerLow),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ridingInsights,
                      style: TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'My Ninja',
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTabButton(l10n.weeklyStats, 0)),
                const SizedBox(width: 8),
                Expanded(child: _buildTabButton(l10n.patterns, 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          // Navigate to Patterns page
          Navigator.pushReplacement(
            context,
            SmoothPageRoute(page: const PolaMingguanPage()),
          );
        } else {
          setState(() {
            _selectedTabIndex = index;
          });
        }
      },
      child: Container(
        height: 36,
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

  Widget _buildStatsGrid() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.map_outlined,
                label: l10n.totalDistanceWeek,
                value: '78',
                unit: l10n.kilometers,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today_outlined,
                label: l10n.avgTrip,
                value: '39.0',
                unit: l10n.kmPerTrip,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.access_time,
                label: l10n.totalTime,
                value: '1',
                unit: l10n.hoursRiding,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildStatCard(
                icon: Icons.speed,
                label: l10n.avgSpeed,
                value: '41.5',
                unit: 'km/h',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
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
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.33,
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
              fontFamily: 'Arial',
              fontSize: 24,
              fontWeight: FontWeight.w400,
              height: 1.33,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 0),
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final l10n = AppLocalizations.of(context)!;
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
              Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Weekly Distance',
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
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => colorScheme.surface,
                    tooltipPadding: const EdgeInsets.all(12),
                    tooltipMargin: 8,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final days = [
                          l10n.mon,
                          l10n.tue,
                          l10n.wed,
                          l10n.thu,
                          l10n.fri,
                          l10n.sat,
                          l10n.sun,
                        ];
                        final dayName = days[touchedSpot.x.toInt()];
                        final distance = touchedSpot.y.toInt();
                        return LineTooltipItem(
                          '$dayName\n',
                          TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Distance : ',
                              style: TextStyle(
                                color: Color(0xFF6B7C4F),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: '$distance km',
                              style: const TextStyle(
                                color: Color(0xFF6B7C4F),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((spotIndex) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: const Color(0xFFFFFFFF),
                              strokeWidth: 2,
                            ),
                            FlDotData(
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 6,
                                  color: const Color(0xFFFFFFFF),
                                  strokeWidth: 2,
                                  strokeColor: const Color(0xFF6B7C4F),
                                );
                              },
                            ),
                          );
                        }).toList();
                      },
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF2A2A2A),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF2A2A2A),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final l10n = AppLocalizations.of(context)!;
                        const style = TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF666666),
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = Text(l10n.mon, style: style);
                            break;
                          case 1:
                            text = Text(l10n.tue, style: style);
                            break;
                          case 2:
                            text = Text(l10n.wed, style: style);
                            break;
                          case 3:
                            text = Text(l10n.thu, style: style);
                            break;
                          case 4:
                            text = Text(l10n.fri, style: style);
                            break;
                          case 5:
                            text = Text(l10n.sat, style: style);
                            break;
                          case 6:
                            text = Text(l10n.sun, style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        return text;
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF666666),
                        );
                        return Text(
                          value.toInt().toString(),
                          style: style,
                          textAlign: TextAlign.right,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xFF666666)),
                ),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 80,
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklyData,
                    isCurved: true,
                    color: const Color(0xFF6B7C4F),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPeakActivityCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16.65, 16.65, 16.65, 0.65),
      decoration: BoxDecoration(
        color: const Color(0xFF6B7C4F).withValues(alpha: 0.1),
        border: Border.all(color: const Color(0xFF6B7C4F), width: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outlined,
                size: 20,
                color: Color(0xFF6B7C4F),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.peakActivity,
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                        color: Color(0xFF6B7C4F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                          color: Color(0xFF99A1AF),
                        ),
                        children: [
                          TextSpan(text: l10n.mostActiveDay),
                          const TextSpan(
                            text: 'Saturday',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7C4F),
                            ),
                          ),
                          TextSpan(text: l10n.withAverage),
                          const TextSpan(
                            text: '35 km',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7C4F),
                            ),
                          ),
                          TextSpan(text: '.'),
                        ],
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
