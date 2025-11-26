import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hubo/core/constants/palette.dart';
import 'package:hubo/feature/health/presentation/notifier/vitals_notifier.dart';

class DailyVitalsScreen extends ConsumerStatefulWidget {
  const DailyVitalsScreen({Key? key, this.onSave}) : super(key: key);

  /// Optional async callback when the form is saved.
  final Future<void> Function(int heartRate, int steps, double sleepHours)?
  onSave;

  @override
  ConsumerState<DailyVitalsScreen> createState() => _DailyVitalsScreenState();
}

class _DailyVitalsScreenState extends ConsumerState<DailyVitalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heartCtrl = TextEditingController();
  final _stepsCtrl = TextEditingController();
  final _sleepCtrl = TextEditingController();
  var _isSaving = false;

  @override
  void dispose() {
    _heartCtrl.dispose();
    _stepsCtrl.dispose();
    _sleepCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final heart = int.parse(_heartCtrl.text.trim());
    final steps = int.parse(_stepsCtrl.text.trim());
    final sleep = double.parse(_sleepCtrl.text.trim());

    setState(() => _isSaving = true);
    try {
      if (widget.onSave != null) {
        await widget.onSave!(heart, steps, sleep);
      } else {
        // Use the notifier (StateNotifier) to add the vital; keeps UI decoupled.
        final notifier = ref.read(vitalsProvider.notifier);
        final localId = await notifier.addVital(
          heartRate: heart,
          steps: steps,
          sleepHours: sleep,
        );

        if (!mounted) return;
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              color: Palette.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Image.asset(
                            'assets/icons/hubo_launcher_icon.png',
                            height: 120,
                            width: 120,
                          ),
                        ),
                      ),
                      const Text(
                        'Add daily vitals',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _heartCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Heart Rate (bpm)',
                          prefixIcon: Icon(Icons.favorite),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Enter heart rate';
                          final n = int.tryParse(v.trim());
                          if (n == null || n <= 0)
                            return 'Enter a valid heart rate';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _stepsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Steps',
                          prefixIcon: Icon(Icons.directions_walk),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Enter steps';
                          final n = int.tryParse(v.trim());
                          if (n == null || n < 0)
                            return 'Enter a valid steps count';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _sleepCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Sleep Hours',
                          prefixIcon: Icon(Icons.bedtime),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Enter sleep hours';
                          final d = double.tryParse(v.trim());
                          if (d == null || d < 0)
                            return 'Enter a valid number of hours';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Palette.primary,
                            foregroundColor: Palette.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
