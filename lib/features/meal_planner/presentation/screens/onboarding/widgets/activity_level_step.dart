import 'package:flutter/material.dart';
import 'package:ai_meal_planner/core/constants/app_constants.dart';
import 'selection_card.dart';

class ActivityLevelStep extends StatelessWidget {
  const ActivityLevelStep({
    required this.selectedActivityLevel,
    required this.onActivityLevelChanged,
    super.key,
  });

  final String? selectedActivityLevel;
  final ValueChanged<String> onActivityLevelChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Level',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'How active are you on a daily basis?',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ...AppConstants.activityLevelOptions.map(
            (level) => OnboardingSelectionCard(
              label: level,
              isSelected: selectedActivityLevel == level,
              onTap: () => onActivityLevelChanged(level),
              icon: _getActivityIcon(level),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String level) {
    if (level.contains('Sedentary')) return Icons.chair_rounded;
    if (level.contains('Lightly')) return Icons.directions_walk_rounded;
    if (level.contains('Moderately')) return Icons.directions_run_rounded;
    return Icons.bolt_rounded;
  }
}
