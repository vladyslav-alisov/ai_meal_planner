import 'package:flutter/material.dart';

class OnboardingWheelPicker extends StatelessWidget {
  const OnboardingWheelPicker({
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.unit = '',
    super.key,
  });

  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          ListWheelScrollView.useDelegate(
            itemExtent: 50,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              onChanged(min + index);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final displayValue = min + index;
                final isSelected = displayValue == value;

                return Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayValue.toString(),
                        style: isSelected
                            ? theme.textTheme.headlineMedium?.copyWith(
                                color: primaryColor,
                              )
                            : theme.textTheme.titleLarge?.copyWith(
                                color: Colors.grey[400],
                              ),
                      ),
                      if (unit.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          unit,
                          style: isSelected
                              ? theme.textTheme.titleMedium?.copyWith(
                                  color: primaryColor,
                                )
                              : theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[300],
                                ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              childCount: max - min + 1,
            ),
            controller: FixedExtentScrollController(
              initialItem: value - min,
            ),
          ),
        ],
      ),
    );
  }
}
