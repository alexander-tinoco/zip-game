import '../../domain/entities/level.dart';

class LevelModel extends Level {
  const LevelModel({
    required super.id,
    required super.name,
    required super.difficulty,
    required super.size,
    required super.checkpoints,
    super.difficultyScore,
    super.completed,
    super.bestScore,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
        id: json['id'] as int,
        name: json['name'] as String,
        difficulty: json['difficulty'] as String,
        size: json['size'] as int,
        checkpoints: (json['checkpoints'] as List).map((e) => e as int).toList(),
        difficultyScore: (json['difficulty_score'] as int?) ?? 0,
        completed: (json['completed'] as bool?) ?? false,
        bestScore: json['best_score'] as int?,
      );
}
