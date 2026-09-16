import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Marque visuelle de l'application : un badge dégradé "ciel dégagé" avec un
/// soleil partiellement voilé par un nuage, traversé par une ligne de pouls
/// (ECG) qui symbolise le "Pulse" de WeatherPulse.
///
/// Entièrement vectoriel ([CustomPainter]) : aucune dépendance à un asset
/// bitmap, se redimensionne donc sans perte de netteté.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96, this.showBadge = true});

  final double size;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AppLogoPainter(showBadge: showBadge)),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  _AppLogoPainter({required this.showBadge});

  final bool showBadge;

  static const _badgeGradient = [
    Color(0xFF2E6FD6),
    Color(0xFF4A90E2),
    Color(0xFF8FC0EF),
  ];
  static const _sunGradient = [Color(0xFFFFE9A8), Color(0xFFFFD54F)];
  static const _cloudColor = Color(0xFFFFFFFF);
  static const _pulseColor = Color(0xFFFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final shortestSide = math.min(size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(shortestSide * 0.24),
    );

    if (showBadge) {
      final badgePaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _badgeGradient,
        ).createShader(Offset.zero & size);
      canvas.drawRRect(rrect, badgePaint);
    }

    canvas.save();
    canvas.clipRRect(rrect);
    _paintSun(canvas, size, shortestSide);
    _paintCloud(canvas, size, shortestSide);
    _paintPulse(canvas, size, shortestSide);
    canvas.restore();
  }

  void _paintSun(Canvas canvas, Size size, double s) {
    final center = Offset(size.width * 0.44, size.height * 0.40);
    final radius = s * 0.19;

    final rayPaint = Paint()
      ..color = _sunGradient.last.withValues(alpha: 0.9)
      ..strokeWidth = s * 0.025
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final angle = (math.pi * 2 / 8) * i;
      final inner = center + Offset(math.cos(angle), math.sin(angle)) * (radius * 1.35);
      final outer = center + Offset(math.cos(angle), math.sin(angle)) * (radius * 1.9);
      canvas.drawLine(inner, outer, rayPaint);
    }

    final sunPaint = Paint()
      ..shader = const RadialGradient(colors: _sunGradient).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, sunPaint);
  }

  void _paintCloud(Canvas canvas, Size size, double s) {
    final baseY = size.height * 0.62;
    final cloudPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(size.width * 0.34, baseY - s * 0.06), radius: s * 0.17))
      ..addOval(Rect.fromCircle(center: Offset(size.width * 0.52, baseY - s * 0.13), radius: s * 0.22))
      ..addOval(Rect.fromCircle(center: Offset(size.width * 0.70, baseY - s * 0.02), radius: s * 0.16))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.20, baseY - s * 0.02, size.width * 0.60, s * 0.16),
          Radius.circular(s * 0.08),
        ),
      );
    final merged = cloudPath;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(merged.shift(Offset(0, s * 0.015)), shadowPaint);

    canvas.drawPath(merged, Paint()..color = _cloudColor);
  }

  void _paintPulse(Canvas canvas, Size size, double s) {
    final y = size.height * 0.76;
    final path = Path()
      ..moveTo(size.width * 0.10, y)
      ..lineTo(size.width * 0.34, y)
      ..lineTo(size.width * 0.42, y - s * 0.10)
      ..lineTo(size.width * 0.50, y + s * 0.20)
      ..lineTo(size.width * 0.58, y - s * 0.16)
      ..lineTo(size.width * 0.66, y)
      ..lineTo(size.width * 0.90, y);

    final glowPaint = Paint()
      ..color = _pulseColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path, glowPaint);

    final linePaint = Paint()
      ..color = _pulseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.028
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _AppLogoPainter oldDelegate) =>
      oldDelegate.showBadge != showBadge;
}
