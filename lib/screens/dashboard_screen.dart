// lib/screens/dashboard_screen.dart
// SceneFlow - Production Dashboard Screen

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../providers/app_provider.dart';
import '../models/scene.dart';

enum _DashSubView { general, characters, locations }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _DashSubView _subView = _DashSubView.general;
  String _timeframe = 'SCENES';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final totalScenes = provider.scenes.length;
    final doneScenes = provider.scenes.where((s) => s.status.label == 'Done').length;
    final progressPercent = totalScenes > 0 ? (doneScenes / totalScenes * 100).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + sub-view switcher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRODUCTION INTELLIGENCE',
                    style: GoogleFonts.inter(
                      color: AppColors.goldLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SCENE_FLOW Insights',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              // Tab switcher
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    _SubTabButton(
                      icon: Icons.dashboard_outlined,
                      label: 'Overview',
                      isActive: _subView == _DashSubView.general,
                      onTap: () => setState(() => _subView = _DashSubView.general),
                    ),
                    _SubTabButton(
                      icon: Icons.bar_chart,
                      label: 'Cast',
                      isActive: _subView == _DashSubView.characters,
                      onTap: () => setState(() => _subView = _DashSubView.characters),
                    ),
                    _SubTabButton(
                      icon: Icons.pie_chart_outline,
                      label: 'Locations',
                      isActive: _subView == _DashSubView.locations,
                      onTap: () => setState(() => _subView = _DashSubView.locations),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sub views
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _subView == _DashSubView.general
                ? _GeneralView(
                    key: const ValueKey('general'),
                    progressPercent: progressPercent,
                    totalCharacters: provider.characters.length,
                    totalScenes: totalScenes,
                  )
                : _subView == _DashSubView.characters
                    ? _CharacterMetricsView(
                        key: const ValueKey('characters'),
                        timeframe: _timeframe,
                        onTimeframeChange: (t) => setState(() => _timeframe = t),
                        characters: provider.characters,
                      )
                    : _LocationsView(key: const ValueKey('locations')),
          ),
        ],
      ),
    );
  }
}

// ─── General Overview ───────────────────────────────────────────────────────

class _GeneralView extends StatelessWidget {
  final int progressPercent;
  final int totalCharacters;
  final int totalScenes;

  const _GeneralView({
    super.key,
    required this.progressPercent,
    required this.totalCharacters,
    required this.totalScenes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Project Dashboard',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Real-time production overview',
          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 24),

        // Circular progress ring
        Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _CircleProgressPainter(progress: progressPercent / 100),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$progressPercent%',
                      style: GoogleFonts.inter(
                        color: AppColors.goldLight,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'COMPLETED',
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Stats cards
        Row(
          children: [
            Expanded(
              child: GlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.people_outline, color: AppColors.teal, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL CHARACTERS',
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '$totalCharacters',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.movie_creation_outlined,
                          color: AppColors.gold, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL SCENES',
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '$totalScenes',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Character Metrics View ──────────────────────────────────────────────────

class _CharacterMetricsView extends StatelessWidget {
  final String timeframe;
  final ValueChanged<String> onTimeframeChange;
  final List characters;

  const _CharacterMetricsView({
    super.key,
    required this.timeframe,
    required this.onTimeframeChange,
    required this.characters,
  });

  @override
  Widget build(BuildContext context) {
    final topChars = [
      {
        'name': 'Julian Marlowe',
        'roleTitle': 'Lead Detective',
        'scenes': '432 sc',
        'change': '+8%',
        'up': true,
        'avatarUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuALijUqBTEDHuvXI0Tk_ZeyGqUh1oJjmbG3nyoPV5K9U3mseNB2Y6y9xD9LvDOVpI6zweOzxL3juffiFqCLgOm8I27lqc87-0VL7Og_ZWOSUdOsaW4KGWm509xzpy2Wb-VzsSoJ44b3ziqzEGWLuzIC9Zqzzf3_Yauuve22QSwizgYGHgRuRrkMJhmeRwFsT0PvTUX3g2XO51R4Fh6ULoExBkfKJpDSr3K86JPpYqntUOJTySyivfY-uq5IGTrCwYBmuo1lrFiZHFQ',
      },
      {
        'name': 'Evelyn Thorne',
        'roleTitle': 'Suspect',
        'scenes': '289 sc',
        'change': '+3%',
        'up': true,
        'avatarUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCsJoXD13WNPvnOKpWe84uAu5YPKSVc_GOsG5VQsNWMtcbszx-Pwv49f6Iw7dQ5jTckjBPkNZ-NH5_DZC0fSJxRD-hKftWdUCv5QV64ewSrkWqSBe2LFgBJVWNBRerkdWtJOEL4hA2rgyel45qPrpdyKuVTrSCXCUXUtvpO9fIGlxWjEy3LvWCI1JEL5sA_bdiP6__7xxQ9xxJ-BYXG7-SHdFAl0BmTSZoUJuL1Sg-VFfP3O6rW__PqrkYaQjBGucECPaMHkb2nBBc',
      },
      {
        'name': 'Elias Vance',
        'roleTitle': 'Informant',
        'scenes': '156 sc',
        'change': '-2%',
        'up': false,
        'avatarUrl':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuD4tma_hGH4Ka-1MlgtR6rxe2L9dnjBJDrmUHZ8mpUWq2Q_wYPkUgmUf0U_I2yIRTHIJTUuDZsGkTXrC0c3nBGxKtZUKsa7F37EaSaFH4YAvmrr0ZlbxM7g8o0xZJgmj08V3CtYLW7-Q0eM2ee6Nj3a-fcrqV_gf7YABNHPRYbknLNDAmsrlBNwGpYTlgl1KGqgaCkpPY8mwd-FUMw-l4VbyFGGj8jo5GZLagWWj-C7FH6XIu-1rbM9fnBtMA6oIdRuTE1IYGWmyiM',
      },
    ];

    return Column(
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
                  'Character Metrics',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Appearance frequency across production.',
                  style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardAlt,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Line chart card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL APPEARANCES',
                        style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '1,284',
                        style: GoogleFonts.inter(
                          color: AppColors.goldLight,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: AppColors.teal, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+12.4%',
                        style: GoogleFonts.jetBrainsMono(
                            color: AppColors.teal, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Line chart
              SizedBox(
                height: 120,
                child: CustomPaint(
                  size: const Size(double.infinity, 120),
                  painter: _LineChartPainter(),
                ),
              ),
              const SizedBox(height: 8),

              // X-axis labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Sc 12', 'Sc 24', 'Sc 36', 'Sc 48'].map((s) {
                  return Text(
                    s,
                    style: GoogleFonts.jetBrainsMono(
                        color: AppColors.textMuted, fontSize: 9),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Timeframe switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.cardAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: ['SCENES', 'DAYS', 'WEEKS'].map((label) {
                    final isActive = timeframe == label;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onTimeframeChange(label),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.goldLight.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: isActive ? AppColors.goldLight : AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Top characters list
        Row(
          children: [
            const Icon(Icons.military_tech, color: AppColors.goldLight, size: 16),
            const SizedBox(width: 6),
            Text(
              'Top Characters',
              style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...topChars.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Image.network(
                          item['avatarUrl'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const CircleAvatar(
                            backgroundColor: AppColors.surfaceAlt,
                            child: Icon(Icons.person, color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            item['roleTitle'] as String,
                            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['scenes'] as String,
                          style: GoogleFonts.jetBrainsMono(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              (item['up'] as bool) ? Icons.trending_up : Icons.trending_down,
                              size: 10,
                              color: (item['up'] as bool) ? AppColors.teal : Colors.redAccent,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item['change'] as String,
                              style: GoogleFonts.jetBrainsMono(
                                color: (item['up'] as bool) ? AppColors.teal : Colors.redAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

// ─── Locations View ──────────────────────────────────────────────────────────

class _LocationsView extends StatelessWidget {
  const _LocationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final topLocations = [
      {
        'name': "Detective's Office",
        'details': 'Night • Main Desk Set',
        'scenes': '8',
        'type': 'INT',
        'img':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBXTz-kV08Fgtv9_9IndKQnMY2ad37lT_mAWOkUaQ_kf1ysgb74AqYo4p_81LAlIncc5rbU3T9EbLVeTqYta6_bqAKd5sCGCFT1mAwOWFOLNGyfApphUPdGwNMQ74eigaehLnNTBOcU6I52fPz0mqkQRuTJ3tc7zNu_rBMAQOVikKZti7FsqiDmhuEdgltswNjpQsi9s1p8AmVcKqjiAF65MXvlBjHROzk2GnNXzTJtSQXTZ3VV5huE0nP0AEw3FgYe2zPI5302xvY',
      },
      {
        'name': 'Rainy Alleyway',
        'details': 'Night • Backlot Entrance',
        'scenes': '5',
        'type': 'EXT',
        'img':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBVdodGU6285PDgY-9OmqnjdYcskXAWQ4PyDjtyOpneUMvNzUKs2RyPGbzwC9xbKIAfU7_ENyRQAakzLie1xoEXeRMz0m6fe1DyqQWV8VTGE0Qm-1GwER7wcVqdWZ0Lza10ud5X1vpS39LAT2Ifr0goRbg1ql4NHYbzRtp11rj-SXoAM4WwDKXiYveegZEdpt5d4Fc89azQEL5cCnvolvU51vKbnTVORcYYSPHEIv3EztrC5Gklo-WDgo-MrtvY1J3HY2rllak88Wo',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Locations Dashboard',
          style: GoogleFonts.inter(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Atmospheric variables breakdown.',
          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 24),

        // Donut chart
        Center(
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _DonutChartPainter(),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '24',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'TOTAL',
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Legend cards
        Row(
          children: [
            Expanded(
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              color: AppColors.gold, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'INTERIOR',
                          style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('60%',
                            style: GoogleFonts.inter(
                                color: AppColors.gold,
                                fontSize: 22,
                                fontWeight: FontWeight.w900)),
                        Text('14 SCENES',
                            style: GoogleFonts.jetBrainsMono(
                                color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              color: AppColors.teal, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'EXTERIOR',
                          style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('40%',
                            style: GoogleFonts.inter(
                                color: AppColors.teal,
                                fontSize: 22,
                                fontWeight: FontWeight.w900)),
                        Text('10 SCENES',
                            style: GoogleFonts.jetBrainsMono(
                                color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Top locations
        Row(
          children: [
            const Icon(Icons.place, color: AppColors.goldLight, size: 16),
            const SizedBox(width: 6),
            Text(
              'Top Locations',
              style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...topLocations.map((loc) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: Image.network(
                              loc['img']!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: AppColors.surfaceAlt),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                loc['type']!,
                                style: GoogleFonts.inter(
                                    color: AppColors.goldLight,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc['name']!,
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loc['details']!,
                            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          loc['scenes']!,
                          style: GoogleFonts.jetBrainsMono(
                              color: AppColors.gold,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'SCENES',
                          style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

// ─── Custom Painters ─────────────────────────────────────────────────────────

class _CircleProgressPainter extends CustomPainter {
  final double progress;

  const _CircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.40;
    final strokeWidth = 6.0;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) => oldDelegate.progress != progress;
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Gradient fill
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.gold.withValues(alpha: 0.25),
          AppColors.gold.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final fillPath = Path()
      ..moveTo(0, h * 0.85)
      ..cubicTo(w * 0.2, h * 0.65, w * 0.35, h * 0.95, w * 0.5, h * 0.45)
      ..cubicTo(w * 0.65, h * 0.15, w * 0.8, h * 0.55, w, h * 0.25)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(fillPath, gradientPaint);

    // Line stroke
    final linePaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final linePath = Path()
      ..moveTo(0, h * 0.85)
      ..cubicTo(w * 0.2, h * 0.65, w * 0.35, h * 0.95, w * 0.5, h * 0.45)
      ..cubicTo(w * 0.65, h * 0.15, w * 0.8, h * 0.55, w, h * 0.25);

    canvas.drawPath(linePath, linePaint);

    // Anchor dots
    final dotPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final dotFill = Paint()
      ..color = const Color(0xFF131313)
      ..style = PaintingStyle.fill;

    for (final pt in [Offset(w * 0.5, h * 0.45), Offset(w, h * 0.25)]) {
      canvas.drawCircle(pt, 4, dotFill);
      canvas.drawCircle(pt, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter _) => false;
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    const strokeWidth = 16.0;

    // Background ring
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Interior (gold 60%)
    final goldPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * 0.60,
      false,
      goldPaint,
    );

    // Exterior (teal 40%)
    final tealPaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + 2 * pi * 0.62,
      2 * pi * 0.38,
      false,
      tealPaint,
    );
  }

  @override
  bool shouldRepaint(_DonutChartPainter _) => false;
}

class _SubTabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SubTabButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.goldLight : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 13,
              color: isActive ? const Color(0xFF402D00) : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? const Color(0xFF402D00) : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
