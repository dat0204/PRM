// lib/screens/add_project_screen.dart
// SceneFlow - Add New Project Screen

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/project.dart';
import '../providers/app_provider.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _directorController = TextEditingController();
  final _startDateController = TextEditingController();
  final _thumbnailController = TextEditingController();

  ProjectType _type = ProjectType.feature;
  ProjectGenre _genre = ProjectGenre.drama;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _directorController.dispose();
    _startDateController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_titleController.text.isEmpty || _directorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Title and Director are required.',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final codeNum = DateTime.now().millisecondsSinceEpoch % 1000;
    final newProject = Project(
      id: 'proj-${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      description: _descriptionController.text,
      startDate: _startDateController.text.isEmpty
          ? DateTime.now().toIso8601String().substring(0, 10)
          : _startDateController.text,
      director: _directorController.text,
      type: _type,
      genre: _genre,
      status: ProjectStatus.preProduction,
      progress: 0,
      thumbnailUrl: _thumbnailController.text,
      codeName: 'SCN-$codeNum',
      acts: ['Act 1: The Setup', 'Act 2: The Confrontation', 'Act 3: The Resolution'],
    );

    context.read<AppProvider>().saveProject(newProject);
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
            'CREATE NEW SLATE',
            style: GoogleFonts.inter(
              color: AppColors.goldLight,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'New Production',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),

          _FormField(label: 'TITLE', controller: _titleController, hint: 'e.g. The Long Goodbye'),
          const SizedBox(height: 14),
          _FormField(
            label: 'DESCRIPTION',
            controller: _descriptionController,
            hint: 'Brief logline...',
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          _FormField(label: 'DIRECTOR', controller: _directorController, hint: 'e.g. R. Chandler'),
          const SizedBox(height: 14),
          _FormField(
            label: 'START DATE',
            controller: _startDateController,
            hint: 'YYYY-MM-DD',
          ),
          const SizedBox(height: 14),
          _FormField(
            label: 'THUMBNAIL URL',
            controller: _thumbnailController,
            hint: 'https://...',
          ),
          const SizedBox(height: 20),

          // Type selector
          Text(
            'TYPE',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ProjectType.values.map((t) {
              final isActive = _type == t;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _type = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.goldLight : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive ? AppColors.goldLight : AppColors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      t.label,
                      style: GoogleFonts.inter(
                        color: isActive ? const Color(0xFF402D00) : AppColors.textSecondary,
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

          // Genre selector
          Text(
            'GENRE',
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
            children: ProjectGenre.values.map((g) {
              final isActive = _genre == g;
              return GestureDetector(
                onTap: () => setState(() => _genre = g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.teal.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive ? AppColors.teal.withValues(alpha: 0.5) : AppColors.borderSubtle,
                    ),
                  ),
                  child: Text(
                    g.label,
                    style: GoogleFonts.inter(
                      color: isActive ? AppColors.teal : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Submit button
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
                    'CREATE PROJECT',
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

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
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
