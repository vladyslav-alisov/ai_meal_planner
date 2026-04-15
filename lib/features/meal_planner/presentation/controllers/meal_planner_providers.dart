import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/local/meal_planner_local_data_source.dart';
import '../../data/datasources/local/objectbox_store.dart';
import '../../data/datasources/local/user_preferences_local_source.dart';
import '../../data/datasources/remote/meal_planner_remote_data_source.dart';
import '../../data/repositories/meal_plan_repository_impl.dart';
import '../../domain/repositories/meal_plan_repository.dart';

final mealPlannerObjectBoxProvider = Provider<MealPlannerObjectBox>((ref) {
  throw UnimplementedError('ObjectBox must be initialized in main().');
});

final mealPlannerRemoteDataSourceProvider =
    Provider<MealPlannerRemoteDataSource>((ref) {
      return GeminiMealPlannerRemoteDataSource(ref.watch(dioProvider));
    });

final mealPlannerLocalDataSourceProvider = Provider<MealPlannerLocalDataSource>(
  (ref) {
    return ObjectBoxMealPlannerLocalDataSource(
      ref.watch(mealPlannerObjectBoxProvider),
    );
  },
);

final userPreferencesLocalSourceProvider = Provider<UserPreferencesLocalSource>(
  (ref) => SharedPrefsUserPreferencesLocalSource(),
);

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  return MealPlanRepositoryImpl(
    remoteDataSource: ref.watch(mealPlannerRemoteDataSourceProvider),
    localDataSource: ref.watch(mealPlannerLocalDataSourceProvider),
  );
});
