import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MpGlassCard extends StatelessWidget {
  const MpGlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.blur = 12.0,
    this.borderOpacity = 0.2,
    this.fillOpacity = 0.08,
    this.borderColor,
    this.gradient,
    this.onTap,
    this.height,
    this.width,
  });

  final Widget child;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double borderOpacity;
  final double fillOpacity;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? 24.0;
    
    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassFill.withValues(alpha: fillOpacity),
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: Border.all(
          color: (borderColor ?? Colors.white).withValues(alpha: borderOpacity),
          width: 1.2,
        ),
        gradient: gradient,
      ),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(effectiveRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      ),
    );
  }
}
