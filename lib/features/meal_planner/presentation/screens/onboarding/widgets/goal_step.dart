import 'package:flutter/material.dart';
import 'package:ai_meal_planner/core/constants/app_constants.dart';
import 'selection_card.dart';

class GoalStep extends StatelessWidget {
  const GoalStep({
    required this.selectedGoals,
    required this.onGoalToggled,
    super.key,
  });

  final List<String> selectedGoals;
  final ValueChanged<String> onGoalToggled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Goals',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'What are you looking to achieve? You can select multiple goals.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ...AppConstants.goalOptions.map(
            (goal) => OnboardingSelectionCard(
              label: goal,
              isSelected: selectedGoals.contains(goal),
              onTap: () => onGoalToggled(goal),
              icon: _getGoalIcon(goal),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGoalIcon(String goal) {
    if (goal.contains('Lose')) return Icons.trending_down_rounded;
    if (goal.contains('Build')) return Icons.fitness_center_rounded;
    if (goal.contains('Maintain')) return Icons.balance_rounded;
    return Icons.restaurant_rounded;
  }
}
