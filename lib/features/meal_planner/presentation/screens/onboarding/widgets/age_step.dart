import 'package:flutter/material.dart';
import 'wheel_picker.dart';

class AgeStep extends StatelessWidget {
  const AgeStep({
    required this.selectedAge,
    required this.onAgeChanged,
    super.key,
  });

  final int selectedAge;
  final ValueChanged<int> onAgeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Age',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your age helps us calculate your daily caloric needs more precisely.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          OnboardingWheelPicker(
            min: 1,
            max: 120,
            value: selectedAge,
            onChanged: onAgeChanged,
            unit: 'yrs',
          ),
        ],
      ),
    );
  }
}
