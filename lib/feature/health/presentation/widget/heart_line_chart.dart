import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HeartRateLineChart extends StatelessWidget {
  const HeartRateLineChart({
    Key? key,
    required this.values,
    this.color = Colors.red,
  }) : super(key: key);

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    final spots = List.generate(
      values.length,
      (i) => FlSpot(i.toDouble(), values[i]),
    );

    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minY: minY - 5,
        maxY: maxY + 5,
        gridData: FlGridData(show: false), // No grid
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 5,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
