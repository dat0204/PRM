// lib/screens/add_character_screen.dart
// SceneFlow - Add New Character Screen

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/character.dart';
import '../providers/app_provider.dart';

class AddCharacterScreen extends StatefulWidget {
  const AddCharacterScreen({super.key});

  @override
  State<AddCharacterScreen> createState() => _AddCharacterScreenState();
}

class _AddCharacterScreenState extends State<AddCharacterScreen> {
  final _nameController = TextEditingController();
  final _roleTitleController = TextEditingController();
  final _avatarController = TextEditingController();
  final _profileController = TextEditingController();
  CharacterRole _role = CharacterRole.supporting;

  @override
  void dispose() {
    _nameController.dispose();
    _roleTitleController.dispose();
    _avatarController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Character name is required.',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newChar = Character(
      id: 'char-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      role: _role,
      roleTitle: _roleTitleController.text.isEmpty
          ? _role.label
          : _roleTitleController.text.toUpperCase(),
      avatarUrl: _avatarController.text,
      psychologicalProfile: _profileController.text,
    );

    context.read<AppProvider>().saveCharacter(newChar);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'ENROLL CAST MEMBER',
            style: GoogleFonts.inter(
              color: AppColors.goldLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'New Character',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),

          // Avatar preview
          if (_avatarController.text.isNotEmpty)
            Center(
              child: Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  _avatarController.text,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.card,
                    child: const Icon(Icons.person, color: AppColors.textMuted, size: 40),
                  ),
                ),
              ),
            ),

          _FormField(label: 'NAME', controller: _nameController, hint: 'e.g. Julian Marlowe'),
          const SizedBox(height: 14),
          _FormField(label: 'ROLE TITLE', controller: _roleTitleController, hint: 'e.g. LEAD DETECTIVE'),
          const SizedBox(height: 14),
          _FormField(label: 'AVATAR URL', controller: _avatarController, hint: 'https://...', onChanged: (_) => setState(() {})),
          const SizedBox(height: 14),
          _FormField(
            label: 'PSYCHOLOGICAL PROFILE',
            controller: _profileController,
            hint: 'Character background, traits, motivations...',
            maxLines: 4,
          ),
          const SizedBox(height: 20),

          // Role selector
          Text(
            'ROLE',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: CharacterRole.values.map((r) {
              final isActive = _role == r;
              Color activeColor;
              switch (r) {
                case CharacterRole.main:
                  activeColor = AppColors.goldLight;
                  break;
                case CharacterRole.supporting:
                  activeColor = AppColors.teal;
                  break;
                case CharacterRole.extra:
                  activeColor = AppColors.textSecondary;
                  break;
              }
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _role = r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? activeColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive ? activeColor.withValues(alpha: 0.5) : AppColors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      r.label,
                      style: GoogleFonts.inter(
                        color: isActive ? activeColor : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Submit
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
                    'ENROLL CHARACTER',
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

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
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
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
