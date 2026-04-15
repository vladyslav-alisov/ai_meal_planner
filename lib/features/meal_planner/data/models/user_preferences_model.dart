import '../../domain/entities/user_preferences.dart';

class UserPreferencesModel extends UserPreferences {
  const UserPreferencesModel({
    required super.age,
    required super.sex,
    required super.heightCm,
    required super.weightKg,
    required super.goals,
    required super.activityLevel,
    required super.dietaryPreferences,
    required super.cookingLevel,
    required super.timeConstraint,
    required super.allergies,
    required super.excludedFoods,
    required super.mealsPerDay,
    required super.notes,
  });

  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    return UserPreferencesModel(
      age: entity.age,
      sex: entity.sex,
      heightCm: entity.heightCm,
      weightKg: entity.weightKg,
      goals: List<String>.from(entity.goals),
      activityLevel: entity.activityLevel,
      dietaryPreferences: List<String>.from(entity.dietaryPreferences),
      cookingLevel: entity.cookingLevel,
      timeConstraint: entity.timeConstraint,
      allergies: List<String>.from(entity.allergies),
      excludedFoods: List<String>.from(entity.excludedFoods),
      mealsPerDay: entity.mealsPerDay,
      notes: entity.notes,
    );
  }

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      age: _asInt(json['age']),
      sex: json['sex']?.toString() ?? '',
      heightCm: _asDouble(json['heightCm']),
      weightKg: _asDouble(json['weightKg']),
      goals: _asStringList(json['goals'] ?? json['goal']),
      activityLevel: json['activityLevel']?.toString() ?? '',
      dietaryPreferences: _asStringList(json['dietaryPreferences'] ?? json['dietaryPreference']),
      cookingLevel: json['cookingLevel']?.toString() ?? '',
      timeConstraint: json['timeConstraint']?.toString() ?? '',
      allergies: _asStringList(json['allergies']),
      excludedFoods: _asStringList(json['excludedFoods']),
      mealsPerDay: _asInt(json['mealsPerDay']),
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'sex': sex,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'goals': goals,
      'activityLevel': activityLevel,
      'dietaryPreferences': dietaryPreferences,
      'cookingLevel': cookingLevel,
      'timeConstraint': timeConstraint,
      'allergies': allergies,
      'excludedFoods': excludedFoods,
      'mealsPerDay': mealsPerDay,
      'notes': notes,
    };
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

  static double _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }

    return const [];
  }
}
