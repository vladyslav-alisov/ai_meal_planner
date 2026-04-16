import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ads/ads_service.dart';
import '../../../../core/ads/widgets/adaptive_banner_ad_section.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../domain/entities/user_preferences.dart';
import '../controllers/meal_planner_controller.dart';
import '../controllers/meal_planner_providers.dart';
import '../widgets/app_background.dart';
import '../widgets/section_card.dart';
import 'history_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'result_screen.dart';
import '../widgets/loading_overlay.dart';
import '../../domain/entities/meal_plan.dart';
import '../controllers/history_controller.dart';

import '../widgets/pill_badge.dart';
import '../widgets/dashboard_action.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  UserPreferences? _preferences;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final localSource = ref.read(userPreferencesLocalSourceProvider);
    final prefs = await localSource.getUserPreferences();
    await ref
        .read(analyticsServiceProvider)
        .logScreenView(screenName: 'planner_screen');
    await ref
        .read(analyticsServiceProvider)
        .logPlannerViewed(hasStoredPreferences: prefs != null);
    if (mounted) {
      setState(() {
        _preferences = prefs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plannerState = ref.watch(mealPlannerControllerProvider);
    final historyState = ref.watch(historyControllerProvider);

    ref.listen<MealPlannerState>(mealPlannerControllerProvider, (
      previous,
      next,
    ) {
      final errorMessage = next.errorMessage;
      if (errorMessage != null && errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
        ref.read(mealPlannerControllerProvider.notifier).clearError();
      }
    });

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        body: Stack(
          children: [
            AppBackground(
              child: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      pinned: false,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Meal Planner',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Your intelligent nutrition assistant',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: const [],
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildHeroCard(context, plannerState),
                          const SizedBox(height: 24),
                          _buildQuickActions(context),
                          const SizedBox(height: 20),
                          const AdaptiveBannerAdSection(),
                          const SizedBox(height: 32),
                          _buildRecentPlanSection(context, historyState),
                          const SizedBox(height: 32),
                          _buildProfileSection(context),
                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (plannerState.isGenerating) const LoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, MealPlannerState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Generation',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Ready for your next meal?',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Generate a personalized meal plan based on your unique profile and preferences.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: state.isGenerating ? null : _onGeneratePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch_rounded),
                SizedBox(width: 12),
                Text(
                  'Generate Meal Plan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        DashboardAction(
          icon: Icons.history_rounded,
          label: 'History',
          onTap: () async {
            await ref
                .read(analyticsServiceProvider)
                .logQuickActionTapped(action: 'history');
            if (!context.mounted) {
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
            );
          },
        ),
        DashboardAction(
          icon: Icons.person_search_rounded,
          label: 'Update Profile',
          onTap: () async {
            await ref
                .read(analyticsServiceProvider)
                .logQuickActionTapped(action: 'update_profile');
            if (!context.mounted) {
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    OnboardingScreen(initialPreferences: _preferences),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentPlanSection(
    BuildContext context,
    AsyncValue<List<MealPlan>> historyState,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Plan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(analyticsServiceProvider)
                    .logQuickActionTapped(action: 'history_see_all');
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HistoryScreen(),
                  ),
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        historyState.when(
          data: (plans) {
            if (plans.isEmpty) {
              return _buildEmptyRecentState(context);
            }
            final latestPlan = plans.first;
            return _RecentPlanCard(
              plan: latestPlan,
              onTap: () async {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ResultScreen(
                      initialPlan: latestPlan,
                      analyticsSource: 'planner_recent',
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              const Text('Could not load recent plans.'),
        ),
      ],
    );
  }

  Widget _buildEmptyRecentState(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 48,
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No plans generated yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            'Your last generated plan will appear here.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Profile Hub',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_preferences != null)
          _ProfileSummaryCard(preferences: _preferences!)
        else
          const Center(child: Text('No profile found.')),
      ],
    );
  }

  Future<void> _onGeneratePressed() async {
    if (_preferences == null) return;

    final plan = await ref
        .read(mealPlannerControllerProvider.notifier)
        .generateMealPlan(_preferences!);

    if (!mounted || plan == null) {
      return;
    }

    await ref.read(adsServiceProvider).maybeShowMealPlanInterstitial();
    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ResultScreen(initialPlan: plan, analyticsSource: 'generated'),
      ),
    );
  }
}

class _RecentPlanCard extends StatelessWidget {
  const _RecentPlanCard({required this.plan, required this.onTap});

  final MealPlan plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      shadowColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant_rounded,
                    color: theme.colorScheme.primary,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Generation',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${plan.dailyCalories} kcal • ${plan.meals.length} meals',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      plan.userPreferences.goals.take(2).join(', '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.preferences});

  final UserPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Current Preferences',
      subtitle: 'Personalization based on your latest inputs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Goals',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: preferences.goals
                .map((g) => PillBadge(label: g))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Eat Styles',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: preferences.dietaryPreferences
                .map(
                  (d) =>
                      PillBadge(label: d, color: theme.colorScheme.secondary),
                )
                .toList(),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(label: 'Age', value: '${preferences.age}'),
              _StatItem(
                label: 'Height',
                value: '${preferences.heightCm.toInt()} cm',
              ),
              _StatItem(
                label: 'Weight',
                value: '${preferences.weightKg.toInt()} kg',
              ),
              _StatItem(
                label: 'Meals/Day',
                value: '${preferences.mealsPerDay}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
