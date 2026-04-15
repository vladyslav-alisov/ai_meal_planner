import 'package:flutter/material.dart';
import 'wheel_picker.dart';

class HeightStep extends StatelessWidget {
  const HeightStep({
    required this.heightCm,
    required this.onHeightChanged,
    super.key,
  });

  final double heightCm;
  final ValueChanged<double> onHeightChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Height',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Accurate metrics help us calculate your daily caloric needs more precisely.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          OnboardingWheelPicker(
            min: 50,
            max: 250,
            value: heightCm.toInt(),
            onChanged: (val) => onHeightChanged(val.toDouble()),
            unit: 'cm',
          ),
        ],
      ),
    );
  }
}
