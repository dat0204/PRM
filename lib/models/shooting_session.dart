// lib/models/shooting_session.dart
// SceneFlow - ShootingSession data model

class ShootingSession {
  final String id;
  final String locationName;
  final int dayNumber;
  final String settingHeader;
  final int scenesCount;
  final double estimatedHours;
  final List<String> sceneIds;

  const ShootingSession({
    required this.id,
    required this.locationName,
    required this.dayNumber,
    required this.settingHeader,
    required this.scenesCount,
    required this.estimatedHours,
    required this.sceneIds,
  });

  ShootingSession copyWith({
    String? id,
    String? locationName,
    int? dayNumber,
    String? settingHeader,
    int? scenesCount,
    double? estimatedHours,
    List<String>? sceneIds,
  }) {
    return ShootingSession(
      id: id ?? this.id,
      locationName: locationName ?? this.locationName,
      dayNumber: dayNumber ?? this.dayNumber,
      settingHeader: settingHeader ?? this.settingHeader,
      scenesCount: scenesCount ?? this.scenesCount,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      sceneIds: sceneIds ?? this.sceneIds,
    );
  }
}
