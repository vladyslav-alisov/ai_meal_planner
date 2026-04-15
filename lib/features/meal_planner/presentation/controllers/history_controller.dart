import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/error_message_mapper.dart';
import '../../domain/entities/meal_plan.dart';
import 'meal_planner_providers.dart';

class HistoryController extends AsyncNotifier<List<MealPlan>> {
  @override
  Future<List<MealPlan>> build() async {
    return _load();
  }

  Future<void> refreshHistory() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<MealPlan?> getPlanById(int id) async {
    try {
      return await ref.read(mealPlanRepositoryProvider).getMealPlanById(id);
    } catch (error, stackTrace) {
      state = AsyncError(mapExceptionToMessage(error), stackTrace);
      return null;
    }
  }

  Future<void> deletePlan(int id) async {
    try {
      await ref.read(mealPlanRepositoryProvider).deleteMealPlan(id);
      await refreshHistory();
    } catch (error, stackTrace) {
      state = AsyncError(mapExceptionToMessage(error), stackTrace);
    }
  }

  Future<List<MealPlan>> _load() {
    return ref.read(mealPlanRepositoryProvider).getSavedMealPlans();
  }
}

final historyControllerProvider =
    AsyncNotifierProvider<HistoryController, List<MealPlan>>(
      HistoryController.new,
    );
