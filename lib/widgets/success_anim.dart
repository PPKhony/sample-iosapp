import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../theme/colors.dart';

class CupertinoSuccessOverlay extends StatefulWidget {
  final VoidCallback onFinished;

  const CupertinoSuccessOverlay({
    super.key,
    required this.onFinished,
  });

  @override
  State<CupertinoSuccessOverlay> createState() => _CupertinoSuccessOverlayState();
}

class _CupertinoSuccessOverlayState extends State<CupertinoSuccessOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );

    _checkAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Automatically close the overlay after animation is done
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            widget.onFinished();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Glass blur background
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: CupertinoTheme.of(context).brightness == Brightness.dark
                      ? const Color(0x901C1C1E)
                      : const Color(0x60FFFFFF),
                ),
              ),
            ),
          ),
          // Checkmark Card
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground(context),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x20000000),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: AnimatedBuilder(
                        animation: _checkAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: CheckmarkPainter(
                              progress: _checkAnimation.value,
                              color: AppColors.success,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'บันทึกสำเร็จ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.label(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw background soft circle
    canvas.drawCircle(center, radius, circlePaint);

    final Paint checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path();
    
    // Checkmark coordinates relative to size
    final double startX = size.width * 0.28;
    final double startY = size.height * 0.5;
    
    final double midX = size.width * 0.44;
    final double midY = size.height * 0.66;
    
    final double endX = size.width * 0.72;
    final double endY = size.height * 0.36;

    // Segment 1: from start to mid (downward diagonal)
    // Segment 2: from mid to end (upward diagonal)
    
    if (progress <= 0.4) {
      // First segment animation (0.0 to 0.4)
      final t = progress / 0.4;
      final currentX = startX + (midX - startX) * t;
      final currentY = startY + (midY - startY) * t;
      path.moveTo(startX, startY);
      path.lineTo(currentX, currentY);
    } else {
      // First segment is complete, animating second segment (0.4 to 1.0)
      path.moveTo(startX, startY);
      path.lineTo(midX, midY);
      
      final t = (progress - 0.4) / 0.6;
      final currentX = midX + (endX - midX) * t;
      final currentY = midY + (endY - midY) * t;
      path.lineTo(currentX, currentY);
    }

    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
