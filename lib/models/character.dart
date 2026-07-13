// lib/models/character.dart
// SceneFlow - Character data model

enum CharacterRole { main, supporting, extra }

extension CharacterRoleExtension on CharacterRole {
  String get label {
    switch (this) {
      case CharacterRole.main:
        return 'MAIN';
      case CharacterRole.supporting:
        return 'SUPPORTING';
      case CharacterRole.extra:
        return 'EXTRA';
    }
  }

  static CharacterRole fromString(String s) {
    switch (s) {
      case 'main':
        return CharacterRole.main;
      case 'supporting':
        return CharacterRole.supporting;
      case 'extra':
        return CharacterRole.extra;
      default:
        return CharacterRole.extra;
    }
  }
}

class Character {
  final String id;
  final String name;
  final CharacterRole role;
  final String roleTitle;
  final String avatarUrl;
  final String psychologicalProfile;

  const Character({
    required this.id,
    required this.name,
    required this.role,
    required this.roleTitle,
    required this.avatarUrl,
    required this.psychologicalProfile,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role.label,
      'roleTitle': roleTitle,
      'avatarUrl': avatarUrl,
      'psychologicalProfile': psychologicalProfile,
    };
  }

  factory Character.fromMap(Map<String, Object?> map) {
    return Character(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      role: CharacterRoleExtension.fromString(
          (map['role'] as String? ?? 'extra').toLowerCase()),
      roleTitle: map['roleTitle'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      psychologicalProfile: map['psychologicalProfile'] as String? ?? '',
    );
  }

  Character copyWith({
    String? id,
    String? name,
    CharacterRole? role,
    String? roleTitle,
    String? avatarUrl,
    String? psychologicalProfile,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      roleTitle: roleTitle ?? this.roleTitle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      psychologicalProfile: psychologicalProfile ?? this.psychologicalProfile,
    );
  }
}
