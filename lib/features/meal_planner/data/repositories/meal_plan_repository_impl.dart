import '../../domain/entities/meal_plan.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../datasources/local/meal_planner_local_data_source.dart';
import '../datasources/remote/meal_planner_remote_data_source.dart';
import '../models/meal_plan_model.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  MealPlanRepositoryImpl({
    required MealPlannerRemoteDataSource remoteDataSource,
    required MealPlannerLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final MealPlannerRemoteDataSource _remoteDataSource;
  final MealPlannerLocalDataSource _localDataSource;

  @override
  Future<MealPlan> generateMealPlan(UserPreferences preferences) {
    return _remoteDataSource.generateMealPlan(preferences);
  }

  @override
  Future<int> saveMealPlan(MealPlan mealPlan) {
    return _localDataSource.saveMealPlan(MealPlanModel.fromEntity(mealPlan));
  }

  @override
  Future<List<MealPlan>> getSavedMealPlans() {
    return _localDataSource.getSavedMealPlans();
  }

  @override
  Future<MealPlan> getMealPlanById(int id) {
    return _localDataSource.getMealPlanById(id);
  }

  @override
  Future<void> deleteMealPlan(int id) {
    return _localDataSource.deleteMealPlan(id);
  }
}
