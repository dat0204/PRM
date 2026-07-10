// lib/screens/scene_detail_screen.dart
// SceneFlow - Scene Detail / Script Editor Screen

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/scene.dart';
import '../models/location_item.dart';
import '../models/character.dart';
import '../providers/app_provider.dart';

class SceneDetailScreen extends StatefulWidget {
  const SceneDetailScreen({super.key});

  @override
  State<SceneDetailScreen> createState() => _SceneDetailScreenState();
}

class _SceneDetailScreenState extends State<SceneDetailScreen> {
  late TextEditingController _scriptController;
  late SceneStatus _status;
  late String _locationId;
  late List<String> _characterIds;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final scene = context.read<AppProvider>().activeScene;
      if (scene != null) {
        _scriptController = TextEditingController(text: scene.actionDialogueText);
        _status = scene.status;
        _locationId = scene.locationId;
        _characterIds = List.from(scene.characterIds);
        _initialized = true;
      }
    }
  }

  @override
  void dispose() {
    _scriptController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final provider = context.read<AppProvider>();
    final scene = provider.activeScene;
    if (scene == null) return;
    final updated = scene.copyWith(
      actionDialogueText: _scriptController.text,
      status: _status,
      locationId: _locationId,
      characterIds: _characterIds,
    );
    provider.saveSceneDetails(scene.id, updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Scene changes saved successfully!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleCharacter(String charId) {
    setState(() {
      if (_characterIds.contains(charId)) {
        _characterIds.remove(charId);
      } else {
        _characterIds.add(charId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final scene = provider.activeScene;
    if (scene == null || !_initialized) {
      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
    }

    final wordCount = _scriptController.text.trim().split(RegExp(r'\s+')).length;
    final activeLocation = provider.locations.firstWhere(
      (l) => l.id == _locationId,
      orElse: () => provider.locations.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scene identity header
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text(
                        scene.code,
                        style: GoogleFonts.jetBrainsMono(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        scene.title,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  scene.act,
                  style: GoogleFonts.inter(color: AppColors.teal, fontSize: 12),
                ),
                const SizedBox(height: 12),
                // Meta tags
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _metaTag(scene.setting.label),
                    _metaTag(scene.timeOfDay.label),
                    _metaTag(scene.pages.split('(').first.trim()),
                    _metaTag('${scene.estimatedHours}h Est.'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Status picker
          Text(
            'STATUS',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: SceneStatus.values.map((s) {
              final isActive = _status == s;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _status = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive
                          ? _statusColor(s).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive ? _statusColor(s).withValues(alpha: 0.4) : AppColors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      s.label,
                      style: GoogleFonts.inter(
                        color: isActive ? _statusColor(s) : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Location picker
          Text(
            'LOCATION',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _locationId,
                isExpanded: true,
                dropdownColor: AppColors.surface,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                onChanged: (val) => setState(() => _locationId = val!),
                items: provider.locations.map((loc) {
                  return DropdownMenuItem(
                    value: loc.id,
                    child: Text(
                      loc.name,
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Character picker
          Text(
            'CAST',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.characters.map((char) {
              final isSelected = _characterIds.contains(char.id);
              return GestureDetector(
                onTap: () => _toggleCharacter(char.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.teal.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.teal.withValues(alpha: 0.4) : AppColors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check, size: 12, color: AppColors.teal),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        char.name,
                        style: GoogleFonts.inter(
                          color: isSelected ? AppColors.teal : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Script editor
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTION / DIALOGUE',
                style: GoogleFonts.inter(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '$wordCount words',
                style: GoogleFonts.jetBrainsMono(
                    color: AppColors.textMuted, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GlassCard(
            padding: const EdgeInsets.all(14),
            child: TextField(
              controller: _scriptController,
              maxLines: null,
              minLines: 10,
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.7,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Write action & dialogue here...',
                hintStyle: GoogleFonts.jetBrainsMono(color: AppColors.textMuted),
                isCollapsed: true,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Save button
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _handleSave,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'SAVE CHANGES',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF402D00),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(SceneStatus s) {
    switch (s) {
      case SceneStatus.done:
        return AppColors.teal;
      case SceneStatus.inProgress:
        return AppColors.goldLight;
      case SceneStatus.drafting:
        return AppColors.textSecondary;
    }
  }

  Widget _metaTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
