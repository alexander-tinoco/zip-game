import '../../domain/entities/game_entities.dart';

class GameSessionModel extends GameSession {
  const GameSessionModel({
    required super.id,
    required super.levelId,
    required super.status,
    required super.difficulty,
  });

  factory GameSessionModel.fromJson(Map<String, dynamic> json) => GameSessionModel(
        id: json['id'] as int,
        levelId: json['level_id'] as int,
        status: json['status'] as String,
        difficulty: json['difficulty'] as String,
      );
}

class HintModel extends Hint {
  const HintModel({
    required super.type,
    required super.nextCell,
    required super.hintsUsed,
    super.undoSteps,
  });

  factory HintModel.fromJson(Map<String, dynamic> json) {
    final hint = json['hint'] as Map<String, dynamic>;
    return HintModel(
      type: hint['type'] == 'backtrack' ? HintType.backtrack : HintType.next,
      nextCell: hint['next_cell'] as int,
      undoSteps: (hint['undo_steps'] as int?) ?? 0,
      hintsUsed: json['hints_used'] as int,
    );
  }
}

class GameResultModel extends GameResult {
  const GameResultModel({
    required super.points,
    required super.durationSeconds,
    required super.mistakes,
    required super.hintsUsed,
    required super.breakdown,
    required super.performance,
    required super.recommendedDifficulty,
    required super.difficultyChange,
  });

  factory GameResultModel.fromJson(Map<String, dynamic> json) {
    final score = json['score'] as Map<String, dynamic>;
    final difficulty = json['difficulty'] as Map<String, dynamic>;
    return GameResultModel(
      points: score['points'] as int,
      durationSeconds: score['duration_seconds'] as int,
      mistakes: score['mistakes'] as int,
      hintsUsed: score['hints_used'] as int,
      breakdown: (score['breakdown'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value as int)),
      performance: json['performance'] as String,
      recommendedDifficulty: difficulty['recommended'] as String,
      difficultyChange: difficulty['change'] as String,
    );
  }
}

Map<String, dynamic> moveToJson(MoveRecord move) => {
      'type': move.type.name,
      if (move.cell != null) 'cell': move.cell,
      'elapsed_ms': move.elapsedMs,
    };
