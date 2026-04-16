import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/meal_plan.dart';

class HistoryPlanCard extends StatelessWidget {
  const HistoryPlanCard({
    required this.mealPlan,
    required this.onTap,
    super.key,
  });

  final MealPlan mealPlan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAt = mealPlan.createdAt;
    final formattedDate = createdAt == null
        ? 'Unknown date'
        : DateFormat('d MMM yyyy, HH:mm').format(createdAt);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mealPlan.userPreferences.goals.join(', '),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 8),
              _Badge(
                label: mealPlan.userPreferences.dietaryPreferences.join(', '),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Badge(label: '${mealPlan.dailyCalories} kcal'),
                  _Badge(label: '${mealPlan.meals.length} meals'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                mealPlan.meals.map((meal) => meal.name).join(' • '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
