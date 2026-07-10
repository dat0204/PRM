// lib/screens/advanced_filter_screen.dart
// SceneFlow - Advanced Filter Screen

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_provider.dart';

class AdvancedFilterScreen extends StatefulWidget {
  const AdvancedFilterScreen({super.key});

  @override
  State<AdvancedFilterScreen> createState() => _AdvancedFilterScreenState();
}

class _AdvancedFilterScreenState extends State<AdvancedFilterScreen> {
  late String _timeOfDay;
  late String _setting;
  late String _status;
  late String? _characterId;

  @override
  void initState() {
    super.initState();
    final filters = context.read<AppProvider>().activeFilters;
    _timeOfDay = filters.timeOfDay;
    _setting = filters.setting;
    _status = filters.status;
    _characterId = filters.characterId;
  }

  void _applyFilters() {
    context.read<AppProvider>().applyFilters(SceneFilterState(
      characterId: _characterId,
      timeOfDay: _timeOfDay,
      setting: _setting,
      status: _status,
    ));
  }

  void _resetFilters() {
    setState(() {
      _timeOfDay = 'ALL';
      _setting = 'ALL';
      _status = 'ALL';
      _characterId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final characters = context.watch<AppProvider>().characters;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SCENE FILTERS',
                    style: GoogleFonts.inter(
                      color: AppColors.goldLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Advanced Filter',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _resetFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    'Reset',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Time of Day filter
          _FilterSection(
            label: 'TIME OF DAY',
            options: const ['ALL', 'DAY', 'NIGHT'],
            selected: _timeOfDay,
            onSelect: (v) => setState(() => _timeOfDay = v),
          ),
          const SizedBox(height: 20),

          // Setting filter
          _FilterSection(
            label: 'SETTING',
            options: const ['ALL', 'INT', 'EXT'],
            selected: _setting,
            onSelect: (v) => setState(() => _setting = v),
          ),
          const SizedBox(height: 20),

          // Status filter
          _FilterSection(
            label: 'SCENE STATUS',
            options: const ['ALL', 'Done', 'In Progress', 'Drafting'],
            selected: _status,
            onSelect: (v) => setState(() => _status = v),
          ),
          const SizedBox(height: 20),

          // Character filter
          Text(
            'FILTER BY CHARACTER',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          GlassCard(
            child: Column(
              children: [
                // All option
                GestureDetector(
                  onTap: () => setState(() => _characterId = null),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _characterId == null ? AppColors.teal : AppColors.border,
                              width: 2,
                            ),
                            color: _characterId == null
                                ? AppColors.teal
                                : Colors.transparent,
                          ),
                          child: _characterId == null
                              ? const Icon(Icons.check, size: 12, color: Colors.black)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'All Characters',
                          style: GoogleFonts.inter(
                            color: _characterId == null ? Colors.white : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: _characterId == null ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: AppColors.borderSubtle),
                ...characters.map((char) => GestureDetector(
                      onTap: () => setState(() => _characterId = char.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _characterId == char.id
                                      ? AppColors.teal
                                      : AppColors.border,
                                  width: 2,
                                ),
                                color: _characterId == char.id
                                    ? AppColors.teal
                                    : Colors.transparent,
                              ),
                              child: _characterId == char.id
                                  ? const Icon(Icons.check, size: 12, color: Colors.black)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            // Avatar
                            ClipOval(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: Image.network(
                                  char.avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const CircleAvatar(
                                    backgroundColor: AppColors.surfaceAlt,
                                    child: Icon(Icons.person, size: 14, color: AppColors.textMuted),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  char.name,
                                  style: GoogleFonts.inter(
                                    color: _characterId == char.id
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: _characterId == char.id
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  char.roleTitle,
                                  style: GoogleFonts.inter(
                                      color: AppColors.textMuted, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _applyFilters,
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
                    'APPLY FILTERS',
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
}

class _FilterSection extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _FilterSection({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          children: options.map((opt) {
            final isActive = selected == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.goldLight.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? AppColors.goldLight.withValues(alpha: 0.5) : AppColors.borderSubtle,
                  ),
                ),
                child: Text(
                  opt,
                  style: GoogleFonts.inter(
                    color: isActive ? AppColors.goldLight : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
