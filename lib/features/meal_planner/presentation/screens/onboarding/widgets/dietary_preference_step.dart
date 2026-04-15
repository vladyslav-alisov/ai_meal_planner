import 'package:flutter/material.dart';
import 'package:ai_meal_planner/core/constants/app_constants.dart';
import 'selection_card.dart';

class DietaryPreferenceStep extends StatelessWidget {
  const DietaryPreferenceStep({
    required this.selectedPreferences,
    required this.onPreferenceToggled,
    super.key,
  });

  final List<String> selectedPreferences;
  final ValueChanged<String> onPreferenceToggled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eating Style',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'What dietary styles do you follow? You can select multiple options.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ...AppConstants.dietaryPreferenceOptions.map(
            (pref) => OnboardingSelectionCard(
              label: pref,
              isSelected: selectedPreferences.contains(pref),
              onTap: () => onPreferenceToggled(pref),
              icon: _getDietIcon(pref),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDietIcon(String pref) {
    if (pref.contains('Vegetarian')) return Icons.eco_rounded;
    if (pref.contains('Vegan')) return Icons.grass_rounded;
    if (pref.contains('Pescatarian')) return Icons.set_meal_rounded;
    if (pref.contains('High protein')) return Icons.fitness_center_rounded;
    if (pref.contains('Low carb')) return Icons.bakery_dining_rounded;
    return Icons.restaurant_rounded;
  }
}
