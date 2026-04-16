import 'package:ai_meal_planner/core/analytics/app_metrica.dart';
import 'package:ai_meal_planner/core/analytics/apps_flyer_service.dart';
import 'package:ai_meal_planner/core/analytics/firebase_analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AnalyticsService {
  Future<void> initialize();

  Future<void> logScreenView({required String screenName, String? screenClass});

  Future<void> logPlannerViewed({required bool hasStoredPreferences});

  Future<void> logQuickActionTapped({required String action});

  Future<void> logOnboardingStarted({required bool isEditing});

  Future<void> logOnboardingStepViewed({required int stepIndex, required String stepName, required bool isEditing});

  Future<void> logOnboardingCompleted({
    required bool isEditing,
    required int goalsCount,
    required int dietaryPreferencesCount,
    required int mealsPerDay,
    required bool hasAllergies,
    required bool hasExcludedFoods,
    required bool hasNotes,
  });

  Future<void> logMealPlanGenerationRequested({
    required int mealsPerDay,
    required int goalsCount,
    required int dietaryPreferencesCount,
    required bool hasAllergies,
    required bool hasExcludedFoods,
    required bool hasNotes,
  });

  Future<void> logMealPlanGenerationCompleted({
    required bool success,
    int? dailyCalories,
    int? mealsCount,
    String? failureType,
  });

  Future<void> logMealPlanSaved({required bool isUpdate, required int mealsCount, required int shoppingItemsCount});

  Future<void> logMealPlanOpened({required String source, required bool isSavedPlan, required int mealsCount});

  Future<void> logMealPlanDeleted({required String source});

  Future<void> logHistoryViewed({required int savedPlansCount});

  Future<void> logShoppingChecklistReset({required int itemsCount});
}

class CombinedAnalyticsService implements AnalyticsService {
  CombinedAnalyticsService(this._services);

  final List<AnalyticsService> _services;

  @override
  Future<void> initialize() async {
    for (final service in _services) {
      await service.initialize();
    }
  }

  @override
  Future<void> logScreenView({required String screenName, String? screenClass}) async {
    for (final service in _services) {
      await service.logScreenView(screenName: screenName, screenClass: screenClass);
    }
  }

  @override
  Future<void> logPlannerViewed({required bool hasStoredPreferences}) async {
    for (final service in _services) {
      await service.logPlannerViewed(hasStoredPreferences: hasStoredPreferences);
    }
  }

  @override
  Future<void> logQuickActionTapped({required String action}) async {
    for (final service in _services) {
      await service.logQuickActionTapped(action: action);
    }
  }

  @override
  Future<void> logOnboardingStarted({required bool isEditing}) async {
    for (final service in _services) {
      await service.logOnboardingStarted(isEditing: isEditing);
    }
  }

  @override
  Future<void> logOnboardingStepViewed({
    required int stepIndex,
    required String stepName,
    required bool isEditing,
  }) async {
    for (final service in _services) {
      await service.logOnboardingStepViewed(stepIndex: stepIndex, stepName: stepName, isEditing: isEditing);
    }
  }

  @override
  Future<void> logOnboardingCompleted({
    required bool isEditing,
    required int goalsCount,
    required int dietaryPreferencesCount,
    required int mealsPerDay,
    required bool hasAllergies,
    required bool hasExcludedFoods,
    required bool hasNotes,
  }) async {
    for (final service in _services) {
      await service.logOnboardingCompleted(
        isEditing: isEditing,
        goalsCount: goalsCount,
        dietaryPreferencesCount: dietaryPreferencesCount,
        mealsPerDay: mealsPerDay,
        hasAllergies: hasAllergies,
        hasExcludedFoods: hasExcludedFoods,
        hasNotes: hasNotes,
      );
    }
  }

  @override
  Future<void> logMealPlanGenerationRequested({
    required int mealsPerDay,
    required int goalsCount,
    required int dietaryPreferencesCount,
    required bool hasAllergies,
    required bool hasExcludedFoods,
    required bool hasNotes,
  }) async {
    for (final service in _services) {
      await service.logMealPlanGenerationRequested(
        mealsPerDay: mealsPerDay,
        goalsCount: goalsCount,
        dietaryPreferencesCount: dietaryPreferencesCount,
        hasAllergies: hasAllergies,
        hasExcludedFoods: hasExcludedFoods,
        hasNotes: hasNotes,
      );
    }
  }

  @override
  Future<void> logMealPlanGenerationCompleted({
    required bool success,
    int? dailyCalories,
    int? mealsCount,
    String? failureType,
  }) async {
    for (final service in _services) {
      await service.logMealPlanGenerationCompleted(
        success: success,
        dailyCalories: dailyCalories,
        mealsCount: mealsCount,
        failureType: failureType,
      );
    }
  }

  @override
  Future<void> logMealPlanSaved({
    required bool isUpdate,
    required int mealsCount,
    required int shoppingItemsCount,
  }) async {
    for (final service in _services) {
      await service.logMealPlanSaved(
        isUpdate: isUpdate,
        mealsCount: mealsCount,
        shoppingItemsCount: shoppingItemsCount,
      );
    }
  }

  @override
  Future<void> logMealPlanOpened({required String source, required bool isSavedPlan, required int mealsCount}) async {
    for (final service in _services) {
      await service.logMealPlanOpened(source: source, isSavedPlan: isSavedPlan, mealsCount: mealsCount);
    }
  }

  @override
  Future<void> logMealPlanDeleted({required String source}) async {
    for (final service in _services) {
      await service.logMealPlanDeleted(source: source);
    }
  }

  @override
  Future<void> logHistoryViewed({required int savedPlansCount}) async {
    for (final service in _services) {
      await service.logHistoryViewed(savedPlansCount: savedPlansCount);
    }
  }

  @override
  Future<void> logShoppingChecklistReset({required int itemsCount}) async {
    for (final service in _services) {
      await service.logShoppingChecklistReset(itemsCount: itemsCount);
    }
  }
}

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});

final appsFlyerAnalyticsProvider = Provider<AnalyticsService>((ref) {
  return AppsFlyerAppAnalyticsService(
    devKey: dotenv.env['APPSFLYER_DEV_KEY'] ?? '',
    appId: dotenv.env['APPSFLYER_APP_ID'] ?? '',
  );
});

final appMetricaAnalyticsProvider = Provider<AnalyticsService>((ref) {
  return AppMetricaAnalyticsService(dotenv.env['APPMETRICA_API_KEY'] ?? '');
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return CombinedAnalyticsService([
    FirebaseAppAnalyticsService(ref.watch(firebaseAnalyticsProvider)),
    ref.watch(appsFlyerAnalyticsProvider),
    ref.watch(appMetricaAnalyticsProvider),
  ]);
});
