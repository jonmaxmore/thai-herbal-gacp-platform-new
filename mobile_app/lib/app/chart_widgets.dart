import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Line Chart Widget (Production-ready)
class GACPLineChart extends StatelessWidget {
  final List<FlSpot> data;
  final String? title;
  final List<String>? xLabels;
  final double minY;
  final double maxY;
  final bool isLoading;
  final String? error;
  final Color? lineColor;
  final Color? backgroundColor;
  final double barWidth;
  final bool showDots;
  final bool showGrid;
  final bool animate;
  final double? aspectRatio;

  const GACPLineChart({
    super.key,
    required this.data,
    this.title,
    this.xLabels,
    this.minY = 0,
    this.maxY = 100,
    this.isLoading = false,
    this.error,
    this.lineColor,
    this.backgroundColor,
    this.barWidth = 3,
    this.showDots = false,
    this.showGrid = true,
    this.animate = true,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Text(
          error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      color: backgroundColor ?? Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            AspectRatio(
              aspectRatio: aspectRatio ?? 1.8,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (xLabels != null && value.toInt() < xLabels!.length) {
                            return Text(
                              xLabels![value.toInt()],
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        interval: 1,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: showGrid),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: lineColor ?? Theme.of(context).colorScheme.primary,
                      barWidth: barWidth,
                      dotData: FlDotData(show: showDots),
                      belowBarData: BarAreaData(
                        show: true,
                        color: (lineColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.08),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      getTooltipItems: (touchedSpots) => touchedSpots
                          .map(
                            (spot) => LineTooltipItem(
                              '${xLabels != null && spot.x.toInt() < xLabels!.length ? xLabels![spot.x.toInt()] : spot.x.toString()}\n'
                              '${spot.y.toStringAsFixed(2)}',
                              const TextStyle(color: Colors.white),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                swapAnimationDuration: animate ? const Duration(milliseconds: 600) : Duration.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}