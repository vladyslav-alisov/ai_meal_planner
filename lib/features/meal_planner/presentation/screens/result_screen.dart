import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/meal_plan.dart';
import '../controllers/meal_planner_controller.dart';
import '../widgets/app_background.dart';
import '../widgets/meal_card.dart';
import '../widgets/section_card.dart';
import '../widgets/summary_metric_card.dart';
import '../widgets/loading_overlay.dart';

import '../widgets/macro_dashboard.dart';
import '../widgets/shopping_checklist.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({required this.initialPlan, super.key});

  final MealPlan initialPlan;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late MealPlan _plan;
  int _shoppingVersion = 0;

  @override
  void initState() {
    super.initState();
    _plan = widget.initialPlan;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mealPlannerControllerProvider.notifier).setCurrentPlan(_plan);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(mealPlannerControllerProvider);

    ref.listen<MealPlannerState>(mealPlannerControllerProvider, (previous, next) {
      final errorMessage = next.errorMessage;
      if (errorMessage != null && errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        ref.read(mealPlannerControllerProvider.notifier).clearError();
      }
    });

    final displayPlan = state.currentPlan ?? _plan;
    final isDirty = state.lastSavedPlan == null || displayPlan != state.lastSavedPlan;
    final isSaved = displayPlan.id != null && !isDirty;
    final isHistorical = displayPlan.id != null;

    return Scaffold(
      body: Stack(
        children: [
          AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          floating: true,
                          title: const Text('Your Meal Plan'),
                          actions: [
                            if (displayPlan.id != null)
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                tooltip: 'Delete saved plan',
                                onPressed: () => _showDeleteConfirmation(context, ref, displayPlan.id!),
                              ),
                          ],
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: MacroHeaderDelegate(plan: displayPlan),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              Text('Daily Guide', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                '${displayPlan.userPreferences.goals.join(', ')} • ${displayPlan.userPreferences.mealsPerDay} meals',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Meals Section
                              Row(
                                children: [
                                  const Icon(Icons.restaurant_rounded, size: 20),
                                  const SizedBox(width: 12),
                                  Text('Today\'s Meals', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...displayPlan.meals.asMap().entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: MealCard(index: entry.key, meal: entry.value),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Shopping List Section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.shopping_cart_checkout_rounded, size: 20),
                                      const SizedBox(width: 12),
                                      Text('Grocery Checklist', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.restart_alt_rounded, size: 20),
                                    tooltip: 'Clear checks',
                                    onPressed: () {
                                      setState(() {
                                        _shoppingVersion++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap items to check them off as you shop.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ShoppingChecklist(
                                key: ValueKey('shopping_${displayPlan.id}_$_shoppingVersion'),
                                items: displayPlan.shoppingList,
                              ),

                              SizedBox(height: isHistorical ? 40 : 100), // Adjust space for bottom bar
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Bottom Bar (Only for unsaved plans)
          if (!isHistorical)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomActions(context, state, displayPlan, isSaved),
            ),

          if (state.isGenerating) const LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, MealPlannerState state, MealPlan displayPlan, bool isSaved) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.0),
            theme.colorScheme.surface,
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: state.isSaving || state.isGenerating || isSaved ? null : _onSavePressed,
              icon: state.isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(isSaved ? Icons.check_circle_rounded : Icons.bookmark_add_rounded),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              label: Text(
                state.isSaving ? 'Saving...' : isSaved ? 'Saved' : displayPlan.id == null ? 'Save Plan' : 'Update Plan',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: state.isGenerating ? null : _onRegeneratePressed,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSavePressed() async {
    final savedId = await ref.read(mealPlannerControllerProvider.notifier).saveMealPlan(_plan);

    if (!mounted || savedId == null) {
      return;
    }

    setState(() {
      _plan = _plan.copyWith(
        id: savedId,
        createdAt: _plan.createdAt ?? DateTime.now(),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal plan saved and synchronized.')),
    );
  }

  Future<void> _onRegeneratePressed() async {
    final plan = await ref.read(mealPlannerControllerProvider.notifier).generateMealPlan(_plan.userPreferences);

    if (!mounted || plan == null) {
      return;
    }

    setState(() {
      _plan = plan;
    });
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref, int planId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal Plan?'),
        content: const Text('Are you sure you want to remove this meal plan from your history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(mealPlannerControllerProvider.notifier).deleteSavedPlan(planId);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan permanently deleted.')),
        );
      }
    }
  }
}
