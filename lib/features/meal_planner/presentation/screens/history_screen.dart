import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/history_controller.dart';
import '../widgets/app_background.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/history_plan_card.dart';
import 'result_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyControllerProvider);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverAppBar(floating: true, title: Text('Saved Plans')),
              historyState.when(
                data: (plans) {
                  if (plans.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateView(
                        icon: Icons.inventory_2_outlined,
                        title: 'No saved plans yet',
                        message:
                            'Save a generated plan and it will show up here for quick reopening.',
                        action: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Back to planner'),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverList.separated(
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return Dismissible(
                          key: Key('plan_${plan.id}'),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) => _showDeleteConfirmation(context, ref, plan.id!),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                          ),
                          child: HistoryPlanCard(
                            mealPlan: plan,
                            onTap: () async {
                              final reopenedPlan = plan.id == null
                                  ? plan
                                  : await ref
                                        .read(historyControllerProvider.notifier)
                                        .getPlanById(plan.id!);

                              if (!context.mounted || reopenedPlan == null) {
                                return;
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      ResultScreen(initialPlan: reopenedPlan),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                    ),
                  );
                },
                error: (error, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    icon: Icons.error_outline_rounded,
                    title: 'Could not load history',
                    message: error.toString(),
                    action: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(historyControllerProvider.notifier)
                            .refreshHistory();
                      },
                      child: const Text('Try again'),
                    ),
                  ),
                ),
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, WidgetRef ref, int planId) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal Plan?'),
        content: const Text('Are you sure you want to remove this meal plan from your history? this action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(historyControllerProvider.notifier).deletePlan(planId);
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
