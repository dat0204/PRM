// lib/models/scene.dart
// SceneFlow - Scene data model

enum SceneStatus { done, inProgress, drafting }

enum SceneSetting { interior, exterior }

enum SceneTimeOfDay { day, night }

extension SceneStatusExtension on SceneStatus {
  String get label {
    switch (this) {
      case SceneStatus.done:
        return 'Done';
      case SceneStatus.inProgress:
        return 'In Progress';
      case SceneStatus.drafting:
        return 'Drafting';
    }
  }

  static SceneStatus fromString(String s) {
    switch (s) {
      case 'Done':
        return SceneStatus.done;
      case 'In Progress':
        return SceneStatus.inProgress;
      case 'Drafting':
        return SceneStatus.drafting;
      default:
        return SceneStatus.drafting;
    }
  }
}

extension SceneSettingExtension on SceneSetting {
  String get label => this == SceneSetting.interior ? 'INT' : 'EXT';

  static SceneSetting fromString(String s) {
    return s == 'INT' ? SceneSetting.interior : SceneSetting.exterior;
  }
}

extension SceneTimeOfDayExtension on SceneTimeOfDay {
  String get label => this == SceneTimeOfDay.day ? 'DAY' : 'NIGHT';

  static SceneTimeOfDay fromString(String s) {
    return s == 'DAY' ? SceneTimeOfDay.day : SceneTimeOfDay.night;
  }
}

class Scene {
  final String id;
  final String projectId;
  final String code;
  final String title;
  final String act;
  final SceneStatus status;
  final String description;
  final SceneSetting setting;
  final SceneTimeOfDay timeOfDay;
  final String locationId;
  final List<String> characterIds;
  final String pages;
  final double estimatedHours;
  final String actionDialogueText;

  const Scene({
    required this.id,
    required this.projectId,
    required this.code,
    required this.title,
    required this.act,
    required this.status,
    required this.description,
    required this.setting,
    required this.timeOfDay,
    required this.locationId,
    required this.characterIds,
    required this.pages,
    required this.estimatedHours,
    required this.actionDialogueText,
  });

  Scene copyWith({
    String? id,
    String? projectId,
    String? code,
    String? title,
    String? act,
    SceneStatus? status,
    String? description,
    SceneSetting? setting,
    SceneTimeOfDay? timeOfDay,
    String? locationId,
    List<String>? characterIds,
    String? pages,
    double? estimatedHours,
    String? actionDialogueText,
  }) {
    return Scene(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      code: code ?? this.code,
      title: title ?? this.title,
      act: act ?? this.act,
      status: status ?? this.status,
      description: description ?? this.description,
      setting: setting ?? this.setting,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      locationId: locationId ?? this.locationId,
      characterIds: characterIds ?? this.characterIds,
      pages: pages ?? this.pages,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actionDialogueText: actionDialogueText ?? this.actionDialogueText,
    );
  }
}
