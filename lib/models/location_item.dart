// lib/models/location_item.dart
// SceneFlow - LocationItem data model

enum LocationSetting { interior, exterior }

enum LocationTimeOfDay { day, night }

extension LocationSettingExtension on LocationSetting {
  String get label => this == LocationSetting.interior ? 'INT' : 'EXT';

  static LocationSetting fromString(String s) {
    return s == 'INT' ? LocationSetting.interior : LocationSetting.exterior;
  }
}

extension LocationTimeOfDayExtension on LocationTimeOfDay {
  String get label => this == LocationTimeOfDay.day ? 'DAY' : 'NIGHT';

  static LocationTimeOfDay fromString(String s) {
    return s == 'DAY' ? LocationTimeOfDay.day : LocationTimeOfDay.night;
  }
}

class LocationItem {
  final String id;
  final String name;
  final String scenesCovered;
  final String area;
  final LocationSetting setting;
  final LocationTimeOfDay timeOfDay;
  final String notes;
  final String? imageUrl;

  const LocationItem({
    required this.id,
    required this.name,
    required this.scenesCovered,
    required this.area,
    required this.setting,
    required this.timeOfDay,
    required this.notes,
    this.imageUrl,
  });

  LocationItem copyWith({
    String? id,
    String? name,
    String? scenesCovered,
    String? area,
    LocationSetting? setting,
    LocationTimeOfDay? timeOfDay,
    String? notes,
    String? imageUrl,
  }) {
    return LocationItem(
      id: id ?? this.id,
      name: name ?? this.name,
      scenesCovered: scenesCovered ?? this.scenesCovered,
      area: area ?? this.area,
      setting: setting ?? this.setting,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
