// lib/widgets/tag_chip.dart
// SceneFlow - Status and genre tag chips

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum TagStyle { gold, teal, muted, success, info, warning }

class TagChip extends StatelessWidget {
  final String label;
  final TagStyle style;
  final bool showDot;
  final bool pulseDot;

  const TagChip({
    super.key,
    required this.label,
    this.style = TagStyle.muted,
    this.showDot = false,
    this.pulseDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.$2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colors.$3,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.$3,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) _getColors() {
    switch (style) {
      case TagStyle.gold:
        return (
          AppColors.goldFaint.withValues(alpha: 0.10),
          AppColors.goldFaint.withValues(alpha: 0.20),
          AppColors.goldFaint,
        );
      case TagStyle.teal:
        return (
          AppColors.teal.withValues(alpha: 0.10),
          AppColors.teal.withValues(alpha: 0.20),
          AppColors.teal,
        );
      case TagStyle.success:
        return (
          const Color(0xFF34D399).withValues(alpha: 0.10),
          const Color(0xFF34D399).withValues(alpha: 0.20),
          const Color(0xFF34D399),
        );
      case TagStyle.info:
        return (
          const Color(0xFF60A5FA).withValues(alpha: 0.10),
          const Color(0xFF60A5FA).withValues(alpha: 0.20),
          const Color(0xFF60A5FA),
        );
      case TagStyle.warning:
        return (
          AppColors.goldLight.withValues(alpha: 0.10),
          AppColors.goldLight.withValues(alpha: 0.20),
          AppColors.goldLight,
        );
      case TagStyle.muted:
      default:
        return (
          Colors.white.withValues(alpha: 0.05),
          AppColors.border,
          AppColors.textSecondary,
        );
    }
  }
}
