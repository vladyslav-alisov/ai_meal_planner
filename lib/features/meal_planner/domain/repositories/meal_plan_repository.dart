import '../entities/meal_plan.dart';
import '../entities/user_preferences.dart';

abstract class MealPlanRepository {
  Future<MealPlan> generateMealPlan(UserPreferences preferences);
  Future<int> saveMealPlan(MealPlan mealPlan);
  Future<List<MealPlan>> getSavedMealPlans();
  Future<MealPlan> getMealPlanById(int id);
  Future<void> deleteMealPlan(int id);
}
