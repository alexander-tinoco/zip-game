/// Sesión de juego creada por el backend
class GameSession {
  const GameSession({
    required this.id,
    required this.levelId,
    required this.status,
    required this.difficulty,
  });

  final int id;
  final int levelId;
  final String status;
  final String difficulty;
}

enum MoveType { add, undo, invalid, restart }

/// Registro de cada interacción (se envía al terminar y se guarda en game_moves)
class MoveRecord {
  const MoveRecord({required this.type, this.cell, required this.elapsedMs});

  final MoveType type;
  final int? cell;
  final int elapsedMs;
}

enum HintType { next, backtrack }

/// Pista calculada por el servidor
class Hint {
  const Hint({
    required this.type,
    required this.nextCell,
    required this.hintsUsed,
    this.undoSteps = 0,
  });

  final HintType type;
  final int nextCell;
  final int undoSteps;
  final int hintsUsed;
}

/// Resultado validado por el servidor
class GameResult {
  const GameResult({
    required this.points,
    required this.durationSeconds,
    required this.mistakes,
    required this.hintsUsed,
    required this.breakdown,
    required this.performance,
    required this.recommendedDifficulty,
    required this.difficultyChange,
  });

  final int points;
  final int durationSeconds;
  final int mistakes;
  final int hintsUsed;
  final Map<String, int> breakdown;
  final String performance;
  final String recommendedDifficulty;
  final String difficultyChange;
}
