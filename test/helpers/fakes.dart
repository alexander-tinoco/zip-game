import 'package:zip_game/core/errors/api_exception.dart';
import 'package:zip_game/features/auth/domain/entities/user.dart';
import 'package:zip_game/features/auth/domain/repositories/auth_repository.dart';
import 'package:zip_game/features/game/domain/entities/game_entities.dart';
import 'package:zip_game/features/game/domain/repositories/game_repository.dart';
import 'package:zip_game/features/game/domain/services/zip_rules.dart';
import 'package:zip_game/features/levels/domain/entities/level.dart';

/// Camino en serpiente: 0..5, 11..6, 12..17, 23..18, 24..29, 35..30
List<int> serpentine() => [
      for (var r = 0; r < 6; r++)
        for (var c = 0; c < 6; c++) r * 6 + (r.isEven ? c : 5 - c),
    ];

/// Nivel tutorial con un número cada 5 celdas del camino en serpiente
Level tutorialLevel() {
  final s = serpentine();
  return Level(
    id: 1,
    name: 'Tutorial',
    difficulty: 'easy',
    size: 6,
    checkpoints: [0, 5, 10, 15, 20, 25, 30, 35].map((i) => s[i]).toList(),
  );
}

/// Repositorio falso que imita al backend sin red
class FakeGameRepository implements GameRepository {
  final level = tutorialLevel();
  final solution = serpentine();
  int hints = 0;
  List<MoveRecord>? lastMoves;

  @override
  Future<({GameSession session, Level level})> startGame({int? levelId}) async => (
        session: const GameSession(id: 10, levelId: 1, status: 'in_progress', difficulty: 'easy'),
        level: level,
      );

  @override
  Future<Hint> requestHint(int sessionId, List<int> path) async {
    hints++;
    return Hint(type: HintType.next, nextCell: solution[path.length], hintsUsed: hints);
  }

  @override
  Future<GameResult> finishGame(int sessionId, List<int> path, List<MoveRecord> moves) async {
    lastMoves = moves;
    final rules = ZipRules(size: 6, checkpoints: level.checkpoints);
    if (!rules.isComplete(path)) {
      throw ApiException('Invalid path', statusCode: 422, code: 'E_INCOMPLETE');
    }
    final mistakes = moves.where((m) => m.type == MoveType.invalid).length;
    return GameResult(
      points: 1200 - mistakes * 25 - hints * 150,
      durationSeconds: 30,
      mistakes: mistakes,
      hintsUsed: hints,
      breakdown: const {'base': 1000, 'time_bonus': 270},
      performance: 'excellent',
      recommendedDifficulty: 'easy',
      difficultyChange: 'keep',
    );
  }
}

class FakeAuthRepository implements AuthRepository {
  static const demo = User(id: 1, username: 'demo', email: 'demo@zipgame.test', recommendedDifficulty: 'easy');

  @override
  Future<User> login({required String email, required String password}) async => demo;

  @override
  Future<User> register({required String username, required String email, required String password}) async =>
      demo;

  @override
  Future<User?> restoreSession() async => demo;

  @override
  Future<void> logout() async {}
}
