import 'package:equatable/equatable.dart';

class MacroBreakdown extends Equatable {
  const MacroBreakdown({
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;

  @override
  List<Object?> get props => [proteinGrams, carbsGrams, fatGrams];
}
