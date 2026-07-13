// lib/models/project.dart
// SceneFlow - Project data model

enum ProjectType { feature, short, tvSeries }

enum ProjectGenre { sciFi, drama, thriller, noir, mystery }

enum ProjectStatus { inProduction, preProduction, completed }

extension ProjectTypeExtension on ProjectType {
  String get label {
    switch (this) {
      case ProjectType.feature:
        return 'Feature';
      case ProjectType.short:
        return 'Short';
      case ProjectType.tvSeries:
        return 'TV Series';
    }
  }

  static ProjectType fromString(String s) {
    switch (s) {
      case 'Feature':
        return ProjectType.feature;
      case 'Short':
        return ProjectType.short;
      case 'TV Series':
        return ProjectType.tvSeries;
      default:
        return ProjectType.feature;
    }
  }
}

extension ProjectGenreExtension on ProjectGenre {
  String get label {
    switch (this) {
      case ProjectGenre.sciFi:
        return 'Sci-Fi';
      case ProjectGenre.drama:
        return 'Drama';
      case ProjectGenre.thriller:
        return 'Thriller';
      case ProjectGenre.noir:
        return 'Noir';
      case ProjectGenre.mystery:
        return 'Mystery';
    }
  }

  static ProjectGenre fromString(String s) {
    switch (s) {
      case 'Sci-Fi':
        return ProjectGenre.sciFi;
      case 'Drama':
        return ProjectGenre.drama;
      case 'Thriller':
        return ProjectGenre.thriller;
      case 'Noir':
        return ProjectGenre.noir;
      case 'Mystery':
        return ProjectGenre.mystery;
      default:
        return ProjectGenre.drama;
    }
  }
}

extension ProjectStatusExtension on ProjectStatus {
  String get label {
    switch (this) {
      case ProjectStatus.inProduction:
        return 'In Production';
      case ProjectStatus.preProduction:
        return 'Pre-Production';
      case ProjectStatus.completed:
        return 'Completed';
    }
  }

  static ProjectStatus fromString(String s) {
    switch (s) {
      case 'In Production':
        return ProjectStatus.inProduction;
      case 'Pre-Production':
        return ProjectStatus.preProduction;
      case 'Completed':
        return ProjectStatus.completed;
      default:
        return ProjectStatus.inProduction;
    }
  }
}

class Project {
  final String id;
  final String title;
  final String description;
  final String startDate;
  final String director;
  final ProjectType type;
  final ProjectGenre genre;
  final ProjectStatus status;
  final int progress;
  final String thumbnailUrl;
  final String codeName;
  final List<String> acts;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.director,
    required this.type,
    required this.genre,
    required this.status,
    required this.progress,
    required this.thumbnailUrl,
    required this.codeName,
    required this.acts,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate,
      'director': director,
      'type': type.label,
      'genre': genre.label,
      'status': status.label,
      'progress': progress,
      'thumbnailUrl': thumbnailUrl,
      'codeName': codeName,
      'acts': jsonEncodeActs(acts),
    };
  }

  static String jsonEncodeActs(List<String> acts) => acts.join('|||');

  static List<String> jsonDecodeActs(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    return raw.split('|||');
  }

  factory Project.fromMap(Map<String, Object?> map) {
    return Project(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      startDate: map['startDate'] as String? ?? '',
      director: map['director'] as String? ?? '',
      type: ProjectTypeExtension.fromString(map['type'] as String? ?? 'Feature'),
      genre: ProjectGenreExtension.fromString(map['genre'] as String? ?? 'Drama'),
      status: ProjectStatusExtension.fromString(map['status'] as String? ?? 'In Production'),
      progress: map['progress'] as int? ?? 0,
      thumbnailUrl: map['thumbnailUrl'] as String? ?? '',
      codeName: map['codeName'] as String? ?? '',
      acts: jsonDecodeActs(map['acts'] as String?),
    );
  }

  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? startDate,
    String? director,
    ProjectType? type,
    ProjectGenre? genre,
    ProjectStatus? status,
    int? progress,
    String? thumbnailUrl,
    String? codeName,
    List<String>? acts,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      director: director ?? this.director,
      type: type ?? this.type,
      genre: genre ?? this.genre,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      codeName: codeName ?? this.codeName,
      acts: acts ?? this.acts,
    );
  }
}
