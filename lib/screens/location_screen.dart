// lib/screens/location_screen.dart
// SceneFlow - Location Directory Screen (Module: Logistics & Export)
//
// F2.2: CRUD Bối cảnh đầy đủ (Add / Edit / Delete) + validate dữ liệu.
// UX bắt buộc (mục 5.2): Form + TextFormField validate, Empty State,
// AlertDialog xác nhận khi xóa, SnackBar phản hồi sau CRUD.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/location_item.dart';
import '../providers/app_provider.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _searchQuery = '';
  String? _activeCardId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final filteredLocations = provider.locations.where((l) {
      final q = _searchQuery.toLowerCase();
      return l.name.toLowerCase().contains(q) || l.area.toLowerCase().contains(q);
    }).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'LOCATIONS',
                style: GoogleFonts.inter(
                  color: AppColors.goldLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Location Directory',
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
                    hintText: 'Search locations...',
                    hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Location cards
              ...filteredLocations.map((loc) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _LocationCard(
                  loc: loc,
                  isActive: _activeCardId == loc.id,
                  onTap: () => setState(
                          () => _activeCardId = _activeCardId == loc.id ? null : loc.id),
                  onEdit: () => _showLocationFormSheet(context, provider, existing: loc),
                  onDelete: () => _confirmDelete(context, provider, loc),
                ),
              )),

              if (filteredLocations.isEmpty)
                GlassCard(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.place_outlined, color: AppColors.textMuted, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          provider.locations.isEmpty
                              ? 'Chưa có bối cảnh nào. Bấm nút + để thêm bối cảnh đầu tiên'
                              : 'No locations found.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // FAB
        Positioned(
          bottom: 100,
          right: 20,
          child: GestureDetector(
            onTap: () => _showLocationFormSheet(context, provider),
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
              child: const Icon(Icons.add, color: Color(0xFF402D00), size: 24),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, AppProvider provider, LocationItem loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Xóa bối cảnh?',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Bạn có chắc muốn xóa "${loc.name}"? Hành động này không thể hoàn tác.',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteLocation(loc.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa "${loc.name}"', style: GoogleFonts.inter(color: Colors.white)),
                  backgroundColor: AppColors.surface,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Xóa',
                style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showLocationFormSheet(BuildContext context, AppProvider provider,
      {LocationItem? existing}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final areaCtrl = TextEditingController(text: existing?.area ?? '');
    final scenesCtrl = TextEditingController(text: existing?.scenesCovered ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    var setting = existing?.setting ?? LocationSetting.interior;
    var timeOfDay = existing?.timeOfDay ?? LocationTimeOfDay.day;
    final isEditing = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Location' : 'Add Location',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                _QuickField(
                  label: 'Name',
                  controller: nameCtrl,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Tên bối cảnh không được để trống';
                    final duplicate = provider.locations.any((l) =>
                    l.name.trim().toLowerCase() == v.trim().toLowerCase() &&
                        l.id != existing?.id);
                    if (duplicate) return 'Tên bối cảnh này đã tồn tại';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _QuickField(
                  label: 'Area',
                  controller: areaCtrl,
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Khu vực không được để trống' : null,
                ),
                const SizedBox(height: 10),
                _QuickField(label: 'Scenes Covered', controller: scenesCtrl),
                const SizedBox(height: 10),
                _QuickField(label: 'Production Notes', controller: notesCtrl, maxLines: 2),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Setting',
                              style: GoogleFonts.inter(
                                  color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          SegmentedButton<LocationSetting>(
                            segments: const [
                              ButtonSegment(value: LocationSetting.interior, label: Text('INT')),
                              ButtonSegment(value: LocationSetting.exterior, label: Text('EXT')),
                            ],
                            selected: {setting},
                            onSelectionChanged: (s) => setModalState(() => setting = s.first),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Time of Day',
                              style: GoogleFonts.inter(
                                  color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          SegmentedButton<LocationTimeOfDay>(
                            segments: const [
                              ButtonSegment(value: LocationTimeOfDay.day, label: Text('DAY')),
                              ButtonSegment(value: LocationTimeOfDay.night, label: Text('NIGHT')),
                            ],
                            selected: {timeOfDay},
                            onSelectionChanged: (s) => setModalState(() => timeOfDay = s.first),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldLight,
                      foregroundColor: const Color(0xFF402D00),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;

                      if (isEditing) {
                        provider.updateLocation(
                          existing.id,
                          existing.copyWith(
                            name: nameCtrl.text.trim(),
                            area: areaCtrl.text.trim(),
                            scenesCovered: scenesCtrl.text.trim(),
                            notes: notesCtrl.text.trim(),
                            setting: setting,
                            timeOfDay: timeOfDay,
                          ),
                        );
                      } else {
                        provider.addLocation(LocationItem(
                          id: 'loc-${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          area: areaCtrl.text.trim(),
                          scenesCovered: scenesCtrl.text.trim(),
                          setting: setting,
                          timeOfDay: timeOfDay,
                          notes: notesCtrl.text.trim(),
                        ));
                      }

                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing ? 'Đã cập nhật bối cảnh' : 'Đã thêm bối cảnh mới',
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                          backgroundColor: AppColors.surface,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(isEditing ? 'SAVE CHANGES' : 'ADD LOCATION',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final LocationItem loc;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LocationCard({
    required this.loc,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isActive ? 0.07 : 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: isActive ? AppColors.teal : Colors.transparent,
              width: 3,
            ),
            top: BorderSide(color: AppColors.borderSubtle),
            right: BorderSide(color: AppColors.borderSubtle),
            bottom: BorderSide(color: AppColors.borderSubtle),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image (if available)
            if (loc.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: double.infinity,
                  height: 140,
                  child: Image.network(
                    loc.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceAlt,
                      child: const Icon(Icons.image_not_supported, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ),
            if (loc.imageUrl != null) const SizedBox(height: 12),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    loc.name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _MiniTag(loc.setting.label),
                const SizedBox(width: 6),
                _MiniTag(loc.timeOfDay.label),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              loc.area,
              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Container(
              height: 1,
              color: AppColors.borderSubtle,
            ),
            const SizedBox(height: 8),

            // Scenes covered
            Row(
              children: [
                const Icon(Icons.movie_outlined, color: AppColors.textMuted, size: 14),
                const SizedBox(width: 6),
                Text(
                  loc.scenesCovered,
                  style: GoogleFonts.jetBrainsMono(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Notes
            Text(
              loc.notes,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),

            // Actions (edit/delete) — revealed when the card is active
            if (isActive) ...[
              const SizedBox(height: 12),
              Container(height: 1, color: AppColors.borderSubtle),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.teal),
                    label: Text('Edit',
                        style: GoogleFonts.inter(
                            color: AppColors.teal, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 4),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                    label: Text('Delete',
                        style: GoogleFonts.inter(
                            color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;

  const _MiniTag(this.label);

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
        label,
        style: GoogleFonts.inter(
          color: AppColors.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _QuickField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final String? Function(String?)? validator;

  const _QuickField({
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
