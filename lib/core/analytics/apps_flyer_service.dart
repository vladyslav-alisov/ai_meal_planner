import 'package:ai_meal_planner/core/analytics/analytics_service.dart';
import 'package:ai_meal_planner/core/analytics/utils.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

class AppsFlyerAppAnalyticsService implements AnalyticsService {
  AppsFlyerAppAnalyticsService({required String devKey, required String appId})
    : _devKey = devKey.trim(),
      _appId = appId.trim();

  final String _devKey;
  final String _appId;

  AppsflyerSdk? _sdk;
  bool _isInitialized = false;

  bool get _isConfigured => _devKey.isNotEmpty && _appId.isNotEmpty;

  @override
  Future<void> initialize() async {
    if (_isInitialized || !_isConfigured) {
      return;
    }

    final options = AppsFlyerOptions(
      afDevKey: _devKey,
      appId: _appId,
      showDebug: false,
      timeToWaitForATTUserAuthorization: 30.0,
    );

    final sdk = AppsflyerSdk(options);
    await runSafely(
      () => sdk.initSdk(
        registerConversionDataCallback: false,
        registerOnAppOpenAttributionCallback: false,
        registerOnDeepLinkingCallback: false,
      ),
    );
    _sdk = sdk;
    _isInitialized = true;
  }

  @override
  Future<void> logScreenView({required String screenName, String? screenClass}) {
    final parameters = <String, dynamic>{'screen_name': screenName};
    if (screenClass != null) {
      parameters['screen_class'] = screenClass;
    }
    return _logEvent('af_screen_view', parameters);
  }

  @override
  Future<void> logPlannerViewed({required bool hasStoredPreferences}) {
    return _logEvent('af_planner_viewed', {'has_stored_preferences': hasStoredPreferences});
  }

  @override
  Future<void> logQuickActionTapped({required String action}) {
    return _logEvent('af_quick_action_tapped', {'action': action});
  }

  @override
  Future<void> logOnboardingStarted({required bool isEditing}) {
    return _logEvent('af_onboarding_started', {'is_editing': isEditing});
  }

  @override
  Future<void> logOnboardingStepViewed({required int stepIndex, required String stepName, required bool isEditing}) {
    return _logEvent('af_onboarding_step_viewed', {
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
    return _logEvent('af_onboarding_completed', {
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
    return _logEvent('af_meal_plan_generation_requested', {
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
    final parameters = <String, dynamic>{'success': success};
    if (dailyCalories != null) {
      parameters['daily_calories'] = dailyCalories;
    }
    if (mealsCount != null) {
      parameters['meals_count'] = mealsCount;
    }
    if (failureType != null) {
      parameters['failure_type'] = failureType;
    }
    return _logEvent('af_meal_plan_generation_completed', parameters);
  }

  @override
  Future<void> logMealPlanSaved({required bool isUpdate, required int mealsCount, required int shoppingItemsCount}) {
    return _logEvent('af_meal_plan_saved', {
      'is_update': isUpdate,
      'meals_count': mealsCount,
      'shopping_items_count': shoppingItemsCount,
    });
  }

  @override
  Future<void> logMealPlanOpened({required String source, required bool isSavedPlan, required int mealsCount}) {
    return _logEvent('af_meal_plan_opened', {
      'source': source,
      'is_saved_plan': isSavedPlan,
      'meals_count': mealsCount,
    });
  }

  @override
  Future<void> logMealPlanDeleted({required String source}) {
    return _logEvent('af_meal_plan_deleted', {'source': source});
  }

  @override
  Future<void> logHistoryViewed({required int savedPlansCount}) {
    return _logEvent('af_history_viewed', {'saved_plans_count': savedPlansCount});
  }

  @override
  Future<void> logShoppingChecklistReset({required int itemsCount}) {
    return _logEvent('af_shopping_checklist_reset', {'items_count': itemsCount});
  }

  Future<void> _logEvent(String name, Map<String, dynamic> values) async {
    if (!_isInitialized) {
      await initialize();
    }

    final sdk = _sdk;
    if (sdk == null) {
      return;
    }

    await runSafely(() => sdk.logEvent(name, values));
  }
}
