import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hubo/core/routing/routes.dart';
import 'package:hubo/feature/auth/presentation/notifier/auth_notifier.dart';
import 'package:hubo/core/constants/palette.dart';
import 'package:hubo/feature/health/presentation/notifier/vitals_notifier.dart';
import 'package:hubo/feature/health/presentation/widget/bar_chart.dart';
import 'package:hubo/feature/health/presentation/widget/heart_line_chart.dart';
import 'package:hubo/feature/health/presentation/widget/state_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vitalsProvider);

    // compute week lists and today's values from state (fallbacks if empty)
    final recent = state.recent;

    final hrWeek = recent.map((e) => e.heartRate.toDouble()).toList();
    final stepsWeek = recent.map((e) => e.steps.toDouble()).toList();
    final sleepWeek = recent.map((e) => e.sleepHours).toList();

    final hrToday = recent.isNotEmpty ? recent.first.heartRate : 0;
    final stepsToday = recent.isNotEmpty ? recent.first.steps : 0;
    final sleepToday = recent.isNotEmpty ? recent.first.sleepHours : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hubo One", style: TextStyle(color: Palette.surface)),
        backgroundColor: Palette.accent,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Palette.surface),
            onPressed: () {
              // Trigger logout and navigate to login screen.
              ref.read(authProvider.notifier).logout();
              context.goNamed(AppRoute.login);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Palette.primary,
        onPressed: () => context.pushNamed(AppRoute.dailyVitals),
        child: const Icon(Icons.add),
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
              SizedBox(
                height: 120, // adjust as needed
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return StatCard(
                        title: 'Heart Rate',
                        value: '$hrToday bpm',
                        asset: 'assets/animations/heart_beat.json',
                      );
                    } else if (index == 1) {
                      return StatCard(
                        title: 'Steps count',
                        value: '$stepsToday',
                        asset: 'assets/animations/step_count.json',
                      );
                    } else {
                      return StatCard(
                        title: 'Sleep hour',
                        value: '${sleepToday.toStringAsFixed(1)} h',
                        asset: 'assets/animations/sleep.json',
                      );
                    }
                  },
                ),
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
                  padding: const EdgeInsets.all(8),
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
                        height: 200,
                        child: HeartRateLineChart(
                          values: hrWeek,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Steps',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: SimpleBarChart(
                          values: stepsWeek,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sleep Hours',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 150,
                        child: SimpleBarChart(
                          values: sleepWeek,
                          color: Colors.blue,
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
