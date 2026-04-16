import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/app_theme.dart';
import 'features/meal_planner/data/datasources/local/objectbox_store.dart';
import 'features/meal_planner/presentation/controllers/meal_planner_providers.dart';
import 'features/meal_planner/presentation/screens/onboarding/onboarding_screen.dart';
import 'features/meal_planner/presentation/screens/planner_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  final objectBox = await MealPlannerObjectBox.create();

  runApp(
    ProviderScope(
      overrides: [mealPlannerObjectBoxProvider.overrideWithValue(objectBox)],
      child: const AiMealPlannerApp(),
    ),
  );
}

class AiMealPlannerApp extends ConsumerWidget {
  const AiMealPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Consumer(
        builder: (context, ref, _) {
          final localSource = ref.watch(userPreferencesLocalSourceProvider);
          return FutureBuilder<bool>(
            future: localSource.isOnboardingComplete(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data == true) {
                return const PlannerScreen();
              }

              return const OnboardingScreen();
            },
          );
        },
      ),
    );
  }
}
