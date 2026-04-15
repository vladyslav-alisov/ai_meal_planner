import '../../domain/entities/meal_entry.dart';

class MealEntryModel extends MealEntry {
  const MealEntryModel({
    required super.name,
    required super.calories,
    required super.proteinGrams,
    required super.carbsGrams,
    required super.fatGrams,
    required super.ingredients,
    required super.instructions,
  });

  factory MealEntryModel.fromEntity(MealEntry entity) {
    return MealEntryModel(
      name: entity.name,
      calories: entity.calories,
      proteinGrams: entity.proteinGrams,
      carbsGrams: entity.carbsGrams,
      fatGrams: entity.fatGrams,
      ingredients: List<String>.from(entity.ingredients),
      instructions: entity.instructions,
    );
  }

  factory MealEntryModel.fromJson(Map<String, dynamic> json) {
    return MealEntryModel(
      name: json['name']?.toString() ?? '',
      calories: _asInt(json['calories']),
      proteinGrams: _asInt(json['proteinGrams']),
      carbsGrams: _asInt(json['carbsGrams']),
      fatGrams: _asInt(json['fatGrams']),
      ingredients: _asStringList(json['ingredients']),
      instructions: json['instructions']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'ingredients': ingredients,
      'instructions': instructions,
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

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }

    return const [];
  }
}
