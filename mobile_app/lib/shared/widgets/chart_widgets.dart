import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Widget สำหรับแสดง Line Chart
class GACPLineChart extends StatelessWidget {
  final List<FlSpot> data;
  final String? title;
  final List<String>? xLabels;
  final double minY;
  final double maxY;
  final bool isLoading;
  final String? error;

  const GACPLineChart({
    super.key,
    required this.data,
    this.title,
    this.xLabels,
    this.minY = 0,
    this.maxY = 100,
    this.isLoading = false,
    this.error,
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
            SizedBox(
              height: 220,
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
                            return Text(xLabels![value.toInt()],
                                style: Theme.of(context).textTheme.bodySmall);
                          }
                          return const SizedBox.shrink();
                        },
                        interval: 1,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget สำหรับแสดง Bar Chart
class GACPBarChart extends StatelessWidget {
  final List<BarChartGroupData> data;
  final String? title;
  final List<String>? xLabels;
  final double minY;
  final double maxY;
  final bool isLoading;
  final String? error;

  const GACPBarChart({
    super.key,
    required this.data,
    this.title,
    this.xLabels,
    this.minY = 0,
    this.maxY = 100,
    this.isLoading = false,
    this.error,
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
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
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
                            return Text(xLabels![value.toInt()],
                                style: Theme.of(context).textTheme.bodySmall);
                          }
                          return const SizedBox.shrink();
                        },
                        interval: 1,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  barGroups: data,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}