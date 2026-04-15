class AppConstants {
  static const appName = 'AI Meal Planner';
  static const geminiModel = "gemini-2.5-flash-lite";

  ///'gemini-2.5-flash-lite';
  static const geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/';

  static const sexOptions = <String>['Female', 'Male', 'Non-binary', 'Prefer not to say'];

  static const goalOptions = <String>['Lose weight', 'Maintain weight', 'Build muscle', 'Eat more balanced meals'];

  static const activityLevelOptions = <String>['Sedentary', 'Lightly active', 'Moderately active', 'Very active'];

  static const dietaryPreferenceOptions = <String>[
    'No specific preference',
    'Mediterranean',
    'Vegetarian',
    'Vegan',
    'Pescatarian',
    'High protein',
    'Low carb',
    'Gluten free',
  ];

  static const cookingLevelOptions = <String>['Beginner', 'Intermediate', 'Advanced'];

  static const timeConstraintOptions = <String>['Under 15 mins', 'Under 30 mins', 'Under 60 mins', 'No limit'];
}
