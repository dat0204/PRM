// lib/widgets/glass_card.dart
// SceneFlow - Reusable glassmorphism card widget

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? borderColor;
  final Color? bgColor;
  final VoidCallback? onTap;
  final bool isActive;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 16,
    this.borderColor,
    this.bgColor,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor ??
              (isActive
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: borderColor ?? AppColors.borderSubtle,
          ),
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
