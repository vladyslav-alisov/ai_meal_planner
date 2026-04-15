import 'package:ai_meal_planner/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'selection_card.dart';

class SexStep extends StatelessWidget {
  const SexStep({required this.selectedSex, required this.onSexChanged, super.key});

  final String? selectedSex;
  final ValueChanged<String> onSexChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Sex', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself so we can generate tailored meal plans and recipes that fit your life perfectly.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ...AppConstants.sexOptions.map(
            (sex) => OnboardingSelectionCard(
              label: sex,
              isSelected: selectedSex == sex,
              onTap: () => onSexChanged(sex),
              icon: sex == 'Male'
                  ? Icons.male_rounded
                  : sex == 'Female'
                  ? Icons.female_rounded
                  : Icons.person_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
