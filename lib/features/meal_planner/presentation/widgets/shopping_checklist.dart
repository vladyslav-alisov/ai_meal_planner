import 'package:flutter/material.dart';

class ShoppingChecklist extends StatefulWidget {
  const ShoppingChecklist({required this.items, super.key});

  final List<String> items;

  @override
  State<ShoppingChecklist> createState() => _ShoppingChecklistState();
}

class _ShoppingChecklistState extends State<ShoppingChecklist> {
  late Map<String, bool> _checkedItems;

  @override
  void initState() {
    super.initState();
    _checkedItems = {for (var item in widget.items) item: false};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.items.map((item) {
        final isChecked = _checkedItems[item] ?? false;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                _checkedItems[item] = !isChecked;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isChecked 
                  ? theme.colorScheme.primary.withValues(alpha: 0.05)
                  : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isChecked 
                    ? theme.colorScheme.primary.withValues(alpha: 0.2)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isChecked ? theme.colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isChecked ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: isChecked 
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                        color: isChecked ? theme.colorScheme.onSurface.withValues(alpha: 0.4) : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
