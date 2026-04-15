import 'package:flutter/material.dart';
import 'package:ai_meal_planner/features/meal_planner/presentation/widgets/planner_text_field.dart';

class AllergiesStep extends StatelessWidget {
  const AllergiesStep({
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
            'Allergies',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Is there anything you are allergic to? Use commas to separate multiple items.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          PlannerTextField(
            controller: controller,
            label: 'e.g. Peanuts, Shellfish',
            hintText: 'Peanuts, shellfish',
            maxLines: 3,
            prefixIcon: const Icon(Icons.warning_amber_rounded),
          ),
        ],
      ),
    );
  }
}
