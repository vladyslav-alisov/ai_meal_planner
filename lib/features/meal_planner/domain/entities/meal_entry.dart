import 'package:equatable/equatable.dart';

class MealEntry extends Equatable {
  const MealEntry({
    required this.name,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.ingredients,
    required this.instructions,
  });

  final String name;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final List<String> ingredients;
  final String instructions;

  @override
  List<Object?> get props => [
    name,
    calories,
    proteinGrams,
    carbsGrams,
    fatGrams,
    ingredients,
    instructions,
  ];
}
