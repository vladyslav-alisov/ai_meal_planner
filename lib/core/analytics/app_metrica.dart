import 'package:ai_meal_planner/core/analytics/analytics_service.dart';
import 'package:ai_meal_planner/core/analytics/utils.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';

class AppMetricaAnalyticsService implements AnalyticsService {
  AppMetricaAnalyticsService(this._apiKey);

  final String _apiKey;
  bool _isInitialized = false;

  bool get _isConfigured => _apiKey.trim().isNotEmpty;

  @override
  Future<void> initialize() async {
    if (_isInitialized || !_isConfigured) {
      return;
    }

    await runSafely(
      () => AppMetrica.activate(
        AppMetricaConfig(
          _apiKey.trim(),
          logs: false,
          crashReporting: true,
          nativeCrashReporting: true,
          flutterCrashReporting: true,
          appOpenTrackingEnabled: true,
          revenueAutoTrackingEnabled: true,
        ),
      ),
    );
    _isInitialized = true;
  }

  @override
  Future<void> logScreenView({required String screenName, String? screenClass}) {
    final parameters = <String, Object>{'screen_name': screenName};
    if (screenClass != null) {
      parameters['screen_class'] = screenClass;
    }
    return _reportEvent('screen_view', parameters);
  }

  @override
  Future<void> logPlannerViewed({required bool hasStoredPreferences}) {
    return _reportEvent('planner_viewed', {'has_stored_preferences': hasStoredPreferences});
  }

  @override
  Future<void> logQuickActionTapped({required String action}) {
    return _reportEvent('quick_action_tapped', {'action': action});
  }

  @override
  Future<void> logOnboardingStarted({required bool isEditing}) {
    return _reportEvent('onboarding_started', {'is_editing': isEditing});
  }

  @override
  Future<void> logOnboardingStepViewed({required int stepIndex, required String stepName, required bool isEditing}) {
    return _reportEvent('onboarding_step_viewed', {
      'step_index': stepIndex,
      'step_name': stepName,
      'is_editing': isEditing,
    });
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
  }) {
    return _reportEvent('onboarding_completed', {
      'is_editing': isEditing,
      'goals_count': goalsCount,
      'dietary_preferences_count': dietaryPreferencesCount,
      'meals_per_day': mealsPerDay,
      'has_allergies': hasAllergies,
      'has_excluded_foods': hasExcludedFoods,
      'has_notes': hasNotes,
    });
  }

  @override
  Future<void> logMealPlanGenerationRequested({
    required int mealsPerDay,
    required int goalsCount,
    required int dietaryPreferencesCount,
    required bool hasAllergies,
    required bool hasExcludedFoods,
    required bool hasNotes,
  }) {
    return _reportEvent('meal_plan_generation_requested', {
      'meals_per_day': mealsPerDay,
      'goals_count': goalsCount,
      'dietary_preferences_count': dietaryPreferencesCount,
      'has_allergies': hasAllergies,
      'has_excluded_foods': hasExcludedFoods,
      'has_notes': hasNotes,
    });
  }

  @override
  Future<void> logMealPlanGenerationCompleted({
    required bool success,
    int? dailyCalories,
    int? mealsCount,
    String? failureType,
  }) {
    final parameters = <String, Object>{'success': success};
    if (dailyCalories != null) {
      parameters['daily_calories'] = dailyCalories;
    }
    if (mealsCount != null) {
      parameters['meals_count'] = mealsCount;
    }
    if (failureType != null) {
      parameters['failure_type'] = failureType;
    }
    return _reportEvent('meal_plan_generation_completed', parameters);
  }

  @override
  Future<void> logMealPlanSaved({required bool isUpdate, required int mealsCount, required int shoppingItemsCount}) {
    return _reportEvent('meal_plan_saved', {
      'is_update': isUpdate,
      'meals_count': mealsCount,
      'shopping_items_count': shoppingItemsCount,
    });
  }

  @override
  Future<void> logMealPlanOpened({required String source, required bool isSavedPlan, required int mealsCount}) {
    return _reportEvent('meal_plan_opened', {
      'source': source,
      'is_saved_plan': isSavedPlan,
      'meals_count': mealsCount,
    });
  }

  @override
  Future<void> logMealPlanDeleted({required String source}) {
    return _reportEvent('meal_plan_deleted', {'source': source});
  }

  @override
  Future<void> logHistoryViewed({required int savedPlansCount}) {
    return _reportEvent('history_viewed', {'saved_plans_count': savedPlansCount});
  }

  @override
  Future<void> logShoppingChecklistReset({required int itemsCount}) {
    return _reportEvent('shopping_checklist_reset', {'items_count': itemsCount});
  }

  Future<void> _reportEvent(String name, Map<String, Object> attributes) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_isConfigured) {
      return;
    }

    await runSafely(() => AppMetrica.reportEventWithMap(name, attributes));
  }
}
