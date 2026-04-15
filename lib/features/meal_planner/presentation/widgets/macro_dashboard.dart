import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/entities/meal_plan.dart';

class MacroDashboard extends StatelessWidget {
  const MacroDashboard({
    required this.plan,
    required this.shrinkOffset,
    super.key,
  });

  final MealPlan plan;
  final double shrinkOffset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate progress (0.0 to 1.0) where 1.0 is fully collapsed
    final maxShrink = 180.0 - 80.0;
    final progress = (shrinkOffset / maxShrink).clamp(0.0, 1.0);
    final isCollapsed = progress > 0.8;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10 * progress, sigmaY: 10 * progress),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: isCollapsed ? 0.85 : 1.0),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05 * progress),
                width: 1,
              ),
            ),
          ),
          child: Stack(
            children: [
              // Vibrant Background Gradient (Fades out as we scroll)
              Positioned.fill(
                child: Opacity(
                  opacity: (1 - progress * 1.5).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          theme.colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: isCollapsed 
                      ? _buildCollapsedContent(context, progress)
                      : _buildExpandedContent(context, progress),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, double progress) {
    final theme = Theme.of(context);
    // Fade out faster to avoid showing overflow during shrinkage
    final opacity = (1 - progress * 2.2).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text(
              'Daily Fuel',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 110,
              height: 110,
              child: CustomPaint(
                painter: MacroRingPainter(
                  protein: plan.macros.proteinGrams.toDouble(),
                  carbs: plan.macros.carbsGrams.toDouble(),
                  fat: plan.macros.fatGrams.toDouble(),
                  proteinColor: const Color(0xFF1B998B), // Vibrant Green
                  carbsColor: const Color(0xFFFF9B42),   // Vibrant Orange
                  fatColor: const Color(0xFFE84855),     // Vibrant Red
                  strokeWidth: 12,
                  gap: 0.2,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${plan.dailyCalories}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        'kcal',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ExpandedMacro(label: 'Protein', value: '${plan.macros.proteinGrams}g', color: const Color(0xFF1B998B)),
                _VerticalDivider(),
                _ExpandedMacro(label: 'Carbs', value: '${plan.macros.carbsGrams}g', color: const Color(0xFFFF9B42)),
                _VerticalDivider(),
                _ExpandedMacro(label: 'Fats', value: '${plan.macros.fatGrams}g', color: const Color(0xFFE84855)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsedContent(BuildContext context, double progress) {
    final theme = Theme.of(context);
    final opacity = ((progress - 0.7) * 3.3).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CustomPaint(
                  painter: MacroRingPainter(
                    protein: plan.macros.proteinGrams.toDouble(),
                    carbs: plan.macros.carbsGrams.toDouble(),
                    fat: plan.macros.fatGrams.toDouble(),
                    proteinColor: const Color(0xFF1B998B),
                    carbsColor: const Color(0xFFFF9B42),
                    fatColor: const Color(0xFFE84855),
                    strokeWidth: 5,
                    gap: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${plan.dailyCalories} kcal',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Daily Targets',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _MiniMacro(value: '${plan.macros.proteinGrams}g', color: const Color(0xFF1B998B)),
              const SizedBox(width: 6),
              _MiniMacro(value: '${plan.macros.carbsGrams}g', color: const Color(0xFFFF9B42)),
              const SizedBox(width: 6),
              _MiniMacro(value: '${plan.macros.fatGrams}g', color: const Color(0xFFE84855)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpandedMacro extends StatelessWidget {
  const _ExpandedMacro({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
          ),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontWeight: FontWeight.bold,
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  const _MiniMacro({required this.value, required this.color});
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

class MacroRingPainter extends CustomPainter {
  MacroRingPainter({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinColor,
    required this.carbsColor,
    required this.fatColor,
    required this.strokeWidth,
    required this.gap,
  });

  final double protein;
  final double carbs;
  final double fat;
  final Color proteinColor;
  final Color carbsColor;
  final Color fatColor;
  final double strokeWidth;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final total = protein + carbs + fat;
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    // Initial background ring
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.black.withValues(alpha: 0.05);
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    double startAngle = -math.pi / 2;

    _drawSegment(canvas, rect, paint, protein / total, proteinColor, startAngle);
    startAngle += (protein / total) * 2 * math.pi;

    _drawSegment(canvas, rect, paint, carbs / total, carbsColor, startAngle);
    startAngle += (carbs / total) * 2 * math.pi;

    _drawSegment(canvas, rect, paint, fat / total, fatColor, startAngle);
  }

  void _drawSegment(Canvas canvas, Rect rect, Paint paint, double percentage, Color color, double startAngle) {
    if (percentage <= 0) return;
    
    paint.color = color;
    final sweepAngle = percentage * 2 * math.pi;
    final gapAngle = gap * (sweepAngle / 10); // Subtle gap proportional to size
    
    canvas.drawArc(
      rect, 
      startAngle + gapAngle, 
      sweepAngle - (gapAngle * 2), 
      false, 
      paint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MacroHeaderDelegate extends SliverPersistentHeaderDelegate {
  MacroHeaderDelegate({required this.plan});
  final MealPlan plan;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return MacroDashboard(plan: plan, shrinkOffset: shrinkOffset);
  }

  @override
  double get maxExtent => 220.0; // Increased to accommodate centered layout

  @override
  double get minExtent => 80.0;

  @override
  bool shouldRebuild(covariant MacroHeaderDelegate oldDelegate) => true;
}
