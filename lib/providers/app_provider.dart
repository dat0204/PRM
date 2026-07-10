// lib/providers/app_provider.dart
// SceneFlow - Central state management using Provider

import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../models/character.dart';
import '../models/location_item.dart';
import '../models/scene.dart';
import '../models/shooting_session.dart';
import '../data/mock_data.dart';

enum TabKey { projects, schedule, board, team }

class SceneFilterState {
  final String? characterId;
  final String timeOfDay; // 'DAY' | 'NIGHT' | 'ALL'
  final String setting;   // 'INT' | 'EXT' | 'ALL'
  final String status;    // 'Done' | 'In Progress' | 'Drafting' | 'ALL'

  const SceneFilterState({
    this.characterId,
    this.timeOfDay = 'ALL',
    this.setting = 'ALL',
    this.status = 'ALL',
  });

  SceneFilterState copyWith({
    String? characterId,
    String? timeOfDay,
    String? setting,
    String? status,
    bool clearCharacterId = false,
  }) {
    return SceneFilterState(
      characterId: clearCharacterId ? null : (characterId ?? this.characterId),
      timeOfDay: timeOfDay ?? this.timeOfDay,
      setting: setting ?? this.setting,
      status: status ?? this.status,
    );
  }

  bool get hasActiveFilters =>
      characterId != null || timeOfDay != 'ALL' || setting != 'ALL' || status != 'ALL';
}

class AppProvider extends ChangeNotifier {
  // Data stores
  List<Project> _projects = List.from(initialProjects);
  List<Character> _characters = List.from(initialCharacters);
  List<LocationItem> _locations = List.from(initialLocations);
  List<Scene> _scenes = List.from(initialScenes);
  List<ShootingSession> _schedule = List.from(initialSchedule);

  // Navigation state
  TabKey _currentTab = TabKey.projects;
  String _selectedProjectId = 'long-goodbye';
  String? _selectedSceneId;

  // Overlay screen states
  bool _isAddingProject = false;
  bool _isAddingCharacter = false;
  bool _isFiltering = false;
  bool _isExporting = false;

  // Filter state
  SceneFilterState _activeFilters = const SceneFilterState();

  // Getters
  List<Project> get projects => _projects;
  List<Character> get characters => _characters;
  List<LocationItem> get locations => _locations;
  List<Scene> get scenes => _scenes;
  List<ShootingSession> get schedule => _schedule;

  TabKey get currentTab => _currentTab;
  String get selectedProjectId => _selectedProjectId;
  String? get selectedSceneId => _selectedSceneId;

  bool get isAddingProject => _isAddingProject;
  bool get isAddingCharacter => _isAddingCharacter;
  bool get isFiltering => _isFiltering;
  bool get isExporting => _isExporting;

  SceneFilterState get activeFilters => _activeFilters;

  Project get activeProject =>
      _projects.firstWhere((p) => p.id == _selectedProjectId, orElse: () => _projects.first);

  Scene? get activeScene =>
      _selectedSceneId != null
          ? _scenes.firstWhere((s) => s.id == _selectedSceneId, orElse: () => _scenes.first)
          : null;

  bool get showBackButton =>
      _isAddingProject || _isAddingCharacter || _isFiltering || _isExporting || _selectedSceneId != null;

  // Navigation actions
  void setCurrentTab(TabKey tab) {
    _currentTab = tab;
    _activeFilters = const SceneFilterState();
    notifyListeners();
  }

  void selectProject(String projectId) {
    _selectedProjectId = projectId;
    _currentTab = TabKey.schedule;
    notifyListeners();
  }

  void selectScene(String sceneId) {
    _selectedSceneId = sceneId;
    notifyListeners();
  }

  void goBack() {
    if (_selectedSceneId != null) {
      _selectedSceneId = null;
    } else if (_isAddingProject) {
      _isAddingProject = false;
    } else if (_isAddingCharacter) {
      _isAddingCharacter = false;
    } else if (_isFiltering) {
      _isFiltering = false;
    } else if (_isExporting) {
      _isExporting = false;
    }
    notifyListeners();
  }

  void startAddProject() {
    _isAddingProject = true;
    notifyListeners();
  }

  void startAddCharacter() {
    _isAddingCharacter = true;
    notifyListeners();
  }

  void startFiltering() {
    _isFiltering = true;
    notifyListeners();
  }

  void startExporting() {
    _isExporting = true;
    notifyListeners();
  }

  // Data mutations
  void saveProject(Project newProject) {
    _projects = [..._projects, newProject];
    _selectedProjectId = newProject.id;
    _isAddingProject = false;
    _currentTab = TabKey.projects;
    notifyListeners();
  }

  void saveCharacter(Character newCharacter) {
    _characters = [..._characters, newCharacter];
    _isAddingCharacter = false;
    notifyListeners();
  }

  void saveSceneDetails(String sceneId, Scene updatedScene) {
    _scenes = _scenes.map((s) => s.id == sceneId ? updatedScene : s).toList();
    _selectedSceneId = null;
    notifyListeners();
  }

  void addLocation(LocationItem newLocation) {
    _locations = [..._locations, newLocation];
    notifyListeners();
  }

  void updateLocation(String id, LocationItem updated) {
    _locations = _locations.map((l) => l.id == id ? updated : l).toList();
    notifyListeners();
  }

  void addScene(Scene newScene) {
    _scenes = [..._scenes, newScene];
    notifyListeners();
  }

  void applyFilters(SceneFilterState filters) {
    _activeFilters = filters;
    _isFiltering = false;
    notifyListeners();
  }

  void resetFilters() {
    _activeFilters = const SceneFilterState();
    notifyListeners();
  }

  // Computed getters
  String get headerTitle {
    if (_isAddingProject) return 'NEW SLATE';
    if (_isAddingCharacter) return 'NEW CAST';
    if (_isFiltering) return 'FILTERS';
    if (_isExporting) return 'EXPORT REPORT';
    if (_selectedSceneId != null) return 'SCENE DETAILS';
    switch (_currentTab) {
      case TabKey.projects:
        return 'SCENE_FLOW';
      case TabKey.schedule:
        return 'SCENE BOARD';
      case TabKey.board:
        return 'DASHBOARD';
      case TabKey.team:
        return 'CAST & DIRECTORY';
    }
  }

  List<Scene> filteredScenesForProject(String projectId) {
    return _scenes.where((scene) {
      if (scene.projectId != projectId) return false;
      if (_activeFilters.characterId != null &&
          !scene.characterIds.contains(_activeFilters.characterId)) return false;
      if (_activeFilters.timeOfDay != 'ALL' &&
          scene.timeOfDay.label != _activeFilters.timeOfDay) return false;
      if (_activeFilters.setting != 'ALL' &&
          scene.setting.label != _activeFilters.setting) return false;
      if (_activeFilters.status != 'ALL' &&
          scene.status.label != _activeFilters.status) return false;
      return true;
    }).toList();
  }
}
