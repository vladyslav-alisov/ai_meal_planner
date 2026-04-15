import 'package:flutter/material.dart';
import 'package:ai_meal_planner/features/meal_planner/presentation/widgets/planner_text_field.dart';

class AdditionalNotesStep extends StatelessWidget {
  const AdditionalNotesStep({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Notes',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Is there anything else we should know?',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          PlannerTextField(
            controller: controller,
            label: 'Any other preferences?',
            hintText: 'Quick breakfasts, budget-friendly, etc.',
            maxLines: 4,
            prefixIcon: const Icon(Icons.note_alt_outlined),
          ),
        ],
      ),
    );
  }
}
