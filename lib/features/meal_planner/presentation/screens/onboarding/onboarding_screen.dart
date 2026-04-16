import 'package:ai_meal_planner/core/utils/string_list_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/analytics/analytics_service.dart';
import '../../../domain/entities/user_preferences.dart';
import '../../controllers/onboarding_controller.dart';
import '../planner_screen.dart';
import 'widgets/welcome_step.dart';
import 'widgets/sex_step.dart';
import 'widgets/age_step.dart';
import 'widgets/height_step.dart';
import 'widgets/weight_step.dart';
import 'widgets/goal_step.dart';
import 'widgets/activity_level_step.dart';
import 'widgets/cooking_level_step.dart';
import 'widgets/prep_time_step.dart';
import 'widgets/dietary_preference_step.dart';
import 'widgets/meals_per_day_step.dart';
import 'widgets/allergies_step.dart';
import 'widgets/excluded_foods_step.dart';
import 'widgets/additional_notes_step.dart';
import 'widgets/summary_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({this.initialPreferences, super.key});

  final UserPreferences? initialPreferences;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _stepNames = <String>[
    'welcome',
    'sex',
    'age',
    'height',
    'weight',
    'goals',
    'activity_level',
    'cooking_level',
    'prep_time',
    'dietary_preferences',
    'meals_per_day',
    'allergies',
    'excluded_foods',
    'additional_notes',
    'summary',
  ];

  late PageController _pageController;

  final int _totalSteps = 15;

  // Local state for the questionnaire data
  late String? _selectedSex;
  late int _selectedAge;
  late double _heightCm;
  late double _weightKg;
  late final List<String> _selectedGoals;
  late String? _selectedActivityLevel;
  late String? _selectedCookingLevel;
  late String? _selectedTimeConstraint;
  late final List<String> _selectedDietaryPreferences;
  late int _mealsPerDay;

  late final TextEditingController _allergiesController;
  late final TextEditingController _excludedFoodsController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPreferences;

    _selectedSex = initial?.sex;
    _selectedAge = initial?.age ?? 30;
    _heightCm = initial?.heightCm ?? 170.0;
    _weightKg = initial?.weightKg ?? 70.0;
    _selectedGoals = initial != null ? List.from(initial.goals) : [];
    _selectedActivityLevel = initial?.activityLevel;
    _selectedCookingLevel = initial?.cookingLevel;
    _selectedTimeConstraint = initial?.timeConstraint;
    _selectedDietaryPreferences = initial != null
        ? List.from(initial.dietaryPreferences)
        : [];
    _mealsPerDay = initial?.mealsPerDay ?? 3;

    _allergiesController = TextEditingController(
      text: initial?.allergies.join(', ') ?? '',
    );
    _excludedFoodsController = TextEditingController(
      text: initial?.excludedFoods.join(', ') ?? '',
    );
    _notesController = TextEditingController(text: initial?.notes ?? '');

    final initialPage = initial != null ? 1 : 0;
    _pageController = PageController(initialPage: initialPage);

    // Sync controller state with initial page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingControllerProvider.notifier).setPage(initialPage);
      ref
          .read(analyticsServiceProvider)
          .logScreenView(screenName: 'onboarding_screen');
      ref
          .read(analyticsServiceProvider)
          .logOnboardingStarted(isEditing: widget.initialPreferences != null);
      _logOnboardingStep(initialPage);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _allergiesController.dispose();
    _excludedFoodsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_pageController.position.isScrollingNotifier.value) return;

    FocusManager.instance.primaryFocus?.unfocus();
    if (_pageController.page == _totalSteps - 1) {
      _complete();
    } else {
      final nextIndex = ref.read(onboardingControllerProvider).currentPage + 1;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      ref.read(onboardingControllerProvider.notifier).nextStep();
      _logOnboardingStep(nextIndex);
    }
  }

  void _onBack() {
    if (_pageController.position.isScrollingNotifier.value) return;

    FocusManager.instance.primaryFocus?.unfocus();
    final previousIndex =
        ref.read(onboardingControllerProvider).currentPage - 1;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    ref.read(onboardingControllerProvider.notifier).previousStep();
    _logOnboardingStep(previousIndex);
  }

  void _toggleGoal(String goal) {
    setState(() {
      if (goal == 'Lose weight') {
        _selectedGoals.remove('Maintain weight');
      } else if (goal == 'Maintain weight') {
        _selectedGoals.remove('Lose weight');
      }

      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  void _toggleDietaryPreference(String pref) {
    const noPreference = 'No specific preference';
    setState(() {
      if (pref == noPreference) {
        _selectedDietaryPreferences.clear();
        _selectedDietaryPreferences.add(noPreference);
      } else {
        _selectedDietaryPreferences.remove(noPreference);
        if (_selectedDietaryPreferences.contains(pref)) {
          _selectedDietaryPreferences.remove(pref);
        } else {
          _selectedDietaryPreferences.add(pref);
        }
        // If everything was removed, default back to no preference (optional, but keep it empty for validation to force a choice if needed)
      }
    });
  }

  Future<void> _complete() async {
    final prefs = UserPreferences(
      age: _selectedAge,
      sex: _selectedSex ?? 'Prefer not to say',
      heightCm: _heightCm,
      weightKg: _weightKg,
      goals: _selectedGoals,
      activityLevel: _selectedActivityLevel ?? 'Moderately active',
      dietaryPreferences: _selectedDietaryPreferences,
      cookingLevel: _selectedCookingLevel ?? 'Intermediate',
      timeConstraint: _selectedTimeConstraint ?? 'Under 30 mins',
      allergies: parseCommaSeparatedList(_allergiesController.text),
      excludedFoods: parseCommaSeparatedList(_excludedFoodsController.text),
      mealsPerDay: _mealsPerDay,
      notes: _notesController.text,
    );

    ref.read(onboardingControllerProvider.notifier).updatePreferences(prefs);
    await ref
        .read(onboardingControllerProvider.notifier)
        .completeOnboarding(isEditing: widget.initialPreferences != null);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const PlannerScreen()),
      );
    }
  }

  bool _isStepValid(int step) {
    switch (step) {
      case 0:
        return true; // Welcome
      case 1:
        return _selectedSex != null; // Sex
      case 2:
        return true; // Age (Wheel)
      case 3:
        return true; // Height (Wheel)
      case 4:
        return true; // Weight (Wheel)
      case 5:
        return _selectedGoals.isNotEmpty; // Goal
      case 6:
        return _selectedActivityLevel != null; // Activity
      case 7:
        return _selectedCookingLevel != null; // Cooking
      case 8:
        return _selectedTimeConstraint != null; // Time
      case 9:
        return _selectedDietaryPreferences.isNotEmpty; // Diet
      case 10:
        return true; // Meals
      case 11:
        return true; // Allergies
      case 12:
        return true; // Excluded
      case 13:
        return true; // Notes
      case 14:
        return true; // Summary
      default:
        return false;
    }
  }

  void _logOnboardingStep(int stepIndex) {
    if (stepIndex < 0 || stepIndex >= _stepNames.length) {
      return;
    }

    ref
        .read(analyticsServiceProvider)
        .logOnboardingStepViewed(
          stepIndex: stepIndex + 1,
          stepName: _stepNames[stepIndex],
          isEditing: widget.initialPreferences != null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    if (state.currentPage > 0)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: _onBack,
                        visualDensity: VisualDensity.compact,
                      )
                    else
                      const SizedBox(width: 40),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (state.currentPage + 1) / _totalSteps,
                          minHeight: 8,
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                    ),
                    if (widget.initialPreferences != null)
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.of(context).pop();
                        },
                        visualDensity: VisualDensity.compact,
                      )
                    else
                      const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const WelcomeStep(),
                    SexStep(
                      selectedSex: _selectedSex,
                      onSexChanged: (val) => setState(() => _selectedSex = val),
                    ),
                    AgeStep(
                      selectedAge: _selectedAge,
                      onAgeChanged: (val) => setState(() => _selectedAge = val),
                    ),
                    HeightStep(
                      heightCm: _heightCm,
                      onHeightChanged: (val) => setState(() => _heightCm = val),
                    ),
                    WeightStep(
                      weightKg: _weightKg,
                      onWeightChanged: (val) => setState(() => _weightKg = val),
                    ),
                    GoalStep(
                      selectedGoals: _selectedGoals,
                      onGoalToggled: _toggleGoal,
                    ),
                    ActivityLevelStep(
                      selectedActivityLevel: _selectedActivityLevel,
                      onActivityLevelChanged: (val) =>
                          setState(() => _selectedActivityLevel = val),
                    ),
                    CookingLevelStep(
                      selectedCookingLevel: _selectedCookingLevel,
                      onCookingLevelChanged: (val) =>
                          setState(() => _selectedCookingLevel = val),
                    ),
                    PrepTimeStep(
                      selectedTimeConstraint: _selectedTimeConstraint,
                      onTimeConstraintChanged: (val) =>
                          setState(() => _selectedTimeConstraint = val),
                    ),
                    DietaryPreferenceStep(
                      selectedPreferences: _selectedDietaryPreferences,
                      onPreferenceToggled: _toggleDietaryPreference,
                    ),
                    MealsPerDayStep(
                      mealsPerDay: _mealsPerDay,
                      onMealsPerDayChanged: (val) =>
                          setState(() => _mealsPerDay = val),
                    ),
                    AllergiesStep(controller: _allergiesController),
                    ExcludedFoodsStep(controller: _excludedFoodsController),
                    AdditionalNotesStep(controller: _notesController),
                    const SummaryStep(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isStepValid(state.currentPage) ? _onNext : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(
                      state.currentPage == 0
                          ? 'Get Started'
                          : state.currentPage == _totalSteps - 1
                          ? (widget.initialPreferences != null
                                ? 'Save Changes'
                                : 'Go to Planner')
                          : 'Continue',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
