import '../../domain/entities/macro_breakdown.dart';

class MacroBreakdownModel extends MacroBreakdown {
  const MacroBreakdownModel({
    required super.proteinGrams,
    required super.carbsGrams,
    required super.fatGrams,
  });

  factory MacroBreakdownModel.fromEntity(MacroBreakdown entity) {
    return MacroBreakdownModel(
      proteinGrams: entity.proteinGrams,
      carbsGrams: entity.carbsGrams,
      fatGrams: entity.fatGrams,
    );
  }

  factory MacroBreakdownModel.fromJson(Map<String, dynamic> json) {
    return MacroBreakdownModel(
      proteinGrams: _asInt(json['proteinGrams']),
      carbsGrams: _asInt(json['carbsGrams']),
      fatGrams: _asInt(json['fatGrams']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
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
}
