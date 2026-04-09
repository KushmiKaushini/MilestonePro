import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Line/area chart showing milestones completed per week over 12 weeks.
class VelocityChart extends StatelessWidget {
  const VelocityChart({super.key, required this.weeklyData});

  /// 12 values, index 0 = oldest week.
  final List<int> weeklyData;

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      weeklyData.length,
      (i) => FlSpot(i.toDouble(), weeklyData[i].toDouble()),
    );

    final maxY = weeklyData.fold(0, (m, v) => v > m ? v : m).toDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: maxY < 1 ? 5 : maxY + 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY < 4 ? 1 : (maxY / 4).ceilToDouble(),
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxY < 4 ? 1 : (maxY / 4).ceilToDouble(),
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}',
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (v, _) {
                final weeksAgo = 11 - v.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    weeksAgo == 0 ? 'Now' : 'W-$weeksAgo',
                    style: const TextStyle(
                        color: AppColors.textHint, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                radius: 3,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: AppColors.background,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.28),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.cardElevated,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${s.y.toInt()} completed',
                      const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
