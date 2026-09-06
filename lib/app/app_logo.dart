import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';

/// Refocus Again brand mark.
///
/// A vector-drawn concentric "focus target" (an outer ring, an inner ring and a
/// solid core) rendered with the app's primary/cyan palette. Being vector-based
/// it stays crisp at any [size] and needs no bundled image asset, so it can be
/// reused across the welcome screen, app bars, empty states, etc.
///
/// If [showWordmark] is true the "REFOCUS AGAIN" wordmark is shown beneath the
/// mark.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const AppLogo({
    super.key,
    this.size = 72,
    this.showWordmark = false,
  });

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FocusTargetPainter(),
      ),
    );

    if (!showWordmark) return mark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(height: size * 0.28),
        Text(
          'REFOCUS AGAIN',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: size * 0.2,
            fontWeight: FontWeight.w800,
            letterSpacing: size * 0.06,
          ),
        ),
      ],
    );
  }
}

class _FocusTargetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Rounded badge backdrop.
    final backdropRect = RRect.fromRectAndRadius(
      Rect.fromCircle(center: center, radius: maxRadius),
      Radius.circular(size.width * 0.24),
    );
    canvas.drawRRect(
      backdropRect,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.surfaceElevated,
    );
    canvas.drawRRect(
      backdropRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.012
        ..color = AppColors.primary.withValues(alpha: 0.25),
    );

    // Outer focus ring (violet).
    canvas.drawCircle(
      center,
      maxRadius * 0.52,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.05
        ..color = AppColors.primary,
    );

    // Two converging aperture arcs (aqua) forming a lens.
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.043
      ..color = AppColors.cyan;
    final arcRect = Rect.fromCircle(center: center, radius: maxRadius * 0.38);
    // Top-right arc: from top (-90deg) sweeping 90deg to the right.
    canvas.drawArc(arcRect, -math.pi / 2, math.pi / 2, false, arcPaint);
    // Bottom-left arc: from bottom (90deg) sweeping 90deg to the left.
    canvas.drawArc(arcRect, math.pi / 2, math.pi / 2, false, arcPaint);

    // Center core with an ink hole.
    canvas.drawCircle(
      center,
      maxRadius * 0.155,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.purple,
    );
    canvas.drawCircle(
      center,
      maxRadius * 0.07,
      Paint()
        ..style = PaintingStyle.fill
        ..color = AppColors.background,
    );
  }

  @override
  bool shouldRepaint(covariant _FocusTargetPainter oldDelegate) => false;
}
