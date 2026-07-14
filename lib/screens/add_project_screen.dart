// lib/screens/add_project_screen.dart
// SceneFlow - Add / Edit Project Screen (F1.1, F1.2)
//
// Form thêm hoặc chỉnh sửa một dự án phim: thông tin cơ bản, phân loại
// (Type/Genre/Status/Progress) và cấu trúc các Hồi (Act) của kịch bản.
// Dùng Form + TextFormField validate theo đúng nguyên tắc UX ở mục 5.2.

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
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _directorCtrl;
  late final TextEditingController _thumbnailCtrl;
  late final TextEditingController _codeNameCtrl;
  late DateTime _startDate;

  ProjectType _type = ProjectType.feature;
  ProjectGenre _genre = ProjectGenre.drama;
  ProjectStatus _status = ProjectStatus.preProduction;
  int _progress = 0;
  late List<String> _acts;

  Project? _existing;
  bool get _isEditing => _existing != null;

  @override
  void initState() {
    super.initState();
    // Đọc 1 lần khi khởi tạo form: nếu provider.editingProject != null
    // nghĩa là người dùng bấm "Edit" từ ProjectsListScreen.
    final existing = context.read<AppProvider>().editingProject;
    _existing = existing;

    _titleCtrl = TextEditingController(text: existing?.title ?? '');
    _descCtrl = TextEditingController(text: existing?.description ?? '');
    _directorCtrl = TextEditingController(text: existing?.director ?? '');
    _thumbnailCtrl = TextEditingController(text: existing?.thumbnailUrl ?? '');
    _codeNameCtrl = TextEditingController(text: existing?.codeName ?? '');
    _startDate = existing != null
        ? (DateTime.tryParse(existing.startDate) ?? DateTime.now())
        : DateTime.now();
    _type = existing?.type ?? ProjectType.feature;
    _genre = existing?.genre ?? ProjectGenre.drama;
    _status = existing?.status ?? ProjectStatus.preProduction;
    _progress = existing?.progress ?? 0;
    _acts = List<String>.from(existing?.acts ??
        const ['Act 1: The Setup', 'Act 2: The Confrontation', 'Act 3: The Resolution']);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _directorCtrl.dispose();
    _thumbnailCtrl.dispose();
    _codeNameCtrl.dispose();
    super.dispose();
  }

  String get _formattedDate =>
      '${_startDate.year.toString().padLeft(4, '0')}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.goldLight,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _addActField() {
    setState(() => _acts.add('Act ${_acts.length + 1}: '));
  }

  void _removeAct(int index) {
    setState(() => _acts.removeAt(index));
  }

  void _submit(AppProvider provider) {
    if (!_formKey.currentState!.validate()) return;

    final cleanActs = _acts.map((a) => a.trim()).where((a) => a.isNotEmpty).toList();
    if (cleanActs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dự án cần có ít nhất một Hồi (Act)',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final thumbnail = _thumbnailCtrl.text.trim().isEmpty
        ? 'https://placehold.co/400x600/1a1a1a/d4af37?text=${Uri.encodeComponent(_titleCtrl.text.trim())}'
        : _thumbnailCtrl.text.trim();

    if (_isEditing) {
      final updated = _existing!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        startDate: _formattedDate,
        director: _directorCtrl.text.trim(),
        type: _type,
        genre: _genre,
        status: _status,
        progress: _progress,
        thumbnailUrl: thumbnail,
        codeName: _codeNameCtrl.text.trim(),
        acts: cleanActs,
      );
      provider.updateProject(_existing!.id, updated);
    } else {
      final newProject = Project(
        id: 'proj-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        startDate: _formattedDate,
        director: _directorCtrl.text.trim(),
        type: _type,
        genre: _genre,
        status: _status,
        progress: _progress,
        thumbnailUrl: thumbnail,
        codeName: _codeNameCtrl.text.trim(),
        acts: cleanActs,
      );
      provider.saveProject(newProject);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Đã cập nhật dự án' : 'Đã tạo dự án mới',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'EDIT SLATE' : 'NEW SLATE',
              style: GoogleFonts.inter(
                color: AppColors.goldLight,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isEditing ? 'Edit Project' : 'Create New Project',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            _SectionLabel('BASIC INFO'),
            const SizedBox(height: 10),
            GlassCard(
              child: Column(
                children: [
                  _FormField(
                    label: 'Project Title',
                    controller: _titleCtrl,
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Tên dự án không được để trống' : null,
                  ),
                  const SizedBox(height: 12),
                  _FormField(label: 'Director', controller: _directorCtrl),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'Description',
                    controller: _descCtrl,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    label: 'Code Name',
                    controller: _codeNameCtrl,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Mã dự án không được để trống';
                      final duplicate = provider.projects.any((p) =>
                      p.codeName.trim().toLowerCase() == v.trim().toLowerCase() &&
                          p.id != _existing?.id);
                      if (duplicate) return 'Mã dự án này đã tồn tại';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _FormField(label: 'Thumbnail URL (optional)', controller: _thumbnailCtrl),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Start Date: $_formattedDate',
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                          const Icon(Icons.calendar_today_outlined,
                              color: AppColors.textMuted, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _SectionLabel('CLASSIFICATION'),
            const SizedBox(height: 10),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type',
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  SegmentedButton<ProjectType>(
                    segments: ProjectType.values
                        .map((t) => ButtonSegment(value: t, label: Text(t.label)))
                        .toList(),
                    selected: {_type},
                    onSelectionChanged: (s) => setState(() => _type = s.first),
                  ),
                  const SizedBox(height: 16),
                  Text('Genre',
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ProjectGenre>(
                    initialValue: _genre,
                    dropdownColor: AppColors.surface,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                    items: ProjectGenre.values
                        .map((g) => DropdownMenuItem(value: g, child: Text(g.label)))
                        .toList(),
                    onChanged: (g) => setState(() => _genre = g ?? _genre),
                  ),
                  const SizedBox(height: 16),
                  Text('Status',
                      style: GoogleFonts.inter(
                          color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  SegmentedButton<ProjectStatus>(
                    segments: ProjectStatus.values
                        .map((s) => ButtonSegment(value: s, label: Text(s.label)))
                        .toList(),
                    selected: {_status},
                    onSelectionChanged: (s) => setState(() => _status = s.first),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress',
                          style: GoogleFonts.inter(
                              color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                      Text('$_progress%',
                          style: GoogleFonts.jetBrainsMono(
                              color: AppColors.goldLight, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Slider(
                    value: _progress.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.goldLight,
                    inactiveColor: AppColors.border,
                    onChanged: (v) => setState(() => _progress = v.round()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionLabel('ACTS (STRUCTURE)'),
                GestureDetector(
                  onTap: _addActField,
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle_outline, color: AppColors.teal, size: 16),
                      const SizedBox(width: 4),
                      Text('Add Act',
                          style: GoogleFonts.inter(
                              color: AppColors.teal, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GlassCard(
              child: Column(
                children: List.generate(_acts.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.goldLight.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('${i + 1}',
                              style: GoogleFonts.jetBrainsMono(
                                  color: AppColors.goldLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: _acts[i],
                            onChanged: (v) => _acts[i] = v,
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Act ${i + 1}: ...',
                              hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _acts.length > 1 ? () => _removeAct(i) : null,
                          icon: const Icon(Icons.close, size: 16),
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldLight,
                  foregroundColor: const Color(0xFF402D00),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _submit(provider),
                child: Text(
                  _isEditing ? 'SAVE CHANGES' : 'CREATE PROJECT',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, letterSpacing: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: AppColors.textMuted,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
        errorStyle: GoogleFonts.inter(color: Colors.redAccent, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}