import 'package:objectbox/objectbox.dart';

@Entity()
class MealPlanRecord {
  MealPlanRecord({
    this.id = 0,
    required this.createdAtIso,
    required this.goal,
    required this.dailyCalories,
    required this.macrosJson,
    required this.mealsJson,
    required this.shoppingListJson,
    required this.userInputJson,
  });

  @Id()
  int id;

  String createdAtIso;
  String goal;
  int dailyCalories;
  String macrosJson;
  String mealsJson;
  String shoppingListJson;
  String userInputJson;
}
