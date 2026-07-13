// lib/app.dart
// SceneFlow - Main application widget with navigation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'widgets/app_header.dart';
import 'widgets/bottom_nav.dart';
import 'providers/app_provider.dart';

// Screens
import 'screens/projects_list_screen.dart';
import 'screens/scene_board_screen.dart';
import 'screens/characters_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/scene_detail_screen.dart';
import 'screens/add_project_screen.dart';
import 'screens/add_character_screen.dart';
import 'screens/export_screen.dart';
import 'screens/advanced_filter_screen.dart';
import 'screens/location_screen.dart';
import 'screens/schedule_screen.dart';

class SceneFlowApp extends StatelessWidget {
  const SceneFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SceneFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _AppShell(),
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.goldLight),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppHeader(
        title: provider.headerTitle,
        showBack: provider.showBackButton,
        onBack: () => provider.goBack(),
        onProfileClick: () => provider.startExporting(),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: _buildCurrentScreen(provider),
      ),
      bottomNavigationBar: provider.showBackButton
          ? null
          : AppBottomNav(
        activeTab: provider.currentTab,
        onTabChange: provider.setCurrentTab,
      ),
    );
  }

  Widget _buildCurrentScreen(AppProvider provider) {
    // Overlay screens (modal-like sub-screens)
    if (provider.isAddingProject) {
      return const AddProjectScreen(key: ValueKey('add-project'));
    }
    if (provider.isAddingCharacter) {
      return const AddCharacterScreen(key: ValueKey('add-char'));
    }
    if (provider.isFiltering) {
      return const AdvancedFilterScreen(key: ValueKey('filter'));
    }
    if (provider.isExporting) {
      return const ExportScreen(key: ValueKey('export'));
    }
    if (provider.selectedSceneId != null) {
      return const SceneDetailScreen(key: ValueKey('scene-detail'));
    }

    // Main tab screens
    switch (provider.currentTab) {
      case TabKey.projects:
        return const ProjectsListScreen(key: ValueKey('projects'));
      case TabKey.schedule:
        return const SceneBoardScreen(key: ValueKey('board'));
      case TabKey.board:
        return const DashboardScreen(key: ValueKey('dashboard'));
      case TabKey.team:
        return const CharactersScreen(key: ValueKey('team'));
      case TabKey.locations:
        return const LocationScreen(key: ValueKey('locations'));
      case TabKey.planner:
        return const ScheduleScreen(key: ValueKey('planner'));
    }
  }
}
