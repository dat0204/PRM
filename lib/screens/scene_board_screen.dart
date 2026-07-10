// lib/screens/scene_board_screen.dart
// SceneFlow - Scene Board / Timeline Screen

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/scene.dart';
import '../providers/app_provider.dart';

class SceneBoardScreen extends StatelessWidget {
  const SceneBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final project = provider.activeProject;
    final filteredScenes = provider.filteredScenesForProject(project.id);
    final acts = project.acts;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Episode ${project.codeName.replaceAll('SCN-', '')} • Scene Board Timeline',
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Filter button
                      GestureDetector(
                        onTap: () => provider.startFiltering(),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          radius: 10,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tune,
                                size: 14,
                                color: provider.activeFilters.hasActiveFilters
                                    ? AppColors.teal
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'FILTER',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 1,
                                ),
                              ),
                              if (provider.activeFilters.hasActiveFilters) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.teal,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Add scene button
                      GestureDetector(
                        onTap: () => _addScene(context, provider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.2),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, size: 14, color: Color(0xFF402D00)),
                              const SizedBox(width: 4),
                              Text(
                                'SCENE',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF402D00),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Acts timeline
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vertical line
                    Container(
                      width: 1,
                      color: AppColors.border,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: acts.map((actName) {
                          final actScenes = filteredScenes
                              .where((s) => s.act.toLowerCase() == actName.toLowerCase())
                              .toList();

                          return _ActSection(
                            actName: actName,
                            scenes: actScenes,
                            characters: provider.characters,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              if (filteredScenes.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'No matching scenes found.',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try resetting your active timeline filters.',
                          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _addScene(BuildContext context, AppProvider provider) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('New Scene', style: GoogleFonts.inter(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter Scene Title...',
            hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text('Add', style: GoogleFonts.inter(color: AppColors.gold)),
          ),
        ],
      ),
    );

    if (title != null && title.isNotEmpty) {
      final codeNo = provider.scenes.where((s) => s.projectId == provider.selectedProjectId).length + 1;
      final newScene = Scene(
        id: 'sc-new-${DateTime.now().millisecondsSinceEpoch}',
        projectId: provider.selectedProjectId,
        code: 'SC ${codeNo < 10 ? '0$codeNo' : '$codeNo'}',
        title: title,
        act: provider.activeProject.acts.first,
        status: SceneStatus.drafting,
        description: 'Brief logline of the scene action.',
        setting: SceneSetting.interior,
        timeOfDay: SceneTimeOfDay.night,
        locationId: provider.locations.isNotEmpty ? provider.locations.first.id : 'loc-office',
        characterIds: const ['marlowe'],
        pages: 'Pages 1-2 (1 2/8)',
        estimatedHours: 2.0,
        actionDialogueText: 'Action description goes here...',
      );
      provider.addScene(newScene);
    }
  }
}

class _ActSection extends StatelessWidget {
  final String actName;
  final List<Scene> scenes;
  final List characters;

  const _ActSection({
    required this.actName,
    required this.scenes,
    required this.characters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Act header
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            actName,
            style: GoogleFonts.inter(
              color: AppColors.teal,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),

        // Scenes
        ...scenes.map((scene) {
          final sceneChars = characters.where((c) => scene.characterIds.contains(c.id)).toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Timeline dot (positioned on the left line)
                Positioned(
                  left: -28,
                  top: 18,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _dotColor(scene.status),
                      border: Border.all(color: AppColors.bg, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _dotColor(scene.status).withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),

                // Scene card
                GlassCard(
                  onTap: () => context.read<AppProvider>().selectScene(scene.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: Text(
                                  scene.code,
                                  style: GoogleFonts.jetBrainsMono(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                scene.title,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          _StatusBadge(status: scene.status),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        scene.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _MetaTag(scene.setting.label),
                              const SizedBox(width: 6),
                              _MetaTag(scene.timeOfDay.label),
                              const SizedBox(width: 6),
                              _MetaTag(scene.pages.split('(').first.trim()),
                            ],
                          ),
                          // Character avatars
                          Row(
                            children: [
                              ...sceneChars.take(4).map((char) => Transform.translate(
                                    offset: Offset(-6.0 * sceneChars.indexOf(char), 0),
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF131313),
                                          width: 2,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(
                                        char.avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const CircleAvatar(
                                          backgroundColor: AppColors.surfaceAlt,
                                          child: Icon(Icons.person, size: 12, color: AppColors.textMuted),
                                        ),
                                      ),
                                    ),
                                  )),
                              if (sceneChars.isEmpty)
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.border,
                                      style: BorderStyle.solid,
                                    ),
                                    color: Colors.black.withValues(alpha: 0.2),
                                  ),
                                  child: const Icon(
                                    Icons.question_mark,
                                    size: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        if (scenes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 4),
            child: Text(
              'No scenes drafted for this act.',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        const SizedBox(height: 16),
      ],
    );
  }

  Color _dotColor(SceneStatus status) {
    switch (status) {
      case SceneStatus.done:
        return AppColors.teal;
      case SceneStatus.inProgress:
        return AppColors.goldLight;
      case SceneStatus.drafting:
        return const Color(0xFF353535);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final SceneStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    Color border;

    switch (status) {
      case SceneStatus.done:
        color = AppColors.teal;
        bg = AppColors.teal.withValues(alpha: 0.10);
        border = AppColors.teal.withValues(alpha: 0.20);
        break;
      case SceneStatus.inProgress:
        color = AppColors.goldLight;
        bg = AppColors.goldLight.withValues(alpha: 0.10);
        border = AppColors.goldLight.withValues(alpha: 0.20);
        break;
      case SceneStatus.drafting:
        color = AppColors.textSecondary;
        bg = Colors.white.withValues(alpha: 0.05);
        border = AppColors.border;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == SceneStatus.inProgress) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            status.label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  final String label;

  const _MetaTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
