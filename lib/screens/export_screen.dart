// lib/screens/export_screen.dart
// SceneFlow - Export / Report Screen (F5.2)
//
// Cho phép cấu hình định dạng báo cáo (khổ giấy, có kèm hồ sơ nhân vật
// hay không, có kèm toàn bộ lời thoại/hành động hay chỉ tóm tắt) rồi
// xuất ra file PDF chuẩn hóa, hỗ trợ đầy đủ tiếng Việt có dấu.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/scene.dart';
import '../providers/app_provider.dart';
import '../services/pdf_export_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  PdfExportOptions _options = const PdfExportOptions();
  bool _isExporting = false;

  Future<void> _runExport(AppProvider provider, {required bool share}) async {
    final project = provider.activeProject;
    final scenes = provider.scenes.where((s) => s.projectId == project.id).toList();

    setState(() => _isExporting = true);
    try {
      if (share) {
        await PdfExportService.shareReport(
          project: project,
          characters: provider.characters,
          scenes: scenes,
          locations: provider.locations,
          options: _options,
        );
      } else {
        await PdfExportService.previewAndPrint(
          project: project,
          characters: provider.characters,
          scenes: scenes,
          locations: provider.locations,
          options: _options,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tạo báo cáo PDF thành công!', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xuất PDF thất bại: $e', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final project = provider.activeProject;
    final scenes = provider.scenes.where((s) => s.projectId == project.id).toList();
    final doneScenes = scenes.where((s) => s.status == SceneStatus.done).length;
    final totalHours = scenes.fold<double>(0, (sum, s) => sum + s.estimatedHours);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'PRODUCTION REPORT',
            style: GoogleFonts.inter(
              color: AppColors.goldLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            project.title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${project.codeName} • ${project.director}',
            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Summary stats
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.movie_creation_outlined,
                  iconColor: AppColors.gold,
                  label: 'Total Scenes',
                  value: '${scenes.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.teal,
                  label: 'Completed',
                  value: '$doneScenes',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people_outline,
                  iconColor: AppColors.teal,
                  label: 'Characters',
                  value: '${provider.characters.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.access_time_outlined,
                  iconColor: AppColors.goldLight,
                  label: 'Est. Hours',
                  value: totalHours.toStringAsFixed(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress overview
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OVERALL PROGRESS',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${project.progress}%',
                      style: GoogleFonts.inter(
                        color: AppColors.goldLight,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$doneScenes / ${scenes.length} scenes done',
                      style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: scenes.isEmpty ? 0 : project.progress / 100,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Export configuration (định dạng kịch bản xuất ra)
          Text(
            'EXPORT CONFIGURATION',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                _ConfigSwitch(
                  label: 'Kèm hồ sơ nhân vật',
                  subtitle: 'Tên, vai trò, mô tả tâm lý',
                  value: _options.includeCharacterProfiles,
                  onChanged: (v) =>
                      setState(() => _options = _options.copyWith(includeCharacterProfiles: v)),
                ),
                const Divider(color: AppColors.borderSubtle, height: 20),
                _ConfigSwitch(
                  label: 'Kèm toàn bộ lời thoại/hành động',
                  subtitle: 'Nếu tắt, chỉ xuất phần tóm tắt cảnh',
                  value: _options.includeFullScript,
                  onChanged: (v) => setState(() => _options = _options.copyWith(includeFullScript: v)),
                ),
                const Divider(color: AppColors.borderSubtle, height: 20),
                _ConfigSwitch(
                  label: 'Khổ giấy US Letter',
                  subtitle: 'Nếu tắt, xuất theo khổ A4 (mặc định)',
                  value: _options.useLetterSize,
                  onChanged: (v) => setState(() => _options = _options.copyWith(useLetterSize: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Scene breakdown
          Text(
            'SCENE BREAKDOWN',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          if (scenes.isEmpty)
            GlassCard(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Chưa có phân cảnh nào trong dự án này để xuất báo cáo.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
                ),
              ),
            ),
          ...scenes.map((scene) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Status dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scene.status == SceneStatus.done
                          ? AppColors.teal
                          : scene.status == SceneStatus.inProgress
                          ? AppColors.goldLight
                          : const Color(0xFF353535),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${scene.code} — ${scene.title}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          scene.act,
                          style: GoogleFonts.inter(
                              color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${scene.estimatedHours}h',
                        style: GoogleFonts.jetBrainsMono(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        scene.status.label,
                        style: GoogleFonts.inter(
                          color: scene.status == SceneStatus.done
                              ? AppColors.teal
                              : scene.status == SceneStatus.inProgress
                              ? AppColors.goldLight
                              : AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 20),

          // Export buttons
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: (scenes.isEmpty || _isExporting)
                  ? null
                  : () => _runExport(provider, share: false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: scenes.isEmpty ? AppColors.surfaceAlt : AppColors.goldLight,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: scenes.isEmpty
                      ? []
                      : [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isExporting)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF402D00)),
                      )
                    else
                      const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFF402D00), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _isExporting ? 'ĐANG TẠO PDF...' : 'PREVIEW & EXPORT PDF',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF402D00),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: (scenes.isEmpty || _isExporting) ? null : () => _runExport(provider, share: true),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.share_outlined, color: Colors.white, size: 16),
              label: Text(
                'SHARE / SAVE PDF FILE',
                style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfigSwitch extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConfigSwitch({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.goldLight,
        ),
      ],
    );
  }
}
