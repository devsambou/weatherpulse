import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Composant réutilisable Glassmorphism premium.
///
/// Encapsule ClipRRect + BackdropFilter (avec ImageFilter.blur) et applique
/// une bordure subtile et un fond translucide adapté aux thèmes clair et sombre.
/// Inclut une option de repli [enableBlur] pour économiser le GPU sur appareils modestes.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blurSigma = 12.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.enableBlur = true,
    this.boxShadow,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final bool enableBlur;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? WeatherPalette.glassBackground(context);
    final border = borderColor ?? WeatherPalette.glassBorder(context);

    final decoration = BoxDecoration(
      color: bg,
      borderRadius: borderRadius,
      border: Border.all(color: border, width: borderWidth),
      boxShadow:
          boxShadow ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
    );

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (enableBlur && blurSigma > 0) {
      content = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      );
    }

    Widget wrapped = ClipRRect(borderRadius: borderRadius, child: content);

    if (margin != null) {
      wrapped = Padding(padding: margin!, child: wrapped);
    }

    return wrapped;
  }
}
