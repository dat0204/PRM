// lib/widgets/app_header.dart
// SceneFlow - App top header bar

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onProfileClick;

  const AppHeader({
    super.key,
    this.title = 'SCENE_FLOW',
    this.showBack = false,
    this.onBack,
    this.onProfileClick,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left: Back button or film icon
              Align(
                alignment: Alignment.centerLeft,
                child: showBack
                    ? GestureDetector(
                        onTap: onBack,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.transparent,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.movie_filter_outlined,
                        color: AppColors.goldLight,
                        size: 20,
                      ),
              ),

              // Center: Title
              Text(
                title,
                style: GoogleFonts.inter(
                  color: AppColors.goldLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 3,
                ),
              ),

              // Right: Profile avatar
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onProfileClick,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                      color: AppColors.card,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDFVjOqzr_V34fHZZurstj2hCp_C_20QXKN3-kJhwNoUpgqDp8tVoLzz7tpMR4gAEu0T4R5sPy9CvDQHClUUz5pbGijC_sb1SFma9gjhicwHQPX47WoDXktD4czRjHQHgHeTBHG2wnU80_Tjc1cMSGHrzergu4FxDx0qUP3wHgaaQwDIDmeea6DAhcTKYoNGxDt7drjmDh1qoMvftBbnmC-zmWf2-S2wZnekqqhUOEoHOd9m8-yB6MKh6_25cGbQGxQp3eg8LwmddE',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
