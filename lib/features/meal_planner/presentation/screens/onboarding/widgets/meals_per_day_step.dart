import 'package:flutter/material.dart';

class MealsPerDayStep extends StatelessWidget {
  const MealsPerDayStep({
    required this.mealsPerDay,
    required this.onMealsPerDayChanged,
    super.key,
  });

  final int mealsPerDay;
  final ValueChanged<int> onMealsPerDayChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meals per Day',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'How many meals do you prefer to have in a day?',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 48),
          _MealsPerDaySelector(
            value: mealsPerDay,
            onChanged: onMealsPerDayChanged,
          ),
        ],
      ),
    );
  }
}

class _MealsPerDaySelector extends StatelessWidget {
  const _MealsPerDaySelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        final mealCount = index + 1;
        final isSelected = value == mealCount;

        return GestureDetector(
          onTap: () => onChanged(mealCount),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? primaryColor : primaryColor.withValues(alpha: 0.1), width: 2),
              boxShadow: [
                if (isSelected)
                  BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Center(
              child: Text(
                mealCount.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected ? Colors.white : theme.textTheme.titleMedium?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
