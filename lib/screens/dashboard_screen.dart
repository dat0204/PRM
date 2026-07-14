// lib/screens/dashboard_screen.dart
// SceneFlow - Dashboard & Analytics Screen (F1.3, F5.1)
//
// F1.3: Tổng quan Dashboard — tổng số nhân vật, tổng số cảnh quay, tiến độ
// hoàn thành dự án (%).
// F5.1: Biểu đồ trực quan (fl_chart) — tần suất xuất hiện nhân vật qua các
// cảnh; tỷ lệ cảnh Interior vs Exterior.
//
// pubspec.yaml cần có: fl_chart: ^0.68.0 (hoặc bản mới hơn tương thích).

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/scene.dart';
import '../providers/app_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _focusedProjectId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (provider.projects.isEmpty) {
      return _EmptyDashboard();
    }

    final focusedId = _focusedProjectId ?? provider.activeProject.id;
    final project = provider.projects.firstWhere((p) => p.id == focusedId,
        orElse: () => provider.activeProject);
    final projectScenes = provider.scenes.where((s) => s.projectId == project.id).toList();

    final doneScenes = projectScenes.where((s) => s.status == SceneStatus.done).length;
    final intCount = projectScenes.where((s) => s.setting == SceneSetting.interior).length;
    final extCount = projectScenes.length - intCount;

    // Character appearance frequency across this project's scenes.
    final Map<String, int> appearances = {};
    for (final scene in projectScenes) {
      for (final charId in scene.characterIds) {
        appearances[charId] = (appearances[charId] ?? 0) + 1;
      }
    }
    final topAppearances = appearances.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topFive = topAppearances.take(5).toList();

    String charName(String id) {
      final match = provider.characters.where((c) => c.id == id);
      return match.isNotEmpty ? match.first.name : id;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DASHBOARD',
            style: GoogleFonts.inter(
              color: AppColors.goldLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Production Overview',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          // Project selector chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.projects.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final p = provider.projects[i];
                final isSelected = p.id == project.id;
                return GestureDetector(
                  onTap: () => setState(() => _focusedProjectId = p.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.goldLight.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.goldLight : AppColors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      p.title,
                      style: GoogleFonts.inter(
                        color: isSelected ? AppColors.goldLight : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // ── F1.3: Summary stat cards ──────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people_outline,
                  iconColor: AppColors.teal,
                  label: 'Total Characters',
                  value: '${provider.characters.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.movie_creation_outlined,
                  iconColor: AppColors.gold,
                  label: 'Total Scenes',
                  value: '${projectScenes.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: AppColors.goldLight,
                  label: 'Scenes Done',
                  value: '$doneScenes / ${projectScenes.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.place_outlined,
                  iconColor: AppColors.teal,
                  label: 'Locations',
                  value: '${provider.locations.length}',
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
                  'OVERALL PROGRESS — ${project.codeName}',
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
                      project.status.label,
                      style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: project.progress / 100,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── F5.1: Character appearance frequency (bar chart) ──────
          Text(
            'CHARACTER APPEARANCE FREQUENCY',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: topFive.isEmpty
                ? _ChartEmptyState('Chưa có phân cảnh nào gán nhân vật.')
                : SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (topFive.first.value + 1).toDouble(),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 26,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: GoogleFonts.jetBrainsMono(
                              color: AppColors.textMuted, fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= topFive.length) return const SizedBox.shrink();
                          final name = charName(topFive[i].key);
                          final initials = name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').join();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              initials.isEmpty ? '?' : initials.toUpperCase(),
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(topFive.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: topFive[i].value.toDouble(),
                          color: AppColors.goldLight,
                          width: 22,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (topFive.isNotEmpty)
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: topFive
                  .map((e) => Text(
                '${charName(e.key)} · ${e.value}',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
              ))
                  .toList(),
            ),
          const SizedBox(height: 24),

          // ── F5.1: Interior vs Exterior ratio (pie chart) ──────────
          Text(
            'INTERIOR vs EXTERIOR RATIO',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: projectScenes.isEmpty
                ? _ChartEmptyState('Chưa có phân cảnh nào trong dự án này.')
                : Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 34,
                      sections: [
                        PieChartSectionData(
                          value: intCount.toDouble(),
                          color: AppColors.teal,
                          title: intCount > 0 ? '$intCount' : '',
                          radius: 30,
                          titleStyle: GoogleFonts.inter(
                              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        PieChartSectionData(
                          value: extCount.toDouble(),
                          color: AppColors.goldLight,
                          title: extCount > 0 ? '$extCount' : '',
                          radius: 30,
                          titleStyle: GoogleFonts.inter(
                              color: const Color(0xFF402D00),
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendRow(
                        color: AppColors.teal,
                        label: 'Interior (INT)',
                        value: intCount,
                        total: projectScenes.length,
                      ),
                      const SizedBox(height: 10),
                      _LegendRow(
                        color: AppColors.goldLight,
                        label: 'Exterior (EXT)',
                        value: extCount,
                        total: projectScenes.length,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard_outlined, color: AppColors.textMuted, size: 36),
            const SizedBox(height: 12),
            Text(
              'Chưa có dự án nào để hiển thị thống kê.\nHãy tạo dự án đầu tiên ở tab Projects.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  final String message;
  const _ChartEmptyState(this.message);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final int total;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : ((value / total) * 100).round();
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          '$value ($pct%)',
          style: GoogleFonts.jetBrainsMono(
              color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
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
          Expanded(
            child: Column(
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
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}