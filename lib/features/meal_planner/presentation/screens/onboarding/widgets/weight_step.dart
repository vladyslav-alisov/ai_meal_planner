import 'package:flutter/material.dart';
import 'wheel_picker.dart';

class WeightStep extends StatelessWidget {
  const WeightStep({
    required this.weightKg,
    required this.onWeightChanged,
    super.key,
  });

  final double weightKg;
  final ValueChanged<double> onWeightChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Weight',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Accurate metrics help us calculate your daily caloric needs more precisely.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          OnboardingWheelPicker(
            min: 20,
            max: 300,
            value: weightKg.toInt(),
            onChanged: (val) => onWeightChanged(val.toDouble()),
            unit: 'kg',
          ),
        ],
      ),
    );
  }
}
