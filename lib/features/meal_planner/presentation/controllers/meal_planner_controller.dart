import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/utils/error_message_mapper.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/entities/user_preferences.dart';
import 'history_controller.dart';
import 'meal_planner_providers.dart';

class MealPlannerState {
  const MealPlannerState({
    this.currentPlan,
    this.lastSavedPlan,
    this.isGenerating = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final MealPlan? currentPlan;
  final MealPlan? lastSavedPlan;
  final bool isGenerating;
  final bool isSaving;
  final String? errorMessage;

  MealPlannerState copyWith({
    MealPlan? currentPlan,
    MealPlan? lastSavedPlan,
    bool? isGenerating,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MealPlannerState(
      currentPlan: currentPlan ?? this.currentPlan,
      lastSavedPlan: lastSavedPlan ?? this.lastSavedPlan,
      isGenerating: isGenerating ?? this.isGenerating,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class MealPlannerController extends Notifier<MealPlannerState> {
  @override
  MealPlannerState build() => const MealPlannerState();

  Future<MealPlan?> generateMealPlan(UserPreferences preferences) async {
    state = state.copyWith(isGenerating: true, clearError: true);
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logMealPlanGenerationRequested(
      mealsPerDay: preferences.mealsPerDay,
      goalsCount: preferences.goals.length,
      dietaryPreferencesCount: preferences.dietaryPreferences.length,
      hasAllergies: preferences.allergies.isNotEmpty,
      hasExcludedFoods: preferences.excludedFoods.isNotEmpty,
      hasNotes: preferences.notes.trim().isNotEmpty,
    );

    try {
      final plan = await ref
          .read(mealPlanRepositoryProvider)
          .generateMealPlan(preferences);
      await analytics.logMealPlanGenerationCompleted(
        success: true,
        dailyCalories: plan.dailyCalories,
        mealsCount: plan.meals.length,
      );
      state = state.copyWith(
        currentPlan: plan,
        isGenerating: false,
        clearError: true,
      );
      return plan;
    } catch (error) {
      await analytics.logMealPlanGenerationCompleted(
        success: false,
        failureType: error.runtimeType.toString(),
      );
      state = state.copyWith(
        isGenerating: false,
        errorMessage: mapExceptionToMessage(error),
      );
      return null;
    }
  }

  Future<int?> saveMealPlan(MealPlan mealPlan) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final analytics = ref.read(analyticsServiceProvider);

    try {
      final isUpdate = mealPlan.id != null;
      final savedId = await ref
          .read(mealPlanRepositoryProvider)
          .saveMealPlan(
            mealPlan.copyWith(createdAt: mealPlan.createdAt ?? DateTime.now()),
          );

      final savedPlan = mealPlan.copyWith(
        id: savedId,
        createdAt: mealPlan.createdAt ?? DateTime.now(),
      );

      state = state.copyWith(
        currentPlan: savedPlan,
        lastSavedPlan: savedPlan,
        isSaving: false,
        clearError: true,
      );

      await analytics.logMealPlanSaved(
        isUpdate: isUpdate,
        mealsCount: savedPlan.meals.length,
        shoppingItemsCount: savedPlan.shoppingList.length,
      );
      await ref.read(historyControllerProvider.notifier).refreshHistory();
      return savedId;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: mapExceptionToMessage(error),
      );
      return null;
    }
  }

  void setCurrentPlan(MealPlan mealPlan) {
    state = state.copyWith(
      currentPlan: mealPlan,
      lastSavedPlan: mealPlan.id != null ? mealPlan : null,
      clearError: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> deleteSavedPlan(int id) async {
    try {
      await ref.read(mealPlanRepositoryProvider).deleteMealPlan(id);
      await ref
          .read(analyticsServiceProvider)
          .logMealPlanDeleted(source: 'result_screen');

      // Reset state if we just deleted the plan we were looking at
      if (state.currentPlan?.id == id) {
        state = state.copyWith(
          currentPlan: null,
          lastSavedPlan: null,
          clearError: true,
        );
      } else if (state.lastSavedPlan?.id == id) {
        state = state.copyWith(lastSavedPlan: null, clearError: true);
      }

      await ref.read(historyControllerProvider.notifier).refreshHistory();
    } catch (error) {
      state = state.copyWith(errorMessage: mapExceptionToMessage(error));
    }
  }
}

final mealPlannerControllerProvider =
    NotifierProvider<MealPlannerController, MealPlannerState>(
      MealPlannerController.new,
    );
