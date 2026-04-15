import 'package:ai_meal_planner/objectbox.g.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../models/meal_plan_record.dart';

class MealPlannerObjectBox {
  MealPlannerObjectBox._(this.store) : mealPlanBox = Box<MealPlanRecord>(store);

  final Store store;
  final Box<MealPlanRecord> mealPlanBox;

  static Future<MealPlannerObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final objectboxDir = path.join(docsDir.path, 'ai_meal_planner_store');
    final store = await openStore(directory: objectboxDir);
    return MealPlannerObjectBox._(store);
  }

  void close() {
    store.close();
  }
}
