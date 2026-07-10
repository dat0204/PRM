// lib/screens/characters_screen.dart
// SceneFlow - Character Directory Screen

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/character.dart';
import '../providers/app_provider.dart';

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final filteredChars = provider.characters.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) || c.roleTitle.toLowerCase().contains(q);
    }).toList();

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner header
                    Text(
                      'CAST & CREW',
                      style: GoogleFonts.inter(
                        color: AppColors.goldLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Character Directory',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search cast & characters...',
                          hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Character grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: filteredChars.isEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.person_off_outlined,
                                color: AppColors.textMuted, size: 32),
                            const SizedBox(height: 12),
                            Text(
                              'No cast members match your query.',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _CharacterCard(character: filteredChars[i]),
                        childCount: filteredChars.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                    ),
            ),
          ],
        ),

        // FAB
        Positioned(
          bottom: 100,
          right: 20,
          child: GestureDetector(
            onTap: () => context.read<AppProvider>().startAddCharacter(),
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
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Color(0xFF402D00), size: 24),
            ),
          ),
        ),
      ],
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final Character character;

  const _CharacterCard({required this.character});

  TagStyle get _roleTagStyle {
    switch (character.role) {
      case CharacterRole.main:
        return TagStyle.gold;
      case CharacterRole.supporting:
        return TagStyle.teal;
      case CharacterRole.extra:
        return TagStyle.muted;
    }
  }

  // Define TagStyle inline since we need it
  Color get _roleColor {
    switch (character.role) {
      case CharacterRole.main:
        return AppColors.goldLight;
      case CharacterRole.supporting:
        return AppColors.teal;
      case CharacterRole.extra:
        return AppColors.textSecondary;
    }
  }

  Color get _roleBg {
    switch (character.role) {
      case CharacterRole.main:
        return AppColors.goldLight.withValues(alpha: 0.10);
      case CharacterRole.supporting:
        return AppColors.teal.withValues(alpha: 0.10);
      case CharacterRole.extra:
        return Colors.white.withValues(alpha: 0.05);
    }
  }

  Color get _roleBorder {
    switch (character.role) {
      case CharacterRole.main:
        return AppColors.goldLight.withValues(alpha: 0.30);
      case CharacterRole.supporting:
        return AppColors.teal.withValues(alpha: 0.30);
      case CharacterRole.extra:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show profile dialog
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(character.name, style: GoogleFonts.inter(color: Colors.white)),
            content: Text(
              character.psychologicalProfile,
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Close', style: GoogleFonts.inter(color: AppColors.gold)),
              ),
            ],
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              character.avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.card,
                child: const Icon(Icons.person, color: AppColors.textMuted, size: 48),
              ),
            ),

            // Gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // Border
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
            ),

            // Role tag (top right)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _roleBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _roleBorder),
                ),
                child: Text(
                  character.role.label,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _roleColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),

            // Bottom info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      character.roleTitle,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jetBrainsMono(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Re-export TagStyle for this file
enum TagStyle { gold, teal, muted, success, info, warning }
