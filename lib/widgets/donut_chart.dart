import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../theme/colors.dart';

class CupertinoDonutChart extends StatefulWidget {
  final Map<String, double> categoryRatios;
  final double totalAmount;

  const CupertinoDonutChart({
    super.key,
    required this.categoryRatios,
    required this.totalAmount,
  });

  @override
  State<CupertinoDonutChart> createState() => _CupertinoDonutChartState();
}

class _CupertinoDonutChartState extends State<CupertinoDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CupertinoDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-run the animation slightly if data changes
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final totalText = '฿${widget.totalAmount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0x20000000)
                  : const Color(0x0A000000),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: DonutChartPainter(
                          categoryRatios: widget.categoryRatios,
                          animationValue: _animation.value,
                          isDark: isDark,
                        ),
                      ),
                      // Center texts
                      FadeTransition(
                        opacity: _animation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'รายจ่ายรวม',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondaryLabel(context),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalText,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.label(context),
                                letterSpacing: -0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            if (widget.categoryRatios.isNotEmpty) ...[
              const SizedBox(height: 24),
              // Segment grid legend
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: widget.categoryRatios.entries.map((entry) {
                  final category = entry.key;
                  final percentage = entry.value * 100;
                  final color = AppColors.getCategoryColor(category);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$category (${percentage.toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.label(context).withOpacity(0.8),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final Map<String, double> categoryRatios;
  final double animationValue;
  final bool isDark;

  DonutChartPainter({
    required this.categoryRatios,
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 24.0;
    final double radius = min(size.width, size.height) / 2 - strokeWidth / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Draw background placeholder gray ring
    final Paint bgPaint = Paint()
      ..color = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (categoryRatios.isEmpty) return;

    // 2. Draw arcs for each category
    double startAngle = -pi / 2; // Start from top

    // To add micro-spaces/gaps between arcs, we account for number of categories
    final int categoryCount = categoryRatios.length;
    final double gapSize = categoryCount > 1 ? 0.035 : 0.0; // gap in radians

    for (var entry in categoryRatios.entries) {
      final category = entry.key;
      final ratio = entry.value;
      final double rawSweepAngle = ratio * 2 * pi;
      final double animatedSweepAngle = rawSweepAngle * animationValue;

      // Adjust sweep angle slightly for spaces/gaps if we have multiple categories
      final double sweepAngle = max(0.0, animatedSweepAngle - gapSize);

      if (sweepAngle > 0.0) {
        final Paint slicePaint = Paint()
          ..color = AppColors.getCategoryColor(category)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(rect, startAngle + (gapSize / 2), sweepAngle, false, slicePaint);
      }

      startAngle += rawSweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.categoryRatios != categoryRatios ||
        oldDelegate.isDark != isDark;
  }
}
