import 'package:flutter/material.dart';
import 'package:ai_meal_planner/core/constants/app_constants.dart';
import 'selection_card.dart';

class CookingLevelStep extends StatelessWidget {
  const CookingLevelStep({
    required this.selectedCookingLevel,
    required this.onCookingLevelChanged,
    super.key,
  });

  final String? selectedCookingLevel;
  final ValueChanged<String> onCookingLevelChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cooking Experience',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'How comfortable are you in the kitchen?',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ...AppConstants.cookingLevelOptions.map(
            (level) => OnboardingSelectionCard(
              label: level,
              isSelected: selectedCookingLevel == level,
              onTap: () => onCookingLevelChanged(level),
              icon: _getSkillIcon(level),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSkillIcon(String level) {
    if (level.contains('Beginner')) return Icons.egg_outlined;
    if (level.contains('Intermediate')) return Icons.restaurant_rounded;
    return Icons.restaurant_menu_rounded;
  }
}
