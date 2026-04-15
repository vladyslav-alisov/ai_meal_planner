import 'dart:convert';

import '../../domain/entities/meal_plan.dart';
import 'macro_breakdown_model.dart';
import 'meal_entry_model.dart';
import 'meal_plan_record.dart';
import 'user_preferences_model.dart';

class MealPlanModel extends MealPlan {
  const MealPlanModel({
    super.id,
    super.createdAt,
    required UserPreferencesModel super.userPreferences,
    required super.dailyCalories,
    required MacroBreakdownModel super.macros,
    required List<MealEntryModel> super.meals,
    required super.shoppingList,
  });

  factory MealPlanModel.fromEntity(MealPlan entity) {
    return MealPlanModel(
      id: entity.id,
      createdAt: entity.createdAt,
      userPreferences: UserPreferencesModel.fromEntity(entity.userPreferences),
      dailyCalories: entity.dailyCalories,
      macros: MacroBreakdownModel.fromEntity(entity.macros),
      meals: entity.meals
          .map(MealEntryModel.fromEntity)
          .toList(growable: false),
      shoppingList: List<String>.from(entity.shoppingList),
    );
  }

  factory MealPlanModel.fromJson(
    Map<String, dynamic> json, {
    required UserPreferencesModel userPreferences,
  }) {
    return MealPlanModel(
      userPreferences: userPreferences,
      dailyCalories: _asInt(json['dailyCalories']),
      macros: MacroBreakdownModel.fromJson(_asMap(json['macros'])),
      meals: _asList(json['mealPlan'])
          .map((item) => MealEntryModel.fromJson(_asMap(item)))
          .toList(growable: false),
      shoppingList: _asStringList(json['shoppingList']),
      createdAt: DateTime.now(),
    );
  }

  factory MealPlanModel.fromRecord(MealPlanRecord record) {
    final macrosJson = jsonDecode(record.macrosJson) as Map<String, dynamic>;
    final mealsJson = (jsonDecode(record.mealsJson) as List)
        .cast<Map<String, dynamic>>();
    final shoppingJson = (jsonDecode(record.shoppingListJson) as List)
        .map((item) => item.toString())
        .toList(growable: false);
    final userInputJson =
        jsonDecode(record.userInputJson) as Map<String, dynamic>;

    return MealPlanModel(
      id: record.id,
      createdAt: DateTime.tryParse(record.createdAtIso),
      userPreferences: UserPreferencesModel.fromJson(userInputJson),
      dailyCalories: record.dailyCalories,
      macros: MacroBreakdownModel.fromJson(macrosJson),
      meals: mealsJson.map(MealEntryModel.fromJson).toList(growable: false),
      shoppingList: shoppingJson,
    );
  }

  MealPlanRecord toRecord() {
    return MealPlanRecord(
      id: id ?? 0,
      createdAtIso: (createdAt ?? DateTime.now()).toIso8601String(),
      goal: userPreferences.goals.join(', '),
      dailyCalories: dailyCalories,
      macrosJson: jsonEncode(MacroBreakdownModel.fromEntity(macros).toJson()),
      mealsJson: jsonEncode(
        meals.map((meal) => MealEntryModel.fromEntity(meal).toJson()).toList(),
      ),
      shoppingListJson: jsonEncode(shoppingList),
      userInputJson: jsonEncode(
        UserPreferencesModel.fromEntity(userPreferences).toJson(),
      ),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.round();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.cast<String, dynamic>();
    }

    return {};
  }

  static List<dynamic> _asList(dynamic value) {
    if (value is List) {
      return value;
    }

    return const [];
  }

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }

    return const [];
  }
}
