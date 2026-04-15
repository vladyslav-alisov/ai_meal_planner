import 'package:equatable/equatable.dart';

import 'macro_breakdown.dart';
import 'meal_entry.dart';
import 'user_preferences.dart';

class MealPlan extends Equatable {
  const MealPlan({
    this.id,
    this.createdAt,
    required this.userPreferences,
    required this.dailyCalories,
    required this.macros,
    required this.meals,
    required this.shoppingList,
  });

  final int? id;
  final DateTime? createdAt;
  final UserPreferences userPreferences;
  final int dailyCalories;
  final MacroBreakdown macros;
  final List<MealEntry> meals;
  final List<String> shoppingList;

  MealPlan copyWith({
    int? id,
    DateTime? createdAt,
    UserPreferences? userPreferences,
    int? dailyCalories,
    MacroBreakdown? macros,
    List<MealEntry>? meals,
    List<String>? shoppingList,
  }) {
    return MealPlan(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      userPreferences: userPreferences ?? this.userPreferences,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      macros: macros ?? this.macros,
      meals: meals ?? this.meals,
      shoppingList: shoppingList ?? this.shoppingList,
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    userPreferences,
    dailyCalories,
    macros,
    meals,
    shoppingList,
  ];
}
