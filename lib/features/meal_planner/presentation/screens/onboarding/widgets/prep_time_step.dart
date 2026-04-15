import 'package:flutter/material.dart';
import 'package:ai_meal_planner/core/constants/app_constants.dart';
import 'selection_card.dart';

class PrepTimeStep extends StatelessWidget {
  const PrepTimeStep({
    required this.selectedTimeConstraint,
    required this.onTimeConstraintChanged,
    super.key,
  });

  final String? selectedTimeConstraint;
  final ValueChanged<String> onTimeConstraintChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferred Prep Time',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'How much time do you usually have for cooking?',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ...AppConstants.timeConstraintOptions.map(
            (time) => OnboardingSelectionCard(
              label: time,
              isSelected: selectedTimeConstraint == time,
              onTap: () => onTimeConstraintChanged(time),
              icon: Icons.access_time_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
