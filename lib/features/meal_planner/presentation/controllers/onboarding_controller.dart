import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../domain/entities/user_preferences.dart';
import 'meal_planner_providers.dart';

class OnboardingState {
  const OnboardingState({
    this.currentPage = 0,
    this.preferences,
    this.isComplete = false,
  });

  final int currentPage;
  final UserPreferences? preferences;
  final bool isComplete;

  OnboardingState copyWith({
    int? currentPage,
    UserPreferences? preferences,
    bool? isComplete,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      preferences: preferences ?? this.preferences,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  void updatePreferences(UserPreferences prefs) {
    state = state.copyWith(preferences: prefs);
  }

  void nextStep() {
    state = state.copyWith(currentPage: state.currentPage + 1);
  }

  void previousStep() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  Future<void> completeOnboarding({required bool isEditing}) async {
    if (state.preferences == null) return;

    final preferences = state.preferences!;
    final localSource = ref.read(userPreferencesLocalSourceProvider);
    await localSource.saveUserPreferences(preferences);
    await localSource.setOnboardingComplete(true);
    await ref
        .read(analyticsServiceProvider)
        .logOnboardingCompleted(
          isEditing: isEditing,
          goalsCount: preferences.goals.length,
          dietaryPreferencesCount: preferences.dietaryPreferences.length,
          mealsPerDay: preferences.mealsPerDay,
          hasAllergies: preferences.allergies.isNotEmpty,
          hasExcludedFoods: preferences.excludedFoods.isNotEmpty,
          hasNotes: preferences.notes.trim().isNotEmpty,
        );

    state = state.copyWith(isComplete: true);
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
