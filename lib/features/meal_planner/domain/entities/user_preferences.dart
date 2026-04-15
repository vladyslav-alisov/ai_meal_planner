import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  const UserPreferences({
    required this.age,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.goals,
    required this.activityLevel,
    required this.dietaryPreferences,
    required this.cookingLevel,
    required this.timeConstraint,
    required this.allergies,
    required this.excludedFoods,
    required this.mealsPerDay,
    required this.notes,
  });

  final int age;
  final String sex;
  final double heightCm;
  final double weightKg;
  final List<String> goals;
  final String activityLevel;
  final List<String> dietaryPreferences;
  final String cookingLevel;
  final String timeConstraint;
  final List<String> allergies;
  final List<String> excludedFoods;
  final int mealsPerDay;
  final String notes;

  @override
  List<Object?> get props => [
    age,
    sex,
    heightCm,
    weightKg,
    goals,
    activityLevel,
    dietaryPreferences,
    cookingLevel,
    timeConstraint,
    allergies,
    excludedFoods,
    mealsPerDay,
    notes,
  ];
}
