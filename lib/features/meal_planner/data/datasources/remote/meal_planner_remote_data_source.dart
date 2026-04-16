import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/errors/app_exceptions.dart';
import '../../../../../core/utils/json_utils.dart';
import '../../models/meal_plan_model.dart';
import '../../models/user_preferences_model.dart';
import '../../../domain/entities/user_preferences.dart';

abstract class MealPlannerRemoteDataSource {
  Future<MealPlanModel> generateMealPlan(UserPreferences preferences);
}

class GeminiMealPlannerRemoteDataSource implements MealPlannerRemoteDataSource {
  GeminiMealPlannerRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<MealPlanModel> generateMealPlan(UserPreferences preferences) async {
    final apiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
    if (apiKey.isEmpty) {
      throw const ValidationException(
        'Missing AI API key. Add GEMINI_API_KEY to your .env file.',
      );
    }

    final userPreferences = UserPreferencesModel.fromEntity(preferences);
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/models/${AppConstants.geminiModel}:generateContent',
        queryParameters: {'key': apiKey},
        data: {
          'contents': [
            {
              'parts': [
                {'text': _buildPrompt(userPreferences)},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'responseMimeType': 'application/json',
            'responseSchema': _responseSchema,
          },
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == HttpStatus.unauthorized ||
          response.statusCode == HttpStatus.forbidden) {
        throw const ApiException(
          'The AI service rejected the API key. Please verify your configuration.',
        );
      }

      if (response.statusCode != HttpStatus.ok) {
        final message =
            response.data?['error']?['message']?.toString() ??
            'The AI service could not generate a meal plan right now.';
        throw ApiException(message);
      }

      final candidates = response.data?['candidates'];
      if (candidates is! List || candidates.isEmpty) {
        throw const ApiException('The AI service returned an empty response.');
      }

      final parts = candidates.first['content']?['parts'];
      if (parts is! List || parts.isEmpty) {
        throw const ParsingException(
          'The AI service response did not contain JSON.',
        );
      }

      final rawText = parts.first['text']?.toString() ?? '';
      final json = JsonUtils.decodeJsonObject(rawText);
      final mealPlan = MealPlanModel.fromJson(
        json,
        userPreferences: userPreferences,
      );

      if (mealPlan.meals.isEmpty || mealPlan.shoppingList.isEmpty) {
        throw const ParsingException(
          'The AI service returned incomplete meal plan data.',
        );
      }

      return mealPlan;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.error is SocketException) {
        throw const NetworkException(
          'Please check your internet connection and try again.',
        );
      }
      throw const NetworkException(
        'The AI service is temporarily unreachable. Please try again later.',
      );
    } on FormatException {
      throw const ParsingException(
        'Malformed JSON returned by the AI service.',
      );
    }
  }

  String _buildPrompt(UserPreferencesModel preferences) {
    return '''
You are generating a single-day meal plan for a general lifestyle meal planning app. This is not a medical app, and you must not give medical disclaimers or disease treatment advice.

Create a realistic, practical meal plan that matches the user's profile as closely as possible.

User profile:
- Age: ${preferences.age}
- Sex: ${preferences.sex}
- Height (cm): ${preferences.heightCm}
- Weight (kg): ${preferences.weightKg}
- Goal: ${preferences.goals.join(', ')}
- Activity level: ${preferences.activityLevel}
- Dietary preference: ${preferences.dietaryPreferences.join(', ')}
- Cooking experience: ${preferences.cookingLevel}
- Prep time constraint: ${preferences.timeConstraint}
- Allergies: ${preferences.allergies.isEmpty ? 'None' : preferences.allergies.join(', ')}
- Excluded foods: ${preferences.excludedFoods.isEmpty ? 'None' : preferences.excludedFoods.join(', ')}
- Meals per day: ${preferences.mealsPerDay}
- Notes: ${preferences.notes.isEmpty ? 'None' : preferences.notes}

Requirements:
- Return valid JSON only.
- Generate exactly ${preferences.mealsPerDay} meals.
- Use metric units where helpful.
- Keep the plan approachable for everyday cooking.
- Include concise instructions for each meal.
- Shopping list should combine ingredients and remove duplicates when possible.
- Set calories and macros for the whole day and for each meal.
''';
  }
}

const Map<String, dynamic> _responseSchema = {
  'type': 'OBJECT',
  'required': ['dailyCalories', 'macros', 'mealPlan', 'shoppingList'],
  'properties': {
    'dailyCalories': {'type': 'INTEGER'},
    'macros': {
      'type': 'OBJECT',
      'required': ['proteinGrams', 'carbsGrams', 'fatGrams'],
      'properties': {
        'proteinGrams': {'type': 'INTEGER'},
        'carbsGrams': {'type': 'INTEGER'},
        'fatGrams': {'type': 'INTEGER'},
      },
    },
    'mealPlan': {
      'type': 'ARRAY',
      'items': {
        'type': 'OBJECT',
        'required': [
          'name',
          'calories',
          'proteinGrams',
          'carbsGrams',
          'fatGrams',
          'ingredients',
          'instructions',
        ],
        'properties': {
          'name': {'type': 'STRING'},
          'calories': {'type': 'INTEGER'},
          'proteinGrams': {'type': 'INTEGER'},
          'carbsGrams': {'type': 'INTEGER'},
          'fatGrams': {'type': 'INTEGER'},
          'ingredients': {
            'type': 'ARRAY',
            'items': {'type': 'STRING'},
          },
          'instructions': {'type': 'STRING'},
        },
      },
    },
    'shoppingList': {
      'type': 'ARRAY',
      'items': {'type': 'STRING'},
    },
  },
};
