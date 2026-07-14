// lib/providers/app_provider.dart
// SceneFlow - Central state management using Provider + SQLite persistence

import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../models/character.dart';
import '../models/location_item.dart';
import '../models/scene.dart';
import '../models/shooting_session.dart';
import '../data/mock_data.dart';
import '../data/app_database.dart';

enum TabKey { projects, schedule, board, team, locations, planner }

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
  final AppDatabase _db = AppDatabase.instance;

  // Data stores (in-memory cache, mirrored to/from SQLite)
  List<Project> _projects = [];
  List<Character> _characters = [];
  List<LocationItem> _locations = [];
  List<Scene> _scenes = [];

  // Loading state (true while the initial SQLite load/seed is happening)
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Navigation state
  TabKey _currentTab = TabKey.projects;
  String _selectedProjectId = 'long-goodbye';
  String? _selectedSceneId;

  // Overlay screen states
  bool _isAddingProject = false;
  bool _isAddingCharacter = false;
  bool _isFiltering = false;
  bool _isExporting = false;

  // Project đang được sửa khi mở AddProjectScreen ở chế độ Edit (F1.1).
  // Bằng null khi người dùng bấm "+" để tạo dự án mới.
  Project? _editingProject;
  Project? get editingProject => _editingProject;

  // Filter state
  SceneFilterState _activeFilters = const SceneFilterState();

  AppProvider() {
    _bootstrap();
  }

  // Nếu bootstrap lỗi, lưu lại để UI có thể hiển thị thay vì xoay mãi.
  Object? _bootstrapError;
  Object? get bootstrapError => _bootstrapError;

  // -- Bootstrap: load from SQLite, seeding with mock data on first run --
  Future<void> _bootstrap() async {
    try {
      final alreadySeeded = await _db.isSeeded;

      if (!alreadySeeded) {
        final sceneCharacterLinks = <String, List<String>>{
          for (final s in initialScenes) s.id: s.characterIds,
        };
        await _db.seedIfEmpty(
          projects: initialProjects.map((p) => p.toMap()).toList(),
          characters: initialCharacters.map((c) => c.toMap()).toList(),
          locations: initialLocations.map((l) => l.toMap()).toList(),
          scenes: initialScenes.map((s) => s.toMap()).toList(),
          sceneCharacterLinks: sceneCharacterLinks,
        );
      }

      await _reloadAllFromDb();
    } catch (e, st) {
      // In lỗi thật ra console thay vì để loading xoay vô thời hạn.
      // ignore: avoid_print
      print('AppProvider._bootstrap() ERROR: $e');
      // ignore: avoid_print
      print(st);
      _bootstrapError = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _reloadAllFromDb() async {
    final projectRows = await _db.getAllProjects();
    final characterRows = await _db.getAllCharacters();
    final locationRows = await _db.getAllLocations();
    final sceneRows = await _db.getAllScenes();
    final links = await _db.getAllSceneCharacterLinks();

    _projects = projectRows.map((r) => Project.fromMap(r)).toList();
    _characters = characterRows.map((r) => Character.fromMap(r)).toList();
    _locations = locationRows.map((r) => LocationItem.fromMap(r)).toList();
    _scenes = sceneRows
        .map((r) => Scene.fromMap(r, characterIds: links[r['id'] as String] ?? const []))
        .toList();
  }

  // Getters
  List<Project> get projects => _projects;
  List<Character> get characters => _characters;
  List<LocationItem> get locations => _locations;
  List<Scene> get scenes => _scenes;

  /// Production Planner (F4.1): scenes of the active project are grouped
  /// automatically by their Location, producing a proposed shooting-day
  /// schedule. This is computed on demand -- it is NOT a stored table --
  /// so it always reflects the current state of Scenes/Locations.
  List<ShootingSession> get schedule => productionScheduleFor(_selectedProjectId);

  List<ShootingSession> productionScheduleFor(String projectId) {
    final projectScenes = _scenes.where((s) => s.projectId == projectId).toList();
    if (projectScenes.isEmpty) return [];

    // Group scene ids by locationId, preserving stable order of first
    // appearance so the result is deterministic.
    final Map<String, List<Scene>> byLocation = {};
    for (final scene in projectScenes) {
      byLocation.putIfAbsent(scene.locationId, () => []).add(scene);
    }

    final sessions = <ShootingSession>[];
    var dayNumber = 1;
    for (final entry in byLocation.entries) {
      final locId = entry.key;
      final sceneGroup = entry.value;
      final location = _locations.where((l) => l.id == locId).cast<LocationItem?>().firstOrNull;

      final totalHours =
      sceneGroup.fold<double>(0, (sum, s) => sum + s.estimatedHours);

      final settingLabel = sceneGroup.first.setting.label;
      final timeLabel = sceneGroup.first.timeOfDay.label;
      final locationLabel = location?.name ?? sceneGroup.first.locationId;

      sessions.add(ShootingSession(
        id: 'auto-sess-$locId',
        locationName: '${locationLabel.toUpperCase()} - DAY $dayNumber',
        dayNumber: dayNumber,
        settingHeader: '$settingLabel. $locationLabel - $timeLabel',
        scenesCount: sceneGroup.length,
        estimatedHours: totalHours,
        sceneIds: sceneGroup.map((s) => s.id).toList(),
      ));
      dayNumber++;
    }

    // Largest shoots first so the crew tackles the biggest location first.
    sessions.sort((a, b) => b.scenesCount.compareTo(a.scenesCount));
    return sessions;
  }

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
      _editingProject = null;
    } else if (_isAddingCharacter) {
      _isAddingCharacter = false;
    } else if (_isFiltering) {
      _isFiltering = false;
    } else if (_isExporting) {
      _isExporting = false;
    }
    notifyListeners();
  }

  /// F1.1: mở màn hình Add/Edit Project. Truyền [existing] để mở ở chế độ
  /// sửa (AddProjectScreen sẽ đọc `provider.editingProject` để biết).
  void startAddProject({Project? existing}) {
    _editingProject = existing;
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

  // -- Data mutations (update in-memory state immediately, persist to
  // SQLite in the background so callers keep the same synchronous API
  // used across the rest of the app) --

  void saveProject(Project newProject) {
    _projects = [..._projects, newProject];
    _selectedProjectId = newProject.id;
    _isAddingProject = false;
    _editingProject = null;
    _currentTab = TabKey.projects;
    notifyListeners();
    _db.upsertProject(newProject.toMap());
  }

  /// F1.1: cập nhật một dự án đã tồn tại.
  void updateProject(String id, Project updated) {
    _projects = _projects.map((p) => p.id == id ? updated : p).toList();
    _selectedProjectId = updated.id;
    _isAddingProject = false;
    _editingProject = null;
    _currentTab = TabKey.projects;
    notifyListeners();
    _db.upsertProject(updated.toMap());
  }

  /// F1.1: xóa một dự án. Các Scene thuộc dự án này cũng bị xóa theo
  /// (cascade ở tầng SQLite lẫn ở bộ nhớ trong).
  void deleteProject(String id) {
    _projects = _projects.where((p) => p.id != id).toList();
    _scenes = _scenes.where((s) => s.projectId != id).toList();
    if (_selectedProjectId == id && _projects.isNotEmpty) {
      _selectedProjectId = _projects.first.id;
    }
    notifyListeners();
    _db.deleteProject(id);
  }

  void saveCharacter(Character newCharacter) {
    _characters = [..._characters, newCharacter];
    _isAddingCharacter = false;
    notifyListeners();
    _db.upsertCharacter(newCharacter.toMap());
  }

  void saveSceneDetails(String sceneId, Scene updatedScene) {
    _scenes = _scenes.map((s) => s.id == sceneId ? updatedScene : s).toList();
    _selectedSceneId = null;
    notifyListeners();
    _db.upsertScene(updatedScene.toMap(), updatedScene.characterIds);
  }

  void addLocation(LocationItem newLocation) {
    _locations = [..._locations, newLocation];
    notifyListeners();
    _db.upsertLocation(newLocation.toMap());
  }

  void updateLocation(String id, LocationItem updated) {
    _locations = _locations.map((l) => l.id == id ? updated : l).toList();
    notifyListeners();
    _db.upsertLocation(updated.toMap());
  }

  /// Deletes a Location. Scenes still referencing this location fall back
  /// to showing the raw id if it can no longer be resolved, so no Scene
  /// data is silently lost.
  void deleteLocation(String id) {
    _locations = _locations.where((l) => l.id != id).toList();
    notifyListeners();
    _db.deleteLocation(id);
  }

  void addScene(Scene newScene) {
    _scenes = [..._scenes, newScene];
    notifyListeners();
    _db.upsertScene(newScene.toMap(), newScene.characterIds);
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
    if (_isAddingProject) return _editingProject != null ? 'EDIT SLATE' : 'NEW SLATE';
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
      case TabKey.locations:
        return 'LOCATIONS';
      case TabKey.planner:
        return 'PRODUCTION PLANNER';
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

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}