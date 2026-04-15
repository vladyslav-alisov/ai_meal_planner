import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> completeOnboarding() async {
    if (state.preferences == null) return;
    
    final localSource = ref.read(userPreferencesLocalSourceProvider);
    await localSource.saveUserPreferences(state.preferences!);
    await localSource.setOnboardingComplete(true);
    
    state = state.copyWith(isComplete: true);
  }
}

final onboardingControllerProvider = NotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);
