import 'package:ai_meal_planner/objectbox.g.dart';
import 'package:objectbox/objectbox.dart' as obx;

import '../../../../../core/errors/app_exceptions.dart' as app_errors;
import '../../models/meal_plan_model.dart';
import 'objectbox_store.dart';

abstract class MealPlannerLocalDataSource {
  Future<int> saveMealPlan(MealPlanModel mealPlan);
  Future<List<MealPlanModel>> getSavedMealPlans();
  Future<MealPlanModel> getMealPlanById(int id);
  Future<void> deleteMealPlan(int id);
}

class ObjectBoxMealPlannerLocalDataSource
    implements MealPlannerLocalDataSource {
  ObjectBoxMealPlannerLocalDataSource(this._objectBox);

  final MealPlannerObjectBox _objectBox;

  @override
  Future<int> saveMealPlan(MealPlanModel mealPlan) async {
    try {
      final record = mealPlan.toRecord();
      return _objectBox.mealPlanBox.put(record);
    } catch (error) {
      throw const app_errors.StorageException(
        'Failed to save meal plan locally.',
      );
    }
  }

  @override
  Future<List<MealPlanModel>> getSavedMealPlans() async {
    try {
      final records = _objectBox.mealPlanBox
          .query()
          .order(MealPlanRecord_.createdAtIso, flags: obx.Order.descending)
          .build()
          .find();
      return records.map(MealPlanModel.fromRecord).toList(growable: false);
    } catch (error) {
      throw const app_errors.StorageException(
        'Could not load saved meal plans.',
      );
    }
  }

  @override
  Future<MealPlanModel> getMealPlanById(int id) async {
    try {
      final record = _objectBox.mealPlanBox.get(id);
      if (record == null) {
        throw const app_errors.StorageException('Meal plan not found.');
      }

      return MealPlanModel.fromRecord(record);
    } catch (error) {
      if (error is app_errors.StorageException) {
        rethrow;
      }

      throw const app_errors.StorageException(
        'Could not load the selected meal plan.',
      );
    }
  }

  @override
  Future<void> deleteMealPlan(int id) async {
    try {
      final removed = _objectBox.mealPlanBox.remove(id);
      if (!removed) {
        throw const app_errors.StorageException('Meal plan not found or already deleted.');
      }
    } catch (error) {
      if (error is app_errors.StorageException) {
        rethrow;
      }
      throw const app_errors.StorageException('Failed to delete meal plan.');
    }
  }
}
