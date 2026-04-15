import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_preferences_model.dart';
import '../../../domain/entities/user_preferences.dart';

abstract class UserPreferencesLocalSource {
  Future<void> saveUserPreferences(UserPreferences preferences);
  Future<UserPreferences?> getUserPreferences();
  Future<void> setOnboardingComplete(bool complete);
  Future<bool> isOnboardingComplete();
}

class SharedPrefsUserPreferencesLocalSource implements UserPreferencesLocalSource {
  static const _keyPreferences = 'user_preferences';
  static const _keyOnboardingComplete = 'onboarding_complete';

  @override
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final model = UserPreferencesModel.fromEntity(preferences);
    await prefs.setString(_keyPreferences, jsonEncode(model.toJson()));
  }

  @override
  Future<UserPreferences?> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyPreferences);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserPreferencesModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, complete);
  }

  @override
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }
}
