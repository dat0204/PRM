// lib/widgets/bottom_nav.dart
// SceneFlow - Bottom navigation bar

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';

class AppBottomNav extends StatelessWidget {
  final TabKey activeTab;
  final ValueChanged<TabKey> onTabChange;

  const AppBottomNav({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (TabKey.projects, Icons.folder_outlined, Icons.folder, 'Projects'),
      (TabKey.schedule, Icons.movie_creation_outlined, Icons.movie_creation, 'Board'),
      (TabKey.board, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
      (TabKey.team, Icons.people_outline, Icons.people, 'Team'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardAlt.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.map((tab) {
              final (key, iconOutline, iconFilled, label) = tab;
              final isActive = activeTab == key;
              return GestureDetector(
                onTap: () => onTabChange(key),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: isActive ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isActive ? iconFilled : iconOutline,
                          color: isActive ? AppColors.goldLight : AppColors.textMuted,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? AppColors.goldLight : AppColors.textMuted,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
