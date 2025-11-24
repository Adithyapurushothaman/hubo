import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hubo/core/routing/routes.dart';
import 'package:hubo/feature/health/presentation/notifier/vitals_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vitalsProvider);

    // compute week lists and today's values from state (fallbacks if empty)
    final recent = state.recent;
    final hrWeek = recent.isNotEmpty
        ? recent.map((e) => e.heartRate.toDouble()).toList()
        : [72, 75, 70, 74, 73, 76, 71].map((e) => e.toDouble()).toList();
    final stWeek = recent.isNotEmpty
        ? recent.map((e) => e.steps.toDouble()).toList()
        : [
            3500,
            4200,
            6000,
            8000,
            5000,
            7500,
            9000,
          ].map((e) => e.toDouble()).toList();
    final slWeek = recent.isNotEmpty
        ? recent.map((e) => e.sleepHours).toList()
        : [6.5, 7.0, 6.0, 7.5, 8.0, 6.8, 7.2];

    final hrToday = (hrWeek.isNotEmpty ? hrWeek.last.toInt() : 0);
    final stepsToday = (stWeek.isNotEmpty ? stWeek.last.toInt() : 0);
    final sleepToday = (slWeek.isNotEmpty ? slWeek.last : 0.0);

    return Scaffold(
      appBar: AppBar(title: const Text("Today's Dashboard")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppRoute.dailyVitals),
        icon: const Icon(Icons.add),
        label: const Text('Add Vitals'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Today\'s vitals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Heart Rate',
                      value: '$hrToday bpm',
                      icon: Icons.favorite,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Steps',
                      value: '$stepsToday',
                      icon: Icons.directions_walk,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Sleep',
                      value: '${sleepToday.toStringAsFixed(1)} h',
                      icon: Icons.bedtime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                '7-day overview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Heart Rate',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 160,
                        child: SimpleLineChart(
                          values: hrWeek,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Steps',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: SimpleBarChart(
                          values: stWeek,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sleep Hours',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: SimpleBarChart(
                          values: slWeek,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleLineChart extends StatelessWidget {
  const SimpleLineChart({
    Key? key,
    required this.values,
    this.color = Colors.blue,
  }) : super(key: key);

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CustomPaint(
        painter: _LineChartPainter(values: values, color: color),
        size: Size.infinite,
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    final double minV = values.reduce((a, b) => a < b ? a : b);
    final double maxV = values.reduce((a, b) => a > b ? a : b);
    final double range = (maxV - minV) == 0 ? 1 : (maxV - minV);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }

    // Draw grid lines
    final gridPaint = Paint()..color = Colors.grey.withOpacity(0.2);
    for (int i = 0; i < 4; i++) {
      final dy = i / 3 * size.height;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    canvas.drawPath(path, paint);
    // Draw points
    final dotPaint = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    Key? key,
    required this.values,
    this.color = Colors.blue,
  }) : super(key: key);

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: values.map((v) {
        final pct = maxV == 0 ? 0.0 : (v / maxV).clamp(0.0, 1.0);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              height: pct * 100,
              decoration: BoxDecoration(
                color: color.withOpacity(0.9),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
