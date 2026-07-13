// lib/screens/schedule_screen.dart
// SceneFlow - Shooting Schedule Screen

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_provider.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final schedule = provider.schedule;
    final scenes = provider.scenes;
    final characters = provider.characters;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'PRODUCTION PLANNER',
                style: GoogleFonts.inter(
                  color: AppColors.goldLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Shooting Schedule',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Các cảnh cùng địa điểm được tự động gom nhóm thành từng ngày quay đề xuất.',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 24),

              if (schedule.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.event_note_outlined,
                            color: AppColors.textMuted, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có phân cảnh nào để lập lịch.\nHãy thêm phân cảnh ở Story Board trước.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

              // Schedule sessions
              ...schedule.map((session) {
                final sessionScenes = scenes.where((s) => session.sceneIds.contains(s.id)).toList();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Session header
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.locationName,
                                  style: GoogleFonts.inter(
                                    color: AppColors.gold,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  session.settingHeader,
                                  style: GoogleFonts.inter(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${session.scenesCount} Scenes',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: AppColors.teal,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Est. ${session.estimatedHours} Hours',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: AppColors.border, thickness: 1, height: 1),
                      const SizedBox(height: 12),

                      // Scene cards in this session
                      ...sessionScenes.map((scene) {
                        final sceneChars = characters
                            .where((c) => scene.characterIds.contains(c.id))
                            .toList();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            padding: const EdgeInsets.all(14),
                            onTap: () => provider.selectScene(scene.id),
                            child: Row(
                              children: [
                                // Scene code
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldLight.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: AppColors.goldLight.withValues(alpha: 0.20)),
                                  ),
                                  child: Text(
                                    scene.code,
                                    style: GoogleFonts.jetBrainsMono(
                                      color: AppColors.goldLight,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Title & pages
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        scene.title,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        scene.pages,
                                        style: GoogleFonts.inter(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Character avatars
                                Row(
                                  children: sceneChars.take(3).map((char) {
                                    final idx = sceneChars.indexOf(char);
                                    return Transform.translate(
                                      offset: Offset(-6.0 * idx, 0),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: const Color(0xFF131313), width: 2),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Image.network(
                                          char.avatarUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const CircleAvatar(
                                            backgroundColor: AppColors.surfaceAlt,
                                            child:
                                            Icon(Icons.person, size: 12, color: AppColors.textMuted),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      if (sessionScenes.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No scenes mapped to this shoot day.',
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // Info FAB — explains the auto-grouping logic (no manual "add
        // session" here since the schedule is always computed live from
        // Scenes + Locations, per F4.1).
        Positioned(
          bottom: 100,
          right: 20,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text('Auto-Scheduling',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
                  content: Text(
                    'Lịch quay được tự động tạo bằng cách gom nhóm tất cả các '
                        'phân cảnh có cùng Bối cảnh (Location) lại thành một ngày '
                        'quay đề xuất. Thêm/sửa phân cảnh ở Story Board hoặc thêm '
                        'bối cảnh mới ở tab Locations để cập nhật lịch này.',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('OK',
                          style: GoogleFonts.inter(
                              color: AppColors.goldLight, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(Icons.info_outline, color: Color(0xFF402D00), size: 24),
            ),
          ),
        ),
      ],
    );
  }
}
