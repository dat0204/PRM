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
