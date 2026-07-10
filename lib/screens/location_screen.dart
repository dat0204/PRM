// lib/screens/location_screen.dart
// SceneFlow - Location Directory Screen

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
                      onTap: () => setState(() => _activeCardId = loc.id),
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
                          'No locations found.',
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
            onTap: () => _showAddLocationDialog(context, provider),
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

  void _showAddLocationDialog(BuildContext context, AppProvider provider) {
    final nameCtrl = TextEditingController();
    final areaCtrl = TextEditingController();
    final scenesCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    var setting = LocationSetting.interior;
    var timeOfDay = LocationTimeOfDay.day;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Location',
                style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _QuickField(label: 'Name', controller: nameCtrl),
              const SizedBox(height: 10),
              _QuickField(label: 'Area', controller: areaCtrl),
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
                    if (nameCtrl.text.isEmpty) return;
                    provider.addLocation(LocationItem(
                      id: 'loc-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text,
                      area: areaCtrl.text,
                      scenesCovered: scenesCtrl.text,
                      setting: setting,
                      timeOfDay: timeOfDay,
                      notes: notesCtrl.text,
                    ));
                    Navigator.pop(ctx);
                  },
                  child: Text('ADD LOCATION',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                ),
              ),
            ],
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

  const _LocationCard({required this.loc, required this.isActive, required this.onTap});

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
                Row(
                  children: [
                    _MiniTag(loc.setting.label),
                    const SizedBox(width: 6),
                    _MiniTag(loc.timeOfDay.label),
                  ],
                ),
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

  const _QuickField({required this.label, required this.controller, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
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
      ),
    );
  }
}
